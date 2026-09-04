#!/bin/bash
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    set -euo pipefail
fi

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Use repo utilities when this script is run from afitzy/scripts/installs.
if [[ -f "${scriptDir}/../utils.sh" ]]; then
    # shellcheck source=../utils.sh
    source "${scriptDir}/../utils.sh"
fi

_VERBOSE=1

AVD_NAME="TuyaSmartLifeTemp"
SDK_ROOT="${HOME}/.local/share/android-tuya-sdk"
CMDLINE_TOOLS_VERSION="15859902"
CMDLINE_TOOLS_SHA256="4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip"
SYSTEM_IMAGE="system-images;android-30;google_apis;x86_64"
AURORA_VERSION_CODE="76"
AURORA_URL="https://f-droid.org/repo/com.aurora.store_${AURORA_VERSION_CODE}.apk"
KVM_DEVICE="${KVM_DEVICE:-/dev/kvm}"

export ANDROID_HOME="${SDK_ROOT}"
export ANDROID_SDK_ROOT="${SDK_ROOT}"
export PATH="${SDK_ROOT}/cmdline-tools/latest/bin:${SDK_ROOT}/platform-tools:${SDK_ROOT}/emulator:${PATH}"

logMsg () {
    if declare -F log >/dev/null 2>&1; then
        log "$@"
    else
        echo "$@"
    fi
}

getUbuntuVersion () {
    if declare -F getOsVers >/dev/null 2>&1; then
        getOsVers
    else
        lsb_release --release --short 2>/dev/null || true
    fi
}

getUbuntuDistro () {
    if declare -F getOsDistro >/dev/null 2>&1; then
        getOsDistro
    else
        lsb_release --id --short 2>/dev/null || true
    fi
}

installPackages () {
    if declare -F getPackages >/dev/null 2>&1; then
        getPackages "$@"
    else
        sudo apt-get update
        sudo apt-get --yes install "$@"
    fi
}

verifyHost () {
    local distro version arch
    distro="$(getUbuntuDistro)"
    version="$(getUbuntuVersion)"
    arch="$(uname -m)"

    if [[ "${distro}" != "Ubuntu" ]]; then
        echo "Unsupported Linux distribution: ${distro:-unknown}. Ubuntu is required."
        exit 1
    fi

    case "${version}" in
        22.04*|24.04*|26.04*)
            ;;
        *)
            echo "Unsupported Ubuntu version: ${version:-unknown}."
            echo "Supported LTS releases: 22.04, 24.04, 26.04."
            exit 1
            ;;
    esac

    if [[ "${arch}" != "x86_64" ]]; then
        echo "Unsupported architecture: ${arch}."
        echo "Google's Android Emulator for Linux currently requires x86_64/amd64."
        exit 1
    fi

    if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
        echo "No graphical desktop session detected."
        echo "Run this script from your Ubuntu desktop session."
        exit 1
    fi

    logMsg "Verified Ubuntu ${version} on ${arch}."
}

verifyDiskSpace () {
    local availableKb minimumKb
    availableKb="$(df -Pk "${HOME}" | awk 'NR==2 {print $4}')"
    minimumKb=$((12 * 1024 * 1024))

    if [[ -z "${availableKb}" || "${availableKb}" -lt "${minimumKb}" ]]; then
        echo "At least 12 GiB of free space in ${HOME} is required."
        exit 1
    fi
}

installPrerequisites () {
    sudo apt-get update
    installPackages curl ca-certificates unzip openjdk-17-jre-headless
}

verifyKvm () {
    if [[ ! -e "${KVM_DEVICE}" ]]; then
        echo "${KVM_DEVICE} does not exist."
        echo "Enable Intel VT-x/AMD-V virtualization in BIOS/UEFI and rerun."
        exit 1
    fi

    if [[ ! -r "${KVM_DEVICE}" || ! -w "${KVM_DEVICE}" ]]; then
        if getent group kvm >/dev/null 2>&1 && ! id -nG "${USER}" | tr ' ' '\n' | grep -qx kvm; then
            echo "Your user is not in the kvm group. Adding it now:"
            sudo usermod -aG kvm "${USER}"
            echo
            echo "Log out of Ubuntu and log back in once, then rerun this script."
            exit 2
        fi

        echo "Your user cannot access ${KVM_DEVICE}."
        echo "Check ${KVM_DEVICE} permissions and KVM configuration, then rerun."
        exit 1
    fi
}

installAndroidCommandLineTools () {
    local zipFile tmpDir

    if [[ -x "${SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" ]]; then
        logMsg "Android command-line tools already installed."
        return
    fi

    mkdir -p "${SDK_ROOT}/cmdline-tools"
    tmpDir="$(mktemp -d)"
    zipFile="${tmpDir}/commandlinetools.zip"
    trap 'rm -rf "${tmpDir}"' RETURN

    logMsg "Downloading Android command-line tools from Google."
    curl -fL --retry 3 --retry-delay 2 "${CMDLINE_TOOLS_URL}" -o "${zipFile}"

    echo "${CMDLINE_TOOLS_SHA256}  ${zipFile}" | sha256sum --check --status || {
        echo "Android command-line tools checksum verification failed."
        exit 1
    }

    unzip -q "${zipFile}" -d "${tmpDir}/unpacked"
    rm -rf "${SDK_ROOT}/cmdline-tools/latest"
    mkdir -p "${SDK_ROOT}/cmdline-tools/latest"
    mv "${tmpDir}/unpacked/cmdline-tools/"* "${SDK_ROOT}/cmdline-tools/latest/"

    trap - RETURN
    rm -rf "${tmpDir}"
}

acceptAndroidLicenses () {
    # Android SDK licenses are required to download Google's emulator/system image.
    yes | sdkmanager --sdk_root="${SDK_ROOT}" --licenses >/dev/null || true
}

installAndroidPackages () {
    logMsg "Installing Android Emulator, platform tools, and ARM-compatible Android 11 image."
    acceptAndroidLicenses
    sdkmanager --sdk_root="${SDK_ROOT}" \
        "platform-tools" \
        "emulator" \
        "${SYSTEM_IMAGE}"
}

verifyEmulatorAcceleration () {
    local output
    output="$(emulator -accel-check 2>&1 || true)"

    if ! grep -qiE 'KVM.*(installed|usable)|accel.*(installed|usable)' <<<"${output}"; then
        echo "Android Emulator hardware acceleration check failed:"
        echo "${output}"
        exit 1
    fi
}

createAvd () {
    if avdmanager list avd 2>/dev/null | grep -Fq "Name: ${AVD_NAME}"; then
        logMsg "Temporary Tuya AVD already exists."
        return
    fi

    logMsg "Creating disposable Android 11 AVD: ${AVD_NAME}"
    echo "no" | avdmanager create avd \
        --force \
        --name "${AVD_NAME}" \
        --package "${SYSTEM_IMAGE}"
}

startAvd () {
    if adb devices 2>/dev/null | grep -q '^emulator-[0-9].*device$'; then
        logMsg "An Android emulator is already running."
    else
        logMsg "Starting the disposable Android emulator."
        emulator "@${AVD_NAME}" \
            -accel on \
            -no-audio \
            -no-boot-anim \
            -no-snapshot-save \
            -camera-back none \
            -camera-front none \
            >/tmp/${AVD_NAME}.log 2>&1 &
    fi

    logMsg "Waiting for Android to finish booting."
    adb wait-for-device

    local booted=0
    for i in {1..120}; do
        if [[ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
            booted=1
            break
        fi
        sleep 2
    done

    if [[ "${booted}" -ne 1 ]]; then
        echo "Android did not finish booting. Recent emulator log:"
        tail -80 "/tmp/${AVD_NAME}.log" 2>/dev/null || true
        exit 1
    fi

    # Keep location disabled unless the user explicitly enables it inside Android.
    adb shell settings put secure location_mode 0 >/dev/null 2>&1 || true
}

installAuroraStore () {
    local apkFile
    apkFile="$(mktemp --suffix=.apk)"

    logMsg "Downloading pinned Aurora Store ${AURORA_VERSION_CODE} from F-Droid."
    curl -fL --retry 3 --retry-delay 2 "${AURORA_URL}" -o "${apkFile}"

    logMsg "Installing Aurora Store into the disposable Android VM."
    adb install -r "${apkFile}" >/dev/null
    rm -f "${apkFile}"

    if ! adb shell pm path com.aurora.store 2>/dev/null | grep -q '^package:'; then
        echo "Aurora Store installation verification failed."
        exit 1
    fi

    adb shell monkey -p com.aurora.store -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true
}

showInstructions () {
    cat <<EOF2

============================================================
 DISPOSABLE ANDROID ENVIRONMENT READY
============================================================

This AVD uses Android 11 / API 30 Google APIs x86_64. Google documents
this image as supporting x86, x86_64, ARMv7 and ARM64 app binaries.

Next:
  1. Aurora Store has already been installed from F-Droid and opened.
  2. In Aurora Store, choose Anonymous login.
  3. Search for Smart Life.
  4. Verify the package ID is:
       com.tuya.smartlife
  5. Install Smart Life and sign into the account containing Dustin.
  6. In Smart Life, get the Tuya User Code.
  7. In Home Assistant:
       Settings -> Devices & services -> Add Integration -> Tuya
  8. Enter the User Code and approve Home Assistant's QR authorization.
  9. Confirm Dustin appears in Home Assistant.

Smart Life is isolated inside this disposable Android VM. Do not enable
shared folders or grant camera, microphone, contacts, or host-file access.

When finished:
    ${scriptName} destroy

============================================================
EOF2
}

stopAvd () {
    local serial
    serial="$(adb devices 2>/dev/null | awk '/^emulator-[0-9]+[[:space:]]+device$/ {print $1; exit}')"

    if [[ -n "${serial}" ]]; then
        adb -s "${serial}" emu kill >/dev/null 2>&1 || true
        sleep 2
    fi
}

destroyEnvironment () {
    stopAvd

    if [[ -x "${SDK_ROOT}/cmdline-tools/latest/bin/avdmanager" ]]; then
        avdmanager delete avd --name "${AVD_NAME}" >/dev/null 2>&1 || true
    fi

    rm -rf "${HOME}/.android/avd/${AVD_NAME}.avd"
    rm -f "${HOME}/.android/avd/${AVD_NAME}.ini"

    if [[ "${1:-}" == "--all" ]]; then
        rm -rf "${SDK_ROOT}"
        logMsg "Removed temporary AVD and its dedicated Android SDK."
    else
        logMsg "Removed temporary AVD."
        echo "The dedicated SDK is retained at ${SDK_ROOT} for faster reuse."
        echo "To remove it too: ${scriptName} destroy --all"
    fi
}

installEnvironment () {
    verifyHost
    verifyDiskSpace
    installPrerequisites
    verifyKvm
    installAndroidCommandLineTools
    installAndroidPackages
    verifyEmulatorAcceleration
    createAvd
    startAvd
    installAuroraStore
    showInstructions
}

main () {
    case "${1:-install}" in
        install)
            installEnvironment
            ;;
        start)
            verifyHost
            verifyKvm
            startAvd
            showInstructions
            ;;
        destroy)
            destroyEnvironment "${2:-}"
            ;;
        *)
            echo "Usage:"
            echo "  ${scriptName} install"
            echo "  ${scriptName} start"
            echo "  ${scriptName} destroy [--all]"
            return 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
