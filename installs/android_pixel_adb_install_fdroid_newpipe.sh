#!/usr/bin/env bash
set -euo pipefail

# Installs the stable F-Droid client from F-Droid's official repository, then
# opens Team NewPipe's fingerprinted repository link in F-Droid. Confirm the
# repository prompt and install NewPipe from the matching repository entry.

F_DROID_APK_URL='https://f-droid.org/repo/org.fdroid.fdroid_1023052.apk'
F_DROID_PACKAGE='org.fdroid.fdroid'
# Official APK certificate SHA-256 (not a hash of the APK file):
# https://f-droid.org/en/docs/Release_Channels_and_Signing_Keys/
F_DROID_CERT_SHA256='43238d512c1e5eb2d6569f4a3afbf5523418b82e0a3ed1552770abb9a9c9ccab'
F_DROID_VERSION_CODE='1023052'
NEWPIPE_REPO_URL='https://archive.newpipe.net/fdroid/repo/?fingerprint=E2402C78F9B97C6C89E97DB914A2751FDA1D02FE2039CC0897A462BDB57E7501'

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

command -v adb >/dev/null 2>&1 || fail 'adb is not installed or is not on PATH. Install Android Platform Tools first.'
command -v curl >/dev/null 2>&1 || fail 'curl is required to download F-Droid from its official HTTPS site.'
command -v apksigner >/dev/null 2>&1 || fail 'apksigner is required for cryptographic verification. On Ubuntu: sudo apt install apksigner'
command -v aapt >/dev/null 2>&1 || fail 'aapt is required to check the package identity. On Ubuntu: sudo apt install aapt'

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
apk_path="$work_dir/fdroid.apk"

printf 'Checking ADB connection...\n'
adb start-server >/dev/null
mapfile -t connected_devices < <(adb devices | awk 'NR > 1 && $2 == "device" { print $1 }')
if [[ "${#connected_devices[@]}" -ne 1 ]]; then
    adb devices -l >&2
    fail 'Connect and authorize exactly one Android phone with USB debugging enabled.'
fi

printf 'Downloading the stable F-Droid APK from f-droid.org...\n'
curl --fail --location --proto '=https' --proto-redir '=https' --tlsv1.2 --connect-timeout 20 --max-time 300 --silent --show-error "$F_DROID_APK_URL" --output "$apk_path"
[[ -s "$apk_path" ]] || fail 'The F-Droid download was empty.'

printf 'Verifying APK signature and pinned official signing certificate...\n'
if ! signatureReport="$(LC_ALL=C apksigner verify --verbose --print-certs "$apk_path" 2>&1)"; then
    fail 'APK signature verification failed. Nothing was installed.'
fi
signerDigest="$(printf '%s\n' "$signatureReport" | sed -nE 's/^Signer #[0-9]+ certificate SHA-256 digest: ([[:xdigit:]]+)$/\1/p' | tr '[:upper:]' '[:lower:]')"
[[ "$signerDigest" == "$F_DROID_CERT_SHA256" ]] || fail 'APK signer does not exactly match the pinned F-Droid certificate. Nothing was installed.'

packageReport="$(LC_ALL=C aapt dump badging "$apk_path")" || fail 'Cannot read APK package identity.'
packageName="$(printf '%s\n' "$packageReport" | sed -n "s/^package: name='\([^']*\)'.*/\1/p")"
versionCode="$(printf '%s\n' "$packageReport" | sed -n "s/^package: .*versionCode='\([^']*\)'.*/\1/p")"
[[ "$packageName" == "$F_DROID_PACKAGE" && "$versionCode" == "$F_DROID_VERSION_CODE" ]] || fail 'Unexpected APK package or version. Nothing was installed.'

printf 'Installing F-Droid on device %s...\n' "${connected_devices[0]}"
adb -s "${connected_devices[0]}" install -r "$apk_path"
installedPath="$(adb -s "${connected_devices[0]}" shell pm path "$F_DROID_PACKAGE")"
[[ "$installedPath" == package:* ]] || fail 'F-Droid package was not found after installation.'

printf "Opening Team NewPipe's fingerprinted repository link...\n"
adb -s "${connected_devices[0]}" shell am start \
    -a android.intent.action.VIEW \
    -d "$NEWPIPE_REPO_URL"

cat <<'INSTRUCTIONS'

On the Pixel:
1. Check that the F-Droid prompt identifies the NewPipe upstream repository and shows the official fingerprint from Team NewPipe.
2. Accept the repository and let F-Droid refresh its index.
3. In F-Droid, open NewPipe and choose the version labeled "Repository: NewPipe upstream repository".
4. Approve Android's install prompt. Keep Play Protect enabled.

The script does not uninstall or replace an existing NewPipe installation. If an existing copy has a different signing key, follow Team NewPipe's backup-and-switch instructions before changing sources.
INSTRUCTIONS
