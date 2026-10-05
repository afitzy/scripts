#!/usr/bin/env bash
set -euo pipefail

# Run on the PC. Place subscription exports beside this script.
# Copies one selected export to Android Download; import in NewPipe manually.
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
for tool in adb python3 cmp; do
    command -v "$tool" >/dev/null 2>&1 || fail "$tool is required on this PC."
done
scriptDir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
shopt -s nullglob dotglob
files=()
for file in "$scriptDir"/*.json; do
    [[ -f "$file" ]] && files+=("$file")
done
((${#files[@]})) || fail "No .json files found beside the script: $scriptDir"
printf 'Found the following files:\n'
for index in "${!files[@]}"; do
    printf '  %d. %q\n' "$((index + 1))" "${files[index]##*/}"
done
while true; do
    read -r -p 'Which one do you want to push to the phone? Enter a number, or q to cancel: ' choice || fail 'No selection received.'
    [[ "$choice" != q && "$choice" != Q ]] || exit 0
    selectedFile=''
    # String comparison avoids arithmetic evaluation of user input.
    for index in "${!files[@]}"; do
        if [[ "$choice" == "$((index + 1))" ]]; then selectedFile="${files[index]}"; break; fi
    done
    [[ -n "$selectedFile" ]] && break
    printf 'Enter one of the listed numbers, or q.\n'
done
workDir="$(mktemp -d)"
trap 'rm -rf -- "$workDir"' EXIT
# Validate and snapshot once, so a later change to the source cannot alter upload.
python3 - "$selectedFile" "$workDir/subscriptions.json" <<'PY'
import json, pathlib, sys
try:
    with open(sys.argv[1], 'rb') as source:
        payload = source.read(20 * 1024 * 1024 + 1)
    if not 0 < len(payload) <= 20 * 1024 * 1024:
        raise ValueError('Export must contain 1 byte to 20 MiB.')
    data = json.loads(payload.decode('utf-8-sig'))
    if not isinstance(data, dict) or not isinstance(data.get('subscriptions'), list):
        raise ValueError('Expected a NewPipe subscriptions JSON export.')
    for item in data['subscriptions']:
        if (not isinstance(item, dict) or not isinstance(item.get('name'), str)
                or not isinstance(item.get('url'), str)
                or not item['url'].startswith(('https://', 'http://'))
                or type(item.get('service_id')) is not int or item['service_id'] < 0):
            raise ValueError('Invalid subscription entry.')
    pathlib.Path(sys.argv[2]).write_bytes(payload)
    print(f"Selected export contains {len(data['subscriptions'])} subscriptions.")
except (OSError, ValueError) as error:
    sys.exit(f'ERROR: {error}')
PY
printf 'Checking ADB connection...\n'
adb start-server >/dev/null || fail 'Could not start ADB.'
deviceList="$(adb devices)" || fail 'Could not list ADB devices.'
connectedDevices=()
while read -r serial state rest; do
    [[ "$state" == device ]] && connectedDevices+=("$serial")
done <<< "$deviceList"
if ((${#connectedDevices[@]} != 1)); then
    printf '%s\n' "$deviceList" >&2
    fail 'Connect and authorize exactly one Android phone with USB debugging enabled.'
fi
serial="${connectedDevices[0]}"
printf 'Using Android device: %s\n' "$serial"
# Generated destination contains only safe shell characters. Reserve it exclusively.
exportName="$(python3 -c 'import datetime, uuid; print("newpipe_subscriptions_" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S_") + uuid.uuid4().hex + ".json")' )"
remoteFile="/sdcard/Download/$exportName"
adb -s "$serial" shell "mkdir -p /sdcard/Download && (set -C; : > $remoteFile)" || fail 'Could not reserve a new file in phone Download.'
if ! adb -s "$serial" push "$workDir/subscriptions.json" "$remoteFile"; then
    fail "Transfer failed. A partial file may remain at $remoteFile. Your local export is unchanged."
fi
adb -s "$serial" exec-out "cat $remoteFile" > "$workDir/readback.json" || fail "Cannot verify $remoteFile. Your local export is unchanged."
cmp -s "$workDir/subscriptions.json" "$workDir/readback.json" || fail "Phone copy differs from the selected export: $remoteFile"
printf '\nCopy verified: %s\n' "$remoteFile"
printf 'On the phone: NewPipe > Subscriptions > menu > Import from > Previous export.\n'
printf 'Select Internal storage > Download > %s\n' "$exportName"
printf 'The file is copied; NewPipe import is still pending. Back up existing phone subscriptions before importing if you want to retain them.\n'
