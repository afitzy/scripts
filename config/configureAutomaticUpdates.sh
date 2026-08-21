#!/usr/bin/env bash
#
# configureAutomaticUpdates.sh
#
# Configure Ubuntu/Kubuntu for low-maintenance automatic updates.
#
# Configuration:
#   - Automatically refresh APT package lists daily
#   - Automatically install security updates
#   - Automatically install Ubuntu Pro ESM updates when Pro is attached
#   - Automatically install normal stable -updates
#   - Do NOT automatically install -proposed or -backports
#   - Do NOT automatically reboot the computer
#   - Keep future distribution upgrades on the LTS track
#   - Leave Snap's built-in automatic updates enabled
#
# Intended for Ubuntu/Kubuntu LTS systems, including Ubuntu/Kubuntu 26.04.
#

set -euo pipefail

readonly AUTO_UPGRADES_FILE="/etc/apt/apt.conf.d/20auto-upgrades"
readonly UNATTENDED_LOCAL_FILE="/etc/apt/apt.conf.d/52unattended-upgrades-local"
readonly RELEASE_UPGRADES_FILE="/etc/update-manager/release-upgrades"

info() {
    printf '\n==> %s\n' "$*"
}

warn() {
    printf '\nWARNING: %s\n' "$*" >&2
}

die() {
    printf '\nERROR: %s\n' "$*" >&2
    exit 1
}

if [[ ${EUID} -ne 0 ]]; then
    die "This script must be run as root. Try: sudo $0"
fi

if [[ ! -r /etc/os-release ]]; then
    die "Unable to determine the operating system."
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" && "${ID_LIKE:-}" != *"ubuntu"* ]]; then
    die "This script is intended for Ubuntu or Ubuntu-based distributions."
fi

if ! command -v apt-get >/dev/null 2>&1; then
    die "APT was not found."
fi

info "Detected: ${PRETTY_NAME:-Ubuntu-based Linux}"

info "Updating package lists..."
apt-get update

info "Installing automatic-update components..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unattended-upgrades \
    update-manager-core \
    ubuntu-pro-client

info "Configuring daily automatic package updates..."

cat > "${AUTO_UPGRADES_FILE}" <<'EOF'
//
// Managed by configureAutomaticUpdates.sh
//

APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

info "Configuring unattended-upgrades..."

cat > "${UNATTENDED_LOCAL_FILE}" <<'EOF'
//
// Managed by configureAutomaticUpdates.sh
//
// Automatically install:
//   * Ubuntu release packages
//   * Security updates
//   * Ubuntu Pro ESM Apps security updates
//   * Ubuntu Pro ESM Infra security updates
//   * Normal stable updates
//
// Deliberately exclude:
//   * proposed
//   * backports
//   * arbitrary third-party repositories
//

#clear Unattended-Upgrade::Allowed-Origins;

Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
    "${distro_id}:${distro_codename}-updates";
};

Unattended-Upgrade::Automatic-Reboot "false";
EOF

info "Enabling APT automatic-update timers..."

systemctl enable --now apt-daily.timer
systemctl enable --now apt-daily-upgrade.timer

info "Configuring release upgrades for LTS releases only..."

if [[ -f "${RELEASE_UPGRADES_FILE}" ]]; then
    if grep -q '^Prompt=' "${RELEASE_UPGRADES_FILE}"; then
        sed -i 's/^Prompt=.*/Prompt=lts/' "${RELEASE_UPGRADES_FILE}"
    else
        printf '\nPrompt=lts\n' >> "${RELEASE_UPGRADES_FILE}"
    fi
else
    cat > "${RELEASE_UPGRADES_FILE}" <<'EOF'
[DEFAULT]
Prompt=lts
EOF
fi

info "Effective automatic-update configuration:"

apt-config dump | grep -E \
    'APT::Periodic::(Update-Package-Lists|Unattended-Upgrade)|Unattended-Upgrade::Allowed-Origins|Unattended-Upgrade::Automatic-Reboot' \
    || true

info "APT update timers:"

systemctl list-timers \
    apt-daily.timer \
    apt-daily-upgrade.timer \
    --no-pager \
    || true

info "Ubuntu Pro status:"

if command -v pro >/dev/null 2>&1; then
    pro status || true

    echo
    echo "For this PC, Ubuntu Pro should normally show:"
    echo "  esm-apps   enabled"
    echo "  esm-infra  enabled"
    echo "  livepatch  enabled (when supported)"
    echo
    echo "If this computer is not yet attached, run:"
    echo
    echo "  sudo pro attach"
else
    warn "Ubuntu Pro client is not available."
fi

if command -v snap >/dev/null 2>&1; then
    info "Snap automatic-update schedule:"
    snap refresh --time || true
fi

info "Testing unattended-upgrades configuration..."

if unattended-upgrade --dry-run --verbose; then
    info "unattended-upgrades dry-run completed successfully."
else
    warn "The unattended-upgrades dry-run reported a problem."
    warn "Review the output above before relying on automatic updates."
    exit 1
fi

cat <<'EOF'

Automatic update configuration complete.

Configured:
  [x] Daily APT package-list refresh
  [x] Automatic Ubuntu/Kubuntu security updates
  [x] Automatic normal stable updates (-updates)
  [x] Ubuntu Pro ESM updates when Pro is attached
  [x] Automatic Firefox/Chromium Snap updates remain enabled
  [x] LTS-only operating-system upgrade path
  [x] Automatic reboot disabled

Not enabled:
  [ ] proposed updates
  [ ] backports
  [ ] arbitrary third-party repositories
  [ ] automatic distribution upgrades
  [ ] automatic unattended reboot

IMPORTANT:
  Major Kubuntu LTS upgrades should still be performed manually.
  For M&J PC, plan a supervised Kubuntu 26.04 -> 28.04 upgrade
  around 2030-2031.

EOF
