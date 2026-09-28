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

Enhances the standard Venus OS Battery Widget with a live, calculated battery time estimate.

### ✨ Features

* 🔋 **Uses the BMS's own Time to Go (TTG) when available**
* 🧮 **Automatically calculates TTG when the BMS does not provide one**
* ⚡ **Charging → estimates time remaining until 100%**
* 🔻 **Discharging → estimates remaining runtime down to 20% State of Charge**
* 📊 **Uses the battery's live State of Charge (SOC) and current**
* 🔋 **Uses the configured Installed Battery Capacity**
* ⏳ **Final 5 Ah of charging → TTG automatically disappears**
* 🚫 **Missing capacity, installed capacity or current data → TTG remains unavailable rather than displaying an incorrect estimate**
* 🔄 **No extra service or background process required**
* 🖥️ **Displays the result directly through the standard Venus OS Battery Widget**

### ⚙️ How It Works

The module adds the required Time to Go calculation directly to the native Venus OS battery data flow.

It first checks whether the selected BMS or battery service already provides:

`/TimeToGo`

If a value is available, the module **uses the BMS's own TTG unchanged**.

If the BMS does not provide a TTG value, the module automatically calculates one using the existing Venus OS D-Bus battery values for:

* 🔋 Battery Current
* 📊 State of Charge (SOC)
* 🔋 Installed Battery Capacity

### ⚡ Charging

When the battery is charging, the module calculates the estimated time remaining until the battery reaches **100%**.

Once the battery is within the final **5 Ah** of its configured capacity, the TTG value is set to zero so that the standard Venus OS Battery Widget naturally stops displaying the time estimate.

### 🔻 Discharging

When the battery is discharging, the module calculates the estimated remaining runtime until the battery reaches **20% SOC**.

This provides a more practical usable-runtime estimate rather than calculating all the way down to 0%.

### 🚫 Missing Data

If the BMS does not provide TTG and the required battery information is unavailable — such as missing capacity, installed capacity or current — the module does **not** attempt to guess the remaining time.

Instead, TTG remains unavailable and the standard Venus OS GUI treats it as **not reported**.

### 📡 Venus OS D-Bus

The calculated value is provided through:

`/Dc/Battery/TimeToGo`

This allows the standard Venus OS GUI to display the calculated battery time without requiring a separate application, external script or background service.


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

