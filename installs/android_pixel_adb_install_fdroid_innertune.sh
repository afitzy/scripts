#!/usr/bin/env bash
set -euo pipefail

# Install/update the official F-Droid client on one authorized Android phone,
# then open InnerTune's package page in F-Droid for user-approved installation.
#
# This intentionally does NOT sideload InnerTune. F-Droid remains responsible
# for selecting, downloading, verifying, installing, and updating InnerTune.

FDROID_PACKAGE="org.fdroid.fdroid"
FDROID_VERSION_CODE="1023052"
FDROID_VERSION_NAME="1.23.2"
FDROID_APK_NAME="org.fdroid.fdroid_${FDROID_VERSION_CODE}.apk"
FDROID_APK_URL="https://f-droid.org/repo/${FDROID_APK_NAME}"
FDROID_CERT_SHA256="43238d512c1e5eb2d6569f4a3afbf5523418b82e0a3ed1552770abb9a9c9ccab"

INNERTUNE_PACKAGE="com.zionhuang.music"
INNERTUNE_FDROID_URL="https://f-droid.org/packages/${INNERTUNE_PACKAGE}/"
INNERTUNE_FDROID_DEEP_LINK="fdroid.app://details?id=${INNERTUNE_PACKAGE}"

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

normalize_hex() {
    tr '[:upper:]' '[:lower:]' | tr -cd '0-9a-f'
}

require_command adb
require_command curl
require_command apksigner
require_command aapt

printf 'Starting ADB server...\n'
adb start-server >/dev/null

mapfile -t adbDevices < <(adb devices | awk 'NR > 1 && $2 == "device" {print $1}')

if (( ${#adbDevices[@]} != 1 )); then
    printf '\nADB devices detected:\n' >&2
    adb devices -l >&2 || true
    fail "Connect and authorize exactly one Android phone with USB debugging enabled."
fi

device="${adbDevices[0]}"
printf 'Using Android device: %s\n' "$device"

androidRelease="$(adb -s "$device" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')"
deviceModel="$(adb -s "$device" shell getprop ro.product.model 2>/dev/null | tr -d '\r')"
printf 'Device: %s (Android %s)\n' "${deviceModel:-unknown}" "${androidRelease:-unknown}"

tmpDir="$(mktemp -d)"
trap 'rm -rf "$tmpDir"' EXIT
fdroidApk="${tmpDir}/${FDROID_APK_NAME}"

printf '\nDownloading official F-Droid %s...\n' "$FDROID_VERSION_NAME"
curl --fail --location --show-error --silent \
    --output "$fdroidApk" \
    "$FDROID_APK_URL"

[[ -s "$fdroidApk" ]] || fail "Downloaded F-Droid APK is empty."

printf 'Verifying F-Droid APK signature...\n'
apksigner verify "$fdroidApk" >/dev/null || fail "F-Droid APK signature verification failed."

actualCert="$({ apksigner verify --print-certs "$fdroidApk" 2>/dev/null || true; } \
    | sed -n 's/^Signer #1 certificate SHA-256 digest: //p' \
    | head -n 1 \
    | normalize_hex)"

[[ -n "$actualCert" ]] || fail "Could not read the F-Droid APK signing certificate."
[[ "$actualCert" == "$FDROID_CERT_SHA256" ]] || fail "F-Droid signing certificate mismatch."

printf 'Verifying F-Droid package identity and version...\n'
badging="$(aapt dump badging "$fdroidApk" 2>/dev/null)" || fail "Could not inspect F-Droid APK metadata."
packageName="$(sed -n "s/^package: name='\([^']*\)'.*/\1/p" <<<"$badging" | head -n 1)"
versionCode="$(sed -n "s/^package: .*versionCode='\([^']*\)'.*/\1/p" <<<"$badging" | head -n 1)"

[[ "$packageName" == "$FDROID_PACKAGE" ]] || fail "Unexpected package in F-Droid APK: ${packageName:-unknown}"
[[ "$versionCode" == "$FDROID_VERSION_CODE" ]] || fail "Unexpected F-Droid version code: ${versionCode:-unknown}"

printf 'Installing/updating verified F-Droid on %s...\n' "$device"
adb -s "$device" install -r "$fdroidApk"

installedPath="$(adb -s "$device" shell pm path "$FDROID_PACKAGE" 2>/dev/null | tr -d '\r')"
[[ "$installedPath" == package:* ]] || fail "F-Droid was not found after installation."

printf '\nOpening InnerTune in F-Droid...\n'
if ! adb -s "$device" shell am start \
    -a android.intent.action.VIEW \
    -d "$INNERTUNE_FDROID_DEEP_LINK" \
    "$FDROID_PACKAGE" >/dev/null 2>&1; then
    printf 'F-Droid deep link was not accepted; opening the official F-Droid web listing instead.\n'
    adb -s "$device" shell am start \
        -a android.intent.action.VIEW \
        -d "$INNERTUNE_FDROID_URL" >/dev/null
fi

cat <<EOF2

F-Droid is installed and verified.

On the phone:
  1. If F-Droid is still refreshing its repository index, let that finish.
  2. Confirm the app shown is "InnerTune" with package ID:
       ${INNERTUNE_PACKAGE}
  3. Tap Install in F-Droid and approve Android's package-install prompt if asked.

The script deliberately does not sideload InnerTune or bypass Android/F-Droid's
normal installation approval flow.
EOF2
