#!/bin/bash
#
# Venus OS GUI v2 Mod Manager
# Battery / Sensor / AC Enhancements
#
# Version 1.1
#

set -e

MOD_VERSION="1.1"

ORIG_GUI="/opt/victronenergy/gui-v2"
OVERLAY="/data/apps/overlay-fs/data/gui-v2/upper"

NEED_RESTART=0

# ============================================================
# Custom Status Bar Icons
# ============================================================

ICON_DIR="/data/custom-icons"

write_svg()
{
    cat > "$ICON_DIR/$1" <<EOF
$2
EOF
}

install_sensor_icons()
{
    echo "Installing custom status bar icons..."

    mkdir -p "$ICON_DIR"

    # White icons
    write_svg temp.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11L12 3l9 8"/><path d="M5 10v10h14V10"/><path d="M9 21V13h6v8"/></svg>'

    write_svg external.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'

    write_svg snowflake.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><g transform="translate(12,12)"><g id="arm"><line x1="0" y1="-10" x2="0" y2="0"/><line x1="-2" y1="-8" x2="0" y2="-10"/><line x1="2" y1="-8" x2="0" y2="-10"/></g><use href="#arm" transform="rotate(60)"/><use href="#arm" transform="rotate(120)"/><use href="#arm" transform="rotate(180)"/><use href="#arm" transform="rotate(240)"/><use href="#arm" transform="rotate(300)"/></g></svg>'

    write_svg water.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

    # Black icons
    write_svg tempB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11L12 3l9 8"/><path d="M5 10v10h14V10"/><path d="M9 21V13h6v8"/></svg>'

    write_svg externalB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'

    write_svg snowflakeB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><g transform="translate(12,12)"><g id="arm"><line x1="0" y1="-10" x2="0" y2="0"/><line x1="-2" y1="-8" x2="0" y2="-10"/><line x1="2" y1="-8" x2="0" y2="-10"/></g><use href="#arm" transform="rotate(60)"/><use href="#arm" transform="rotate(120)"/><use href="#arm" transform="rotate(180)"/><use href="#arm" transform="rotate(240)"/><use href="#arm" transform="rotate(300)"/></g></svg>'

    write_svg waterB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

    echo "Custom icons installed."
}

remove_sensor_icons()
{
    echo "Removing custom status bar icons..."

    rm -f "$ICON_DIR"/temp*.svg \
          "$ICON_DIR"/external*.svg \
          "$ICON_DIR"/snowflake*.svg \
          "$ICON_DIR"/water*.svg

    rmdir "$ICON_DIR" 2>/dev/null || true
}


# ============================================================
# Detect GUI location
# ============================================================

if [ -d "$OVERLAY" ]; then
    GUI_ROOT="$OVERLAY"
    echo "✅ Overlay-fs detected"
else
    GUI_ROOT="$ORIG_GUI"
    echo "⚠ No overlay detected"
fi


COMPONENTS="$GUI_ROOT/Victron/VenusOS/components"
WIDGETS="$COMPONENTS/widgets"


STATUSBAR="$COMPONENTS/StatusBar.qml"

BATTERY="$WIDGETS/BatteryWidget.qml"

ACINPUT="$WIDGETS/AcInputWidget.qml"
ACLOADS="$WIDGETS/AcLoadsWidget.qml"


echo
echo "======================================"
echo " Venus OS GUI v2 Mod Manager"
echo " Version $MOD_VERSION"
echo "======================================"
echo

# ============================================================
# Verify files exist
# ============================================================

for FILE in "$STATUSBAR" "$BATTERY" "$ACINPUT" "$ACLOADS"
do
    if [ ! -f "$FILE" ]; then
        echo "❌ Missing file:"
        echo "$FILE"
        exit 1
    fi
done

echo "✅ GUI files located"







# ============================================================
# Backup function
# ============================================================

backup_file()
{
    FILE="$1"
    NAME="$2"

    if [ -f "$FILE" ]; then

        BACKUP="$FILE.bak-$NAME-$(date +%Y%m%d-%H%M%S)"

        cp "$FILE" "$BACKUP"

        echo "Backup:"
        echo "$BACKUP"

    else
        echo "⚠ File not found:"
        echo "$FILE"
    fi
}


# ============================================================
# Restore latest backup
# ============================================================

restore_file()
{
    FILE="$1"
    NAME="$2"

    BACKUP=$(ls -t "$FILE.bak-$NAME-"* 2>/dev/null | head -n1 || true)

    if [ -f "$BACKUP" ]; then

        cp "$BACKUP" "$FILE"

        echo "Restored:"
        echo "$FILE"

        NEED_RESTART=1

    else

        echo "⚠ No backup found for:"
        echo "$FILE"

    fi
}



# ============================================================
# Mod detection
# ============================================================

battery_installed()
{
    grep -q "VENUS_MOD_BATTERY_TIME" "$BATTERY" 2>/dev/null
}


sensors_installed()
{
    grep -q "VENUS_MOD_SENSOR_STATUS" "$STATUSBAR" 2>/dev/null
}


ac_input_installed()
{
    grep -q "VENUS_MOD_AC_INPUT" "$ACINPUT" 2>/dev/null
}


ac_loads_installed()
{
    grep -q "VENUS_MOD_AC_LOADS" "$ACLOADS" 2>/dev/null
}



# ============================================================
# Battery Time Estimator
# ============================================================

install_battery()
{

echo "Installing Battery Time Estimator"


if battery_installed; then

    echo "Battery mod already installed"
    return

fi


backup_file "$BATTERY" "battery"


cd "$WIDGETS"


patch -N --forward BatteryWidget.qml <<'PATCH'

--- BatteryWidget.qml
+++ BatteryWidget.qml

@@ -40,7 +40,8 @@

 	readonly property var batteryData: Global.system.battery
+	// VENUS_MOD_BATTERY_TIME
+	readonly property real batterySoc: batteryData.stateOfCharge || 0


@@ -75,6 +76,11 @@

 	VeQuickItem {
 		id: remoteGeneratorSelected

 		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/RemoteGeneratorSelected" : ""
 	}

+	VeQuickItem {
+		id: batteryCapacity
+		uid: "dbus/com.victronenergy.battery.socketcan_vecan0/Capacity"
+	}


@@ -220,9 +226,46 @@

 			Label {

-				text: Global.system.battery.timeToGo == 0 ? "" : Utils.secondsToString(Global.system.battery.timeToGo)
-				visible: Global.system.battery.timeToGo

+				text: {
+
+					const capAh = batteryCapacity.value;
+					const current = batteryData.current;
+					const soc = batteryData.stateOfCharge;
+
+					if (current > 0.1) {
+
+						if (soc >= 99)
+							return "Finishing charge";
+
+						const remainingAh = capAh * (100 - soc) / 100;
+						const hours = remainingAh / current;
+
+						return "Time to full " + Utils.secondsToString(hours * 3600);
+					}
+
+					if (current < -0.1) {
+
+						if (soc <= 25)
+							return "WARNING";
+
+						const usableAh = capAh * (soc - 20) / 100;
+						const hours = usableAh / Math.abs(current);
+
+						return "Remaining " + Utils.secondsToString(hours * 3600);
+					}
+
+					return "";
+				}
+
+				visible: true

 				color: Theme.color_font_primary

PATCH


NEED_RESTART=1

echo "Battery installed"

}



remove_battery()
{

echo "Removing Battery Time Estimator"

restore_file "$BATTERY" "battery"

}
# ============================================================
# Live Sensor Status Bar Mod
# ============================================================

install_sensors()
{

echo "Installing Live Sensor Status Bar"


if sensors_installed; then

    echo "Sensor mod already installed"
    return

fi


backup_file "$STATUSBAR" "sensors"

install_sensor_icons


cd "$COMPONENTS"


patch -N --forward StatusBar.qml <<'PATCH'

--- StatusBar.qml
+++ StatusBar.qml

@@ -185,6 +185,150 @@
 	Label {
 		id: clockLabel
 		anchors.centerIn: parent
 		font.pixelSize: 22
 		visible: !breadcrumbs.visible
 		text: ClockTime.currentTime
 	}

+	// VENUS_MOD_SENSOR_STATUS
+
+	// === Custom Live Sensor Row with Icons (Final) ===
+
+	Row {
+		id: liveSensorRow
+		spacing: 16
+		anchors.verticalCenter: parent.verticalCenter
+		anchors.right: clockLabel.left
+		anchors.rightMargin: 20
+		visible: true
+		opacity: !breadcrumbs.visible ? 1 : 0
+
+		Behavior on opacity {
+			enabled: root.animationEnabled
+			OpacityAnimator {
+				duration: Theme.animation_page_idleOpacity_duration
+			}
+		}
+
+		VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }
+		VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }
+		VeQuickItem { id: fridgeTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }
+		VeQuickItem { id: hotWaterTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_0/Temperature" }
+		VeQuickItem { id: waterLevel; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level" }
+		VeQuickItem { id: waterCapacity; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity" }
+		VeQuickItem { id: themeMode; uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme" }
+
+		Row {
+			spacing: 4
+
+			Image {
+				width: 20
+				height: 20
+				fillMode: Image.PreserveAspectFit
+				source: themeMode.value === 1
+					? "file:///data/custom-icons/tempB.svg"
+					: "file:///data/custom-icons/temp.svg"
+			}
+
+			Label {
+				text: internalTemp.valid ? internalTemp.value.toFixed(1) + "°C" : "--.-°C"
+				font.bold: true
+				font.pixelSize: 18
+			}
+		}
+
+		Row {
+			spacing: 4
+
+			Image {
+				width: 20
+				height: 20
+				fillMode: Image.PreserveAspectFit
+				source: themeMode.value === 1
+					? "file:///data/custom-icons/externalB.svg"
+					: "file:///data/custom-icons/external.svg"
+			}
+
+			Label {
+				text: externalTemp.valid ? externalTemp.value.toFixed(1) + "°C" : "--.-°C"
+				font.bold: true
+				font.pixelSize: 18
+			}
+		}
+
+		Row {
+			spacing: 4
+
+			Image {
+				width: 20
+				height: 20
+				fillMode: Image.PreserveAspectFit
+				source: themeMode.value === 1
+					? "file:///data/custom-icons/snowflakeB.svg"
+					: "file:///data/custom-icons/snowflake.svg"
+			}
+
+			Label {
+				text: fridgeTemp.valid ? fridgeTemp.value.toFixed(1) + "°C" : "--.-°C"
+				font.bold: true
+				font.pixelSize: 18
+			}
+		}
+	}
+
+	Row {
+		id: water
+		spacing: 4
+		anchors.verticalCenter: parent.verticalCenter
+		anchors.left: alarmButton.visible && alarmButton.enabled
+				? alarmButton.right
+				: notificationButton.visible
+					? notificationButton.right
+					: connectivityRow.right
+		anchors.leftMargin: 20
+		visible: true
+		opacity: !breadcrumbs.visible ? 1 : 0
+
+		Behavior on opacity {
+			enabled: root.animationEnabled
+			OpacityAnimator {
+				duration: Theme.animation_page_idleOpacity_duration
+			}
+		}
+
+		Image {
+			width: 20
+			height: 20
+			fillMode: Image.PreserveAspectFit
+			source: themeMode.value === 1
+				? "file:///data/custom-icons/waterB.svg"
+				: "file:///data/custom-icons/water.svg"
+		}
+
+		Label {
+			text:
+				(waterLevel.valid
+					? (waterCapacity.valid
+						? ((waterLevel.value / 100.0) * waterCapacity.value * 1000).toFixed(0) + "L"
+						: waterLevel.value.toFixed(0) + "%")
+					: "")
+				+ (hotWaterTemp.valid
+					? (waterLevel.valid ? "  " : "") + hotWaterTemp.value.toFixed(1) + "°C"
+					: "")
+
+			font.bold: true
+			font.pixelSize: 18
+		}
+	}
+
+	// === End Custom Live Sensor Row ===

PATCH


NEED_RESTART=1

echo "Sensors installed"

}



remove_sensors()
{

echo "Removing Live Sensor Status Bar"

restore_file "$STATUSBAR" "sensors"

remove_sensor_icons

}
# ============================================================
# AC Widget Enhancements
# ============================================================


install_ac()
{

echo "Installing AC Widget Enhancements"


# ----------------------------
# AC Input Widget
# ----------------------------

if ac_input_installed; then

	echo "AC Input mod already installed"

else

	backup_file "$ACINPUT" "ac"

	cd "$WIDGETS"


	patch -N --forward AcInputWidget.qml <<'PATCH'

--- AcInputWidget.qml
+++ AcInputWidget.qml

@@ -25,6 +25,47 @@
 	extraContentLoader.sourceComponent: ThreePhaseDisplay {
 		width: parent.width
 		model: root.input.phases
 		widgetSize: root.size
 		inputMode: true
 	}

+	// VENUS_MOD_AC_INPUT
+
+	VeQuickItem {
+		id: acCurrent
+		uid: "dbus/com.victronenergy.system/Ac/Grid/L1/Current"
+	}
+
+	VeQuickItem {
+		id: acVoltage
+		uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/V"
+	}
+
+	VeQuickItem {
+		id: acFrequency
+		uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/F"
+	}
+
+	Item {
+		anchors.fill: parent
+		z: 999
+
+		Label {
+			text:
+				(acVoltage.valid ? acVoltage.value.toFixed(0) + " V" : "--- V") + "  " +
+				(acCurrent.valid ? acCurrent.value.toFixed(1) + " A" : "--.- A") + "  " +
+				(acFrequency.valid ? acFrequency.value.toFixed(1) + " Hz" : "--.- Hz")
+
+			font.pixelSize: 16
+			color: Theme.color_font_primary
+
+			anchors {
+				horizontalCenter: parent.horizontalCenter
+				bottom: parent.bottom
+				bottomMargin: Theme.geometry_baseline_spacing
+			}
+
+			visible: root.inputOperational &&
+			         root.input &&
+			         root.input.connected
+		}
+	}

PATCH


	echo "AC Input installed"

fi



# ----------------------------
# AC Loads Widget
# ----------------------------


if ac_loads_installed; then

	echo "AC Loads mod already installed"

else

	backup_file "$ACLOADS" "ac"

	cd "$WIDGETS"


	patch -N --forward AcLoadsWidget.qml <<'PATCH'

--- AcLoadsWidget.qml
+++ AcLoadsWidget.qml

@@ -20,6 +20,47 @@
 	type: VenusOS.OverviewWidget_Type_AcLoads
 	quantityLabel.dataObject: root.measurements
 	phaseCount: root.measurements.phases.count

+	// VENUS_MOD_AC_LOADS
+
+	VeQuickItem {
+		id: acVoltage
+		uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/V"
+	}
+
+	VeQuickItem {
+		id: acCurrent
+		uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/I"
+	}
+
+	VeQuickItem {
+		id: acFrequency
+		uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/F"
+	}
+
+	Label {
+		text:
+			(acVoltage.valid ? acVoltage.value.toFixed(0) + " V" : "--- V") + "  " +
+			(acCurrent.valid ? acCurrent.value.toFixed(1) + " A" : "--.- A") + "  " +
+			(acFrequency.valid ? acFrequency.value.toFixed(1) + " Hz" : "--.- Hz")
+
+		font.pixelSize: 18
+		color: Theme.color_font_primary
+
+		anchors {
+			bottom: parent.bottom
+			horizontalCenter: parent.horizontalCenter
+			bottomMargin: Theme.geometry_baseline_spacing
+		}
+
+		visible: root.size >= VenusOS.OverviewWidget_Size_L &&
+		         acVoltage.valid &&
+		         acVoltage.value >= 10
+	}

PATCH


	echo "AC Loads installed"

fi


NEED_RESTART=1

echo "AC enhancements complete"

}



# ============================================================
# Remove AC Enhancements
# ============================================================


remove_ac()
{

echo "Removing AC Widget Enhancements"


restore_file "$ACINPUT" "ac"

restore_file "$ACLOADS" "ac"


}
# ============================================================
# Status Display
# ============================================================


echo "Installed Mods:"
echo


if battery_installed; then
	echo "1) Battery Time Estimator        ✅ Installed"
else
	echo "1) Battery Time Estimator        ❌ Not Installed"
fi


if sensors_installed; then
	echo "2) Live Sensor Status Bar        ✅ Installed"
else
	echo "2) Live Sensor Status Bar        ❌ Not Installed"
fi


if ac_input_installed || ac_loads_installed; then
	echo "3) AC Widget Enhancements        ✅ Installed"
else
	echo "3) AC Widget Enhancements        ❌ Not Installed"
fi


echo
echo "--------------------------------------"
echo "4) Install All"
echo "5) Remove All"
echo "6) Exit"
echo


read -p "Select: " OPTION



case "$OPTION" in


1)

	if battery_installed; then

		remove_battery

	else

		install_battery

	fi

;;


2)

	if sensors_installed; then

		remove_sensors

	else

		install_sensors

	fi

;;


3)

	if ac_input_installed || ac_loads_installed; then

		remove_ac

	else

		install_ac

	fi

;;


4)

	echo
	echo "Installing all mods..."
	echo

	install_battery
	install_sensors
	install_ac

;;


5)

	echo
	echo "Removing all mods..."
	echo

	remove_battery
	remove_sensors
	remove_ac

;;


6)

	echo "Exit"
	exit 0

;;


*)

	echo "Invalid option"

;;

esac



# ============================================================
# Restart GUI once
# ============================================================


if [ "$NEED_RESTART" = "1" ]; then

	echo
	echo "Restarting Venus GUI..."

	sleep 2

	svc -t /service/start-gui

fi



echo
echo "======================================"
echo "✅ Venus GUI Mods Complete"
echo "======================================"
