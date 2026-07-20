# 🚀 Venus OS GUI v2 Mod Manager

A collection of custom modifications for **Victron Venus OS GUI v2**.

This installer provides a simple way to install, remove, and manage GUI enhancements while keeping the original Venus OS files safely backed up.

Compatible with Venus OS systems running **GUI v2**.

---

# ✨ Features

## 🔋 Battery Time Estimator

Adds additional battery information to the standard GUI v2 battery widget.

Features:

✅ Displays **Time to Full** while charging  
✅ Displays **Remaining Time** while discharging  
✅ Calculates remaining runtime down to **20% battery capacity**  
✅ Shows **WARNING** below 25% remaining capacity  
✅ Colour warnings:
- 🟠 Amber below 35%
- 🔴 Red below 30%

Uses the battery information already provided by the BMS:

- Current capacity (Ah)
- Installed capacity (Ah)
- Battery current

No additional services or drivers required.

---

## 🌡️ Live Sensor Status Bar

Adds additional live information to the Venus OS status bar.

Features:

✅ Internal temperature display  
✅ External temperature display  
✅ Fridge temperature display  
✅ Water tank level  
✅ Hot water temperature  
✅ Custom icons  
✅ Automatic dark/light theme icons

Uses native Venus OS D-Bus values.

---

## ⚡ AC Widget Enhancements

Adds additional AC information to the GUI widgets.

Features:

✅ Additional AC monitoring information  
✅ Uses native Venus OS data sources  
✅ No additional background services

---

# 🛠 Installation

SSH into your Venus OS device.

Download the installer:

```bash
wget https://raw.githubusercontent.com/YOUR-REPO/main/install.sh -O /data/gui-mod-manager.sh
