# TPM Auto-Unlock für LUKS (Debian / Linux)

Diese Anleitung beschreibt, wie man eine **LUKS-verschlüsselte Systemplatte automatisch über TPM2 entsperren** lässt und wie man das **nach einem BIOS/UEFI-Update wiederherstellt**.

Getestet mit:

* Debian 12 / Debian 13
* LUKS2 + LVM Installation
* NVMe SSD
* TPM 2.0

---

# Überblick

Mit TPM-Auto-Unlock:

* 🔓 System bootet **ohne manuelle Passphrase**
* 🔐 Verschlüsselung bleibt aktiv
* 🛟 Passphrase bleibt als **Fallback**

TPM speichert einen Schlüssel, der nur freigegeben wird, wenn die gemessene Systemumgebung (Firmware, Bootzustand) passt.

---

# Voraussetzungen

Installierte Tools:

```
systemd
cryptsetup
```

Optional:

```
tpm2-tools
```

TPM prüfen:

```bash
ls /dev/tpm*
```

Erwartete Ausgabe:

```
/dev/tpm0
/dev/tpmrm0
```

Falls nichts erscheint:

1. BIOS/UEFI öffnen
2. TPM aktivieren
3. TPM Version **2.0** auswählen

---

# LUKS-Partition ermitteln

```bash
lsblk -f | grep crypto_LUKS
```

Beispiel:

```
nvme0n1p3 crypto_LUKS
```

Das LUKS Device lautet dann:

```
/dev/nvme0n1p3
```

---

# TPM Auto-Unlock einrichten

TPM-Schlüssel im LUKS Header speichern:

```bash
sudo systemd-cryptenroll /dev/nvme0n1p3 --tpm2-device=auto
```

Danach:

* einmal **LUKS-Passphrase eingeben**
* ein neuer TPM-Keyslot wird erstellt

---

# Initramfs aktualisieren

Damit TPM beim Boot verwendet wird:

```bash
sudo update-initramfs -u
```

---

# Funktion testen

System neu starten:

```bash
reboot
```

Erwartetes Verhalten:

* keine Passphrase beim Boot
* System startet direkt

Falls TPM nicht funktioniert, wird automatisch die **Passphrase abgefragt**.

---

# TPM Slot prüfen

```bash
sudo cryptsetup luksDump /dev/nvme0n1p3
```

Du solltest einen Slot sehen mit:

```
systemd-tpm2
```

---

# BIOS / UEFI Update Problem

Nach einem BIOS-Update kann TPM-Auto-Unlock aufhören zu funktionieren.

Symptom:

```
System fragt wieder nach der LUKS Passphrase
```

Grund:

TPM verwendet **PCR-Messwerte**.
Ein BIOS-Update verändert diese Werte.

Das ist **normal und erwartet**.

---

# TPM Schlüssel nach BIOS Update erneuern

1. System normal booten
2. Passphrase eingeben

Dann:

```bash
sudo systemd-cryptenroll /dev/nvme0n1p3 --tpm2-device=auto
```

---

# Initramfs neu erzeugen

```bash
sudo update-initramfs -u
```

---

# Neustarten

```bash
reboot
```

TPM-Auto-Unlock funktioniert jetzt wieder.

---

# Alte TPM Slots entfernen (optional)

BIOS Updates können mehrere TPM Slots erzeugen.

Slots anzeigen:

```bash
sudo cryptsetup luksDump /dev/nvme0n1p3
```

Slot löschen:

```bash
sudo cryptsetup luksKillSlot /dev/nvme0n1p3 SLOTNUMMER
```

⚠️ Wichtig:

* niemals den **Passphrase-Slot löschen**

---

# Sicherheitshinweise

TPM Auto-Unlock bedeutet:

* System kann ohne Passwort booten
* Schutz basiert auf Hardware-Zustand

Empfehlungen:

* Passphrase immer behalten
* Secure Boot aktiv lassen
* regelmäßige Backups erstellen

---

# Schnellübersicht

Einrichtung:

```
systemd-cryptenroll
update-initramfs
reboot
```

Nach BIOS Update:

```
systemd-cryptenroll
update-initramfs
reboot
```

---

# Lizenz

Diese Anleitung kann frei verwendet und angepasst werden.
