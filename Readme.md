# Debian_Things

Eine Sammlung kleiner **Tools, Skripte und Anleitungen für Debian-basierte Systeme**.

Dieses Repository enthält nützliche Hilfsmittel für **Systemwartung, Updates und Shell-Produktivität** unter Debian (z. B. Debian 12 / Debian 13).

---

# Inhalt

## 1. Automatisches Update-Script

Datei: `Update.sh`

Ein Bash-Script, das **Systemupdates auf Debian automatisiert**.

### Funktionen

* `apt-get update` und `apt upgrade`
* optionales **full-upgrade**
* automatisches Aufräumen (`autoremove`, `clean`)
* optionales **Flatpak-Update**
* optional Installation von **Helper-Tools (needrestart)**
* optional **automatischer Neustart**, wenn erforderlich
* ausführliches **Logging nach `/var/log` oder `/tmp`**
* Fehlerbehandlung und farbige Konsolenausgabe

### Beispiel

Normales Update:

```bash
sudo ./Update.sh
```

Vollständiges Upgrade:

```bash
sudo ./Update.sh --full
```

Flatpak-Apps aktualisieren:

```bash
sudo ./Update.sh --flatpak
```

Helper-Tools installieren:

```bash
sudo ./Update.sh --helpers
```

Automatischer Neustart wenn nötig:

```bash
sudo ./Update.sh --reboot
```

Hilfe anzeigen:

```bash
sudo ./Update.sh --help
```

Das Script führt Systemupdates und Bereinigungen automatisch aus und prüft anschließend, ob ein Neustart erforderlich ist. 

---

## 2. Debian Alias Guide

Datei: `debian_alias_guide.md`

Eine Anleitung, wie man **dauerhafte Bash-Aliase unter Debian erstellt**.

### Themen

* Benutzer-Aliase über `.bashrc`
* systemweite Aliase
* Verwendung von `.bash_aliases`
* Testen von Alias-Funktionen

### Beispiel

```bash
alias ll='ls -alF'
alias update='sudo apt update && sudo apt upgrade'
```

Nach dem Hinzufügen in `.bashrc` können die Änderungen mit folgendem Befehl aktiviert werden:

```bash
source ~/.bashrc
```

Dadurch lassen sich häufig verwendete Befehle schneller ausführen. 

---

# Voraussetzungen

* Debian 12 / Debian 13 oder kompatible Debian-basierte Distributionen
* Bash
* Root-Rechte für Update-Scripts

---

# Installation

Repository klonen:

```bash
git clone https://github.com/USERNAME/Debian_Things.git
cd Debian_Things
```

Script ausführbar machen:

```bash
chmod +x Update.sh
```

---

# Hinweis

Diese Scripts verändern Systempakete.
Bitte überprüfe die Scripts vor der Ausführung mit Root-Rechten.

---

# Lizenz

MIT-Lizenz (oder eine andere gewünschte Lizenz).

---

# Mitwirken

Verbesserungen und Pull Requests sind willkommen.

Mögliche Erweiterungen:

* weitere Debian-Hilfsskripte
* Tools für Systemwartung
* Shell-Produktivitäts-Tools
* zusätzliche Dokumentation
