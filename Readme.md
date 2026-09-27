# 🚀 Venus OS GUI v2 Mod Manager

A modular enhancement manager for **Victron Energy Venus OS GUI v2**.

The Mod Manager allows you to install, remove and manage custom GUI enhancements without permanently modifying your original Venus OS installation.

It automatically:

- Detects Overlay-FS installations
- Creates timestamped backups
- Installs only the selected modifications
- Allows each modification to be removed independently
- Restarts the GUI automatically when required

---

# ✨ Current Modules

## 🔋 Battery Time Estimator


Enhances the standard Venus OS Battery Widget with a live, calculated time estimate.

Features

* ✅ Time to Full while the battery is charging
* ✅ Remaining Runtime while the battery is discharging
* ✅ Runtime calculated down to 20% State of Charge
* ✅ Uses the battery’s live State of Charge and current
* ✅ Uses the configured battery capacity
* ✅ Automatically calculates the estimated time from the current battery conditions
* ✅ Displays the result directly in the standard Battery Widget
* ✅ No background services
* ✅ No external scripts

How It Works

The module adds the required Time to Go calculation directly to the native Venus OS battery data flow.

It uses the existing Venus OS D-Bus battery values for:

* Battery Current
* State of Charge (SOC)
* Installed Battery Capacity

The calculated value is then provided through the battery service’s:

/Dc/Battery/TimeToGo

This allows the standard Venus OS GUI to display the calculated battery time without requiring a separate application or background process.

---

## 🌡️ Live Sensor Status Bar

Adds live environmental information directly into the GUI v2 status bar.

### Features

- ✅ Internal temperature
- ✅ External temperature
- ✅ Fridge temperature
- ✅ Water tank level
- ✅ Hot water temperature
- ✅ Automatic light/dark theme icons
- ✅ Native Venus OS D-Bus integration

The installer automatically installs all required SVG icons into:

```
/data/custom-icons
```

These icons are automatically removed when the module is uninstalled.

No manual installation is required.

---

## ⚡ AC Widget Enhancements

Adds additional live AC information to the standard GUI widgets.

### Features

- ✅ Live Voltage
- ✅ Live Current
- ✅ Live Frequency
- ✅ Available on AC Input Widget
- ✅ Available on AC Loads Widget
- ✅ Uses native Venus OS D-Bus values

---

# 📂 Supported Install Locations

The installer automatically detects the correct GUI location.

Priority order:

### Overlay Filesystem

```
/data/apps/overlay-fs/data/gui-v2/upper
```

Recommended for persistent modifications.

---

### Standard Venus OS

```
/opt/victronenergy/gui-v2
```

Used automatically when Overlay-FS is unavailable.

No configuration is required.

---

# 🛠 Installation

SSH into your GX device.

Download the installer:

```bash
wget https://raw.githubusercontent.com/Sarah-1331/Gui_v2-Mod-Manager/main/install.sh \-O /data/gui-mod-manager.sh
```

Make it executable:

```bash
chmod +x /data/gui-mod-manager.sh
```

Run the installer:

```bash
/data/gui-mod-manager.sh
```

---

# 📋 Installer Menu

The installer automatically detects installed modules.

Example:

```
======================================
 Venus OS GUI v2 Mod Manager
 Version 1.1
======================================

Installed Mods

1) Battery Time Estimator        ✅ Installed
2) Live Sensor Status Bar        ❌ Not Installed
3) AC Widget Enhancements        ✅ Installed

--------------------------------------

4) Install All
5) Remove All
6) Exit
```

Selecting an installed module removes it.

Selecting a missing module installs it.

---

# 💾 Automatic Backup System

Before any modification is applied, a timestamped backup is created.

Example:

```
BatteryWidget.qml.bak-battery-20260720-183000

StatusBar.qml.bak-sensors-20260720-183010

AcInputWidget.qml.bak-ac-20260720-183020
```

Backups are stored alongside the original files.

Your original GUI files are never modified without first creating a backup.

---

# 🔄 Removing Mods

Each module can be removed independently.

Removing a module will:

- Restore the latest backup
- Remove any associated resources (such as SVG icons)
- Restart the GUI

No manual cleanup is required.

---

# 🔁 Venus OS Updates

After a Venus OS update, modified GUI files may be replaced.

If this happens simply run:

```
/data/gui-mod-manager.sh
```

and reinstall the desired modules.

The installer will automatically create new backups before applying any modifications.

---

# 📸 Screenshots

Coming soon.

- Battery Widget
- Live Sensor Status Bar
- AC Widget Enhancements


---

