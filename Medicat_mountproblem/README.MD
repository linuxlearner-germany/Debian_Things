# 🛠 Fix: NTFS USB (Medicat) lässt sich nicht mounten

## 📌 Analyse

👉 `/dev/sda1` ist **NTFS** (Label: Medicat)  
👉 Das Problem liegt **nicht am falschen Dateisystem**, sondern sehr wahrscheinlich an:

- **"dirty NTFS"**
- unsauber entferntem USB-Stick
- **Windows Hibernation / Fast Startup**

➡️ Das ist ein typischer Fehler bei solchen Sticks.

---

## 🔧 Lösung

Führe folgende Befehle aus:

```bash
sudo apt update
sudo apt install ntfs-3g
sudo ntfsfix /dev/sda1

## 📂 Danach mounten mit

```bash
sudo mkdir -p /mnt/medicat
sudo mount -t ntfs-3g /dev/sda1 /mnt/medicat
