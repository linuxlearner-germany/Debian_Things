#!/usr/bin/env bash

set -o pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

g() { printf "%b\n" "${GREEN}$*${NC}"; }
r() { printf "%b\n" "${RED}$*${NC}"; }
y() { printf "%b\n" "${YELLOW}$*${NC}"; }
blank() { printf "\n"; }

show_logo() {
  printf "%b" "$RED"
  cat <<'EOF'
ヽ༼ຈل͜ຈ༽ﾉ
██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗
██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗
██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝
╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗
 ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝
EOF
  printf "%b\n" "$NC"
}

selected_in_list() {
  local item="$1"
  local list="$2"

  case " $list " in
    *" $item "*) return 0 ;;
    *) return 1 ;;
  esac
}

blank
blank
show_logo
g "================== SYSTEM_UPDATE =================="

# ------------------------------------------------------------
# Root prüfen
# ------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
  r "Bitte als root starten:"
  y "sudo $0"
  exit 1
fi

# ------------------------------------------------------------
# Benötigte Programme prüfen
# ------------------------------------------------------------

if ! command -v apt >/dev/null 2>&1; then
  r "APT nicht gefunden."
  exit 2
fi

if ! command -v whiptail >/dev/null 2>&1; then
  r "whiptail ist nicht installiert."
  y "Installiere es mit:"
  y "sudo apt update && sudo apt install whiptail -y"
  exit 3
fi

HAS_FLATPAK=false

if command -v flatpak >/dev/null 2>&1; then
  HAS_FLATPAK=true
fi

# ------------------------------------------------------------
# APT-Paketquellen aktualisieren
# ------------------------------------------------------------

blank
g "Aktualisiere APT-Paketquellen..."
apt update

if [ $? -ne 0 ]; then
  r "APT update ist fehlgeschlagen."
  exit 4
fi

# ------------------------------------------------------------
# APT-Updates per Checkbox auswählen
# ------------------------------------------------------------

APT_PACKAGES="$(
  apt list --upgradable 2>/dev/null |
    awk -F/ 'NR > 1 {print $1}' |
    sort -u
)"

SELECTED_APT_PACKAGES=""

if [ -n "$APT_PACKAGES" ]; then
  APT_OPTIONS=()

  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    APT_OPTIONS+=("$pkg" "APT-Paketupdate" "ON")
  done <<< "$APT_PACKAGES"

  SELECTED_APT_PACKAGES="$(
    whiptail \
      --title "APT Updates auswählen" \
      --checklist "Mit LEERTASTE Pakete an-/abwählen, mit TAB zu <Ok>, mit ENTER bestätigen." \
      25 100 15 \
      "${APT_OPTIONS[@]}" \
      3>&1 1>&2 2>&3
  )"

  if [ $? -ne 0 ]; then
    y "APT-Paketauswahl abgebrochen oder übersprungen."
    SELECTED_APT_PACKAGES=""
  fi

  SELECTED_APT_PACKAGES="$(printf "%s" "$SELECTED_APT_PACKAGES" | tr -d '"')"
else
  y "Keine APT-Updates verfügbar."
fi

# ------------------------------------------------------------
# Flatpak-Updates per Checkbox auswählen
# ------------------------------------------------------------

SELECTED_FLATPAK_REFS=""

if [ "$HAS_FLATPAK" = true ]; then
  blank
  g "Prüfe Flatpak-Updates..."

  FLATPAK_UPDATES="$(
    flatpak remote-ls --updates --columns=application,branch 2>/dev/null
  )"

  if [ -n "$FLATPAK_UPDATES" ]; then
    FLATPAK_OPTIONS=()

    while IFS=$'\t' read -r app branch; do
      [ -z "$app" ] && continue
      [ -z "$branch" ] && branch="stable"

      ref="${app}//${branch}"
      label="${app} (${branch})"

      FLATPAK_OPTIONS+=("$ref" "$label" "ON")
    done <<< "$FLATPAK_UPDATES"

    SELECTED_FLATPAK_REFS="$(
      whiptail \
        --title "Flatpak Updates auswählen" \
        --checklist "Mit LEERTASTE Pakete an-/abwählen, mit TAB zu <Ok>, mit ENTER bestätigen." \
        25 100 15 \
        "${FLATPAK_OPTIONS[@]}" \
        3>&1 1>&2 2>&3
    )"

    if [ $? -ne 0 ]; then
      y "Flatpak-Paketauswahl abgebrochen oder übersprungen."
      SELECTED_FLATPAK_REFS=""
    fi

    SELECTED_FLATPAK_REFS="$(printf "%s" "$SELECTED_FLATPAK_REFS" | tr -d '"')"
  else
    y "Keine Flatpak-Updates verfügbar."
  fi
else
  y "Flatpak ist nicht installiert. Flatpak-Updates werden übersprungen."
fi

# ------------------------------------------------------------
# Autoremove / Clean per Checkbox auswählen
# ------------------------------------------------------------

MAINTENANCE_CHOICES="$(
  whiptail \
    --title "Wartung auswählen" \
    --checklist "Mit LEERTASTE auswählen, was zusätzlich ausgeführt werden soll." \
    15 85 5 \
    "autoremove" "Nicht mehr benötigte APT-Pakete entfernen" "ON" \
    "clean" "APT-Cache bereinigen" "ON" \
    3>&1 1>&2 2>&3
)"

if [ $? -ne 0 ]; then
  y "Wartungsauswahl abgebrochen oder übersprungen."
  MAINTENANCE_CHOICES=""
fi

MAINTENANCE_CHOICES="$(printf "%s" "$MAINTENANCE_CHOICES" | tr -d '"')"

# ------------------------------------------------------------
# Zusammenfassung
# ------------------------------------------------------------

blank
g "==================================================="
g "Zusammenfassung"
g "==================================================="

if [ -n "$SELECTED_APT_PACKAGES" ]; then
  g "Ausgewählte APT-Pakete:"
  for pkg in $SELECTED_APT_PACKAGES; do
    g "  - $pkg"
  done
else
  y "Keine APT-Pakete ausgewählt."
fi

blank

if [ -n "$SELECTED_FLATPAK_REFS" ]; then
  g "Ausgewählte Flatpak-Pakete:"
  for ref in $SELECTED_FLATPAK_REFS; do
    g "  - $ref"
  done
else
  y "Keine Flatpak-Pakete ausgewählt."
fi

blank

if [ -n "$MAINTENANCE_CHOICES" ]; then
  g "Ausgewählte Wartung:"
  for action in $MAINTENANCE_CHOICES; do
    g "  - $action"
  done
else
  y "Keine Wartungsaktionen ausgewählt."
fi

blank

if [ -z "$SELECTED_APT_PACKAGES" ] &&
   [ -z "$SELECTED_FLATPAK_REFS" ] &&
   [ -z "$MAINTENANCE_CHOICES" ]; then
  y "Nichts ausgewählt. Beende Skript."
  exit 0
fi

if ! whiptail \
  --title "Bestätigung" \
  --yesno "Ausgewählte Updates und Wartungsaktionen jetzt ausführen?" \
  10 80; then
  y "Abgebrochen."
  exit 0
fi

# ------------------------------------------------------------
# APT-Updates installieren
# ------------------------------------------------------------

if [ -n "$SELECTED_APT_PACKAGES" ]; then
  blank
  g "Installiere ausgewählte APT-Updates..."

  for pkg in $SELECTED_APT_PACKAGES; do
    blank
    g "Aktualisiere APT-Paket: $pkg"

    if ! apt install --only-upgrade -y "$pkg"; then
      r "Fehler beim Aktualisieren von APT-Paket: $pkg"
    fi
  done
fi

# ------------------------------------------------------------
# Flatpak-Updates installieren
# ------------------------------------------------------------

if [ -n "$SELECTED_FLATPAK_REFS" ]; then
  blank
  g "Installiere ausgewählte Flatpak-Updates..."

  for ref in $SELECTED_FLATPAK_REFS; do
    blank
    g "Aktualisiere Flatpak-Paket: $ref"

    if ! flatpak update -y "$ref"; then
      r "Fehler beim Aktualisieren von Flatpak-Paket: $ref"
    fi
  done
fi

# ------------------------------------------------------------
# Wartung ausführen
# ------------------------------------------------------------

if selected_in_list "autoremove" "$MAINTENANCE_CHOICES"; then
  blank
  g "Entferne nicht mehr benötigte Pakete..."

  if ! apt autoremove -y; then
    r "APT autoremove ist fehlgeschlagen."
  fi
fi

if selected_in_list "clean" "$MAINTENANCE_CHOICES"; then
  blank
  g "Bereinige APT-Cache..."

  if ! apt clean; then
    r "APT clean ist fehlgeschlagen."
  fi
fi

blank
g "==================================================="
g "Update abgeschlossen."
g "==================================================="

# ------------------------------------------------------------
# Reboot-Check
# ------------------------------------------------------------

if [ -f /var/run/reboot-required ]; then
  blank
  y "Ein Neustart ist erforderlich."

  if whiptail \
    --title "Neustart erforderlich" \
    --yesno "Das System benötigt einen Neustart. Jetzt neu starten?" \
    10 70; then
    g "Starte System neu..."
    reboot
  else
    y "Neustart wurde übersprungen."
  fi
fi

exit 0
