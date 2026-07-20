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

Enhances the standard Battery Widget with intelligent runtime estimation.

### Features

- ✅ Time to Full while charging
- ✅ Remaining Runtime while discharging
- ✅ Runtime calculated to 20% State of Charge
- ✅ Low battery warning below 25%
- ✅ Uses live BMS values
- ✅ No background services
- ✅ No external scripts

Uses native Venus OS D-Bus battery information including:

- Battery Current
- State of Charge
- Installed Battery Capacity

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
wget https://raw.githubusercontent.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>/main/install.sh \
-O /data/gui-mod-manager.sh
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

# 🛣 Roadmap

Future modules planned include:

- GPS information
- Weather integration
- Generator enhancements
- Battery statistics
- System diagnostics
- Custom dashboard widgets
- Additional status bar modules

Suggestions are welcome.

---

# ⚠ Disclaimer

This project is an independent community enhancement for Victron Energy Venus OS GUI v2.

It is not affiliated with or endorsed by Victron Energy.

Always ensure your system is backed up before making modifications.

Use at your own risk.

---

# 🤝 Contributing

Bug reports, feature requests and pull requests are welcome.

If you create your own GUI modules, feel free to contribute them to the project.

---

# 📜 Credits

Created for the Victron Energy community.

Built using the open modification capabilities intentionally provided by the Venus OS GUI v2 architecture.

Special thanks to Victron Energy for making GUI v2 modifiable through Overlay-FS and QML.

---

⭐ If you find this project useful, consider giving the repository a star.
