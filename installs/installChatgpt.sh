#!/bin/bash

scriptName="$(basename "$0")"

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function isWsl ()
{
    if grep -qi microsoft /proc/version 2>/dev/null || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
        return 0
    fi

    return 1
}

function installChatgptUbuntu ()
{
    local friendlyName="chatgpt"
    local architecture
    local packageArchitecture
    local packageUrl
    local packageFile

    architecture="$(uname -m)"

    case "${architecture}" in
        x86_64|amd64)
            packageArchitecture="amd64"
            ;;
        aarch64|arm64)
            packageArchitecture="arm64"
            ;;
        *)
            echo "${friendlyName}: unsupported architecture: ${architecture}"
            return 1
            ;;
    esac

    packageUrl="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_${packageArchitecture}.deb"
    packageFile="$(mktemp --suffix=.deb)"

    trap 'rm -f "${packageFile}"' EXIT

    echo "${friendlyName}: downloading official OpenAI desktop package"

    if ! curl --proto '=https' --tlsv1.2 --fail --location \
        --output "${packageFile}" "${packageUrl}"; then
        echo "${friendlyName}: failed to download package."
        return 1
    fi

    if [[ ! -s "${packageFile}" ]]; then
        echo "${friendlyName}: downloaded package is empty."
        return 1
    fi

    echo "${friendlyName}: installing"
    sudo apt install --yes "${packageFile}"

    if ! command -v chatgpt >/dev/null 2>&1; then
        echo "${friendlyName}: installation completed, but the chatgpt command was not found."
        return 1
    fi

    echo "${friendlyName}: installed successfully"
    dpkg-query --show --showformat='${Package} ${Version}\n' chatgpt 2>/dev/null || true
}

if isWsl; then
    echo "chatgpt: Windows Subsystem for Linux detected."
    echo "chatgpt: not installing the Linux desktop package inside WSL."
    echo "chatgpt: install the Windows ChatGPT desktop app from Windows with:"
    echo "winget install --id 9PLM9XGG6VKS -s msstore"
    exit 1
fi

if [[ "$(getOsVers)" == "24.04" || "$(getOsVers)" == "26.04" ]]; then
    if ! command -v curl >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install --yes curl
    fi

    installChatgptUbuntu
else
    echo "Unrecognized or unsupported OS version. ChatGPT desktop app not installed."
    echo "Official Ubuntu support currently requires Ubuntu 24.04 LTS or 26.04 LTS."
    exit 1
fi
