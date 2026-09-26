#!/bin/bash

scriptName="$(basename "$0")"

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

installerUrl="https://chatgpt.com/codex/install.sh"

echo "codex: checking prerequisites"

if ! command -v curl >/dev/null 2>&1; then
    echo "codex: curl is required but is not installed."
    exit 1
fi

case "$(uname -s)" in
    Linux|Darwin)
        ;;
    *)
        echo "codex: unsupported operating system: $(uname -s)"
        exit 1
        ;;
esac

case "$(uname -m)" in
    x86_64|amd64|aarch64|arm64)
        ;;
    *)
        echo "codex: unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac

if command -v codex >/dev/null 2>&1; then
    echo "codex: existing installation found"
    codex --version || true
else
    echo "codex: no existing installation found"
fi

echo "codex: downloading official OpenAI installer"

installerFile="$(mktemp)"
trap 'rm -f "${installerFile}"' EXIT

if ! curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
    "${installerUrl}" --output "${installerFile}"; then
    echo "codex: failed to download official OpenAI installer."
    exit 1
fi

if [[ ! -s "${installerFile}" ]]; then
    echo "codex: downloaded installer is empty."
    exit 1
fi

echo "codex: installing"
if ! sh "${installerFile}"; then
    echo "codex: installation failed."
    exit 1
fi

# OpenAI's installer normally installs to ~/.local/bin. Make that location
# available immediately even when the current shell has not reloaded its
# profile yet.
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! command -v codex >/dev/null 2>&1; then
    echo "codex: installed, but codex is not currently in PATH."
    echo "codex: open a new shell and run: codex --version"
    exit 1
fi

echo "codex: installed successfully"
codex --version

echo
echo "Run 'codex' and select 'Sign in with ChatGPT' to authenticate."
