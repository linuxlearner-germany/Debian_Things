# Debian Things

Praktische Skripte, Anleitungen und Hilfestellungen für Debian-basierte Systeme.

Dieses Repository sammelt nützliche Werkzeuge für Wartung, Updates, Shell-Produktivität und allgemeine Problemlösungen unter Debian. Aktuell enthält es unter anderem ein Update-Skript, einen Alias-Guide sowie weitere thematische Ordner wie `Medicat_mountproblem` und `TPM_ENCRYPTION`. :contentReference[oaicite:1]{index=1}

---

## Inhalt

- [Über das Projekt](#über-das-projekt)
- [Enthaltene Dateien und Ordner](#enthaltene-dateien-und-ordner)
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Verwendung](#verwendung)
- [Sicherheitshinweis](#sicherheitshinweis)
- [Mitwirken](#mitwirken)
- [Lizenz](#lizenz)

---

## Über das Projekt

**Debian Things** ist eine Sammlung von kleinen, praxisnahen Hilfsmitteln für den Alltag mit Debian und Debian-basierten Distributionen.  
Der Fokus liegt auf einfachen, nachvollziehbaren Lösungen für typische Aufgaben wie:

- Systemupdates
- Paketpflege
- Shell-Optimierung
- wiederkehrende Administrationsaufgaben
- technische Notizen und Lösungsansätze

Das Repository eignet sich besonders für Anwender, die ihre Debian-Umgebung effizienter verwalten möchten. :contentReference[oaicite:2]{index=2}

---

## Enthaltene Dateien und Ordner

### `Update.sh`
Ein Bash-Skript zur Automatisierung von Systemupdates.

**Funktionen:**
- Aktualisierung der Paketquellen
- Upgrade installierter Pakete
- optionales `full-upgrade`
- automatische Bereinigung mit `autoremove` und `clean`
- optionales Flatpak-Update
- optionale Installation von Hilfstools wie `needrestart`
- optionaler automatischer Neustart bei Bedarf
- Logging nach `/var/log` oder `/tmp`
- farbige Konsolenausgabe und Fehlerbehandlung :contentReference[oaicite:3]{index=3}

### `debian_alias_guide.md`
Anleitung zum Erstellen und dauerhaften Einrichten von Bash-Aliases unter Debian.

**Behandelte Themen:**
- Aliase in `.bashrc`
- Nutzung von `.bash_aliases`
- systemweite Aliase
- Testen und Aktivieren von Aliasen :contentReference[oaicite:4]{index=4}

### `Medicat_mountproblem`
Thematischer Ordner zu einem spezifischen Mount-Problem.

### `TPM_ENCRYPTION`
Thematischer Ordner rund um TPM bzw. Verschlüsselung.

> Hinweis: Die beiden Ordner sind im Repository sichtbar, ihr genauer Inhalt ist auf der Übersichtsseite jedoch nicht weiter beschrieben. :contentReference[oaicite:5]{index=5}

---

## Voraussetzungen

Für die Nutzung der Skripte und Anleitungen solltest du Folgendes mitbringen:

- Debian 12 / Debian 13 oder eine kompatible Debian-basierte Distribution
- Bash
- Root- bzw. `sudo`-Rechte für administrative Skripte
- Grundkenntnisse im Umgang mit dem Terminal :contentReference[oaicite:6]{index=6}

---

## Installation

Repository klonen:

```bash
git clone https://github.com/linuxlearner-germany/Debian_Things.git
cd Debian_Things
