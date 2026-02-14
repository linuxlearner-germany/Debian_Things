#!/usr/bin/env bash
#
# Automatisches Update-Script für Debian-basierte Systeme (Debian 12/13+)
# Automatic update script for Debian-based systems (Debian 12/13+)
#
# Features:
#  - apt-get update + upgrade (inkl. Security, wenn security-Repo aktiv ist)
#  - optional: full-upgrade, Flatpak, needrestart, Auto-Reboot (wenn Marker existiert)
#  - Logging nach /var/log (Fallback: /tmp)
#
# Usage:
#   sudo ./update.sh
#   sudo ./update.sh --full
#   sudo ./update.sh --flatpak
#   sudo ./update.sh --helpers
#   sudo ./update.sh --reboot
#   sudo ./update.sh --help
#

set -euo pipefail
IFS=$'\n\t'

# --- Farben / Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- Print Helpers ---
g() { printf "%b\n" "${GREEN}$*${NC}"; }  # green
r() { printf "%b\n" "${RED}$*${NC}"; }    # red
blank() { printf "\n"; }

# --- Defaults ---
FULL_UPGRADE=0
DO_FLATPAK=0
INSTALL_HELPERS=0
AUTO_REBOOT=0

usage() {
  cat <<'EOF'
Usage: sudo ./update.sh [OPTIONS]

Options:
  --full        Use apt-get full-upgrade (may remove/replace packages)
  --flatpak     Update Flatpak apps (installs flatpak if missing; adds flathub if needed)
  --helpers     Install helper tools (needrestart) and run post-checks
  --reboot      Reboot automatically if a reboot marker file exists
  --no-reboot   Never reboot automatically (default)
  -h, --help    Show this help

Notes:
  - Security updates are included automatically if your Debian security repository is enabled.
  - This script logs output to /var/log (fallback: /tmp).
EOF
}

for arg in "$@"; do
  case "$arg" in
    "") continue ;;
    --full) FULL_UPGRADE=1 ;;
    --flatpak) DO_FLATPAK=1 ;;
    --helpers) INSTALL_HELPERS=1 ;;
    --reboot) AUTO_REBOOT=1 ;;
    --no-reboot) AUTO_REBOOT=0 ;;
    -h|--help) usage; exit 0 ;;
    *)
      r "Unbekanntes Argument / Unknown argument: $arg"
      usage
      exit 2
      ;;
  esac
done

# --- Error handler ---
on_error() {
  local ec=$?
  r "FEHLER / ERROR: Exit-Code ${ec}"
  r "Letzte Zeile / Last line: ${BASH_COMMAND}"
  exit "$ec"
}
trap on_error ERR

# --- Root check ---
if [[ "${EUID}" -ne 0 ]]; then
  r "Bitte als root ausführen / Please run as root (sudo)."
  exit 1
fi

# --- Check package manager availability ---
if ! command -v apt-get >/dev/null 2>&1; then
  r "Kein 'apt-get' gefunden / No 'apt-get' found."
  exit 2
fi

# --- Banner ---
blank
r "ヽ༼ຈل͜ຈ༽ﾉ"
g "<|START|>"
g "============1=1=1=1=1=1=1=1=1=1=1=1=1=1=1=1=1=1=================="
g "#    Automatisches System-Update / Automatic system update      #"
g "#                           (Debian)                            #"
g "================================================================="
blank

# --- Logging ---
LOGDIR="/var/log"
LOGFILE="${LOGDIR}/system-update-$(date +%F_%H-%M-%S).log"
if ! ( touch "$LOGFILE" 2>/dev/null ); then
  LOGDIR="/tmp"
  LOGFILE="${LOGDIR}/system-update-$(date +%F_%H-%M-%S).log"
  touch "$LOGFILE"
fi
chmod 600 "$LOGFILE" || true
exec > >(tee -a "$LOGFILE") 2>&1

g "Logfile / Log: $LOGFILE"
g "Host: $(hostname)  Kernel: $(uname -r)"
blank

export DEBIAN_FRONTEND=noninteractive

# Recommended dpkg options for unattended scripts
APT_GET=(apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)

# --- Security repo hint (warning only) ---
if grep -RqsE 'security\.debian\.org|[-]security' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  g "Security-Repo: gefunden (OK)"
else
  r "WARNUNG: Kein Security-Repo in APT-Quellen gefunden."
  r "          APT installiert Security-Updates nur, wenn die Quellen korrekt gesetzt sind."
fi
blank

# ---------------- APT UPDATE ----------------
g "|-> Aktualisiere Paketquellen / Update package lists"
apt-get update
g "<-|"
blank

if [[ "$INSTALL_HELPERS" -eq 1 ]]; then
  g "|-> Installiere Helfer / Install helpers: needrestart"
  # needrestart is optional; ignore failure if repo policies block it
  "${APT_GET[@]}" install needrestart || true
  g "<-|"
  blank
fi

# ---------------- APT UPGRADE ----------------
if [[ "$FULL_UPGRADE" -eq 1 ]]; then
  g "|-> Vollständiges Upgrade / full-upgrade (kann Pakete entfernen/ersetzen)"
  "${APT_GET[@]}" full-upgrade
else
  g "|-> Installiere Updates / upgrade"
  "${APT_GET[@]}" upgrade
fi
g "<-|"
blank

# ---------------- CLEANUP ----------------
g "|-> Entferne nicht mehr benötigte Pakete / autoremove (purge)"
"${APT_GET[@]}" autoremove --purge
g "<-|"
blank

g "|-> Bereinige Paket-Cache / clean"
apt-get clean
g "<-|"
blank

# ---------------- FLATPAK (optional) ----------------
if [[ "$DO_FLATPAK" -eq 1 ]]; then
  r "-----------------------"
  g "============2=2=2=2=2=2=2=2=2=2=2=2=2=2=2=2=2=2=================="
  g "Flatpak Updates (optional)                                      #"
  g "================================================================="
  blank

  if ! command -v flatpak >/dev/null 2>&1; then
    g "|-> Flatpak nicht gefunden – installiere Flatpak / installing flatpak"
    "${APT_GET[@]}" install flatpak
    g "<-|"
    blank
  else
    g "|-> Flatpak ist bereits installiert / flatpak already installed"
    g "<-|"
    blank
  fi

  # Add flathub if missing
  if ! flatpak remotes 2>/dev/null | grep -q '^flathub$'; then
    g "|-> Füge Flathub hinzu / add flathub"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    g "<-|"
    blank
  else
    g "|-> Flathub ist bereits vorhanden / flathub already present"
    g "<-|"
    blank
  fi

  g "|-> Aktualisiere Flatpak-Apps / flatpak update"
  flatpak update -y || true
  g "<-|"
  blank
fi

# ---------------- POST CHECKS ----------------
g "================================================================="
g "System-Update abgeschlossen / Update completed                   #"
g "================================================================="
blank

r "     /\    "
r "    /  \   "
r "   /    \  "
r "  /      \ "
r "  ¯¯¯¯¯¯¯¯ "
r "  ( ͡° ͜ʖ ͡°)"
blank

if command -v needrestart >/dev/null 2>&1; then
  g "|-> needrestart Check (Hinweis auf notwendige Neustarts / hints)"
  # list-only; do not auto-restart services
  needrestart -r l || true
  g "<-|"
  blank
else
  g "Hinweis: needrestart nicht installiert (optional: --helpers)."
  blank
fi

# Debian may or may not provide these reboot markers; check both.
REBOOT_MARKER=0
if [[ -f /run/reboot-required || -f /var/run/reboot-required ]]; then
  REBOOT_MARKER=1
fi

if [[ "$REBOOT_MARKER" -eq 1 ]]; then
  r "Neustart erforderlich (Marker gefunden) / Reboot required (marker found)."
  if [[ "$AUTO_REBOOT" -eq 1 ]]; then
    g "|-> Auto-Reboot aktiv – reboot in 10 Sekunden (Ctrl+C zum Abbrechen)"
    sleep 10
    systemctl reboot
  else
    g "Auto-Reboot ist AUS. Bitte bei Gelegenheit neu starten."
  fi
else
  g "Kein Reboot-Marker gefunden. Ein Neustart kann trotzdem sinnvoll sein (z.B. Kernel/critical libs)."
fi

g "<|END|>"
