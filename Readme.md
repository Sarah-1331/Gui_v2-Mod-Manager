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


Make it executable:

chmod +x /data/gui-mod-manager.sh

Run:

bash /data/gui-mod-manager.sh
📋 Installer Menu

The installer will show:

================================
 Venus OS GUI v2 Mod Manager
================================

Installed Mods:

🔋 Battery Time Estimator     ❌ Not Installed
🌡️ Live Sensors               ✅ Installed
⚡ AC Widget                  ❌ Not Installed


Options:

1) Battery Time
2) Live Sensors
3) AC Widget
4) Install All Mods
5) Restore All Mods
6) Exit

Simply select the required option.

💾 Backup System

Before changing any Venus OS files, the installer creates a timestamped backup.

Example:

BatteryWidget.qml.bak-20260720-183000
StatusBar.qml.bak-20260720-183005

Backups are stored next to the original files.

Your original Venus OS files are never overwritten without a backup.

🔄 Restore

To restore a modification:

Run the installer again and select:

Restore Mod

The installer will:

✅ Locate the latest backup
✅ Restore the original QML file
✅ Restart the GUI

🖥 Overlay-fs Support

The installer automatically detects Venus OS overlay-fs.

If overlay-fs is available:

/data/apps/overlay-fs/data/gui-v2/upper

the modification is installed there.

This prevents changes being lost during normal operation and keeps the factory system files untouched.

If overlay-fs is not available, the installer safely modifies the normal GUI location:

/opt/victronenergy/gui-v2
🔁 After Venus OS Updates

A Venus OS update may replace GUI files.

If your modifications disappear:

Run the Mod Manager again.
Select reinstall.

The installer will:

🔍 Check installed mods
💾 Create fresh backups
🔧 Reapply modifications

⚠️ Disclaimer

These modifications are community-developed enhancements for Venus OS GUI v2.

Always keep a backup of your system before applying modifications.

Tested on Venus OS GUI v2.

📜 Credits

Created for the Venus OS community.

Built using the open modification capabilities provided by Victron Venus OS GUI v2.

Enjoy your customised Venus OS experience! ⚡🔋🌞


I would also add a small screenshot section later:

```markdown
# 📸 Screenshots

Coming soon...

Built using the open modification capabilities provided by Victron Venus OS GUI v2.

Enjoy your customised Venus OS experience! ⚡🔋🌞
