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
NEED_SYSTEMCALC_RESTART=0

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


STATUSBAR_LANDSCAPE="$COMPONENTS/StatusBar_Landscape.qml"

SYSTEMCALC="/opt/victronenergy/dbus-systemcalc-py/dbus_systemcalc.py"

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

for FILE in "$STATUSBAR_LANDSCAPE" "$SYSTEMCALC" "$ACINPUT" "$ACLOADS"
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

        echo "Removing backup:"
        echo "$BACKUP"

        rm -f "$BACKUP"

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
    compgen -G "$SYSTEMCALC.bak-ttg-*" > /dev/null
}


sensors_installed()
{
    compgen -G "$STATUSBAR_LANDSCAPE.bak-sensors-*" > /dev/null
}


ac_input_installed()
{
    compgen -G "$ACINPUT.bak-ac-*" > /dev/null
}


ac_loads_installed()
{
    compgen -G "$ACLOADS.bak-ac-*" > /dev/null
}



# ============================================================
# Battery Time Estimator
# ============================================================

install_battery()
{
    if battery_installed; then
        echo
        echo "⚠ Battery Time Estimator is already installed."
        echo
        return 1
    fi

    echo
    echo "Installing Battery Time Estimator..."
    echo

    backup_file "$SYSTEMCALC" "ttg"

    python3 - "$SYSTEMCALC" <<'PY'
import sys

file = sys.argv[1]

with open(file, "r") as f:
    data = f.read()

old = "\t\t\tnewvalues['/Dc/Battery/TimeToGo'] = self._dbusmonitor.get_value(self._batteryservice,'/TimeToGo')"

new = """\t\t\tttg = 0
\t\t\tcapacity = self._dbusmonitor.get_value(self._batteryservice, '/Capacity')
\t\t\tinstalled = self._dbusmonitor.get_value(self._batteryservice, '/InstalledCapacity')
\t\t\tcurrent = self._dbusmonitor.get_value(self._batteryservice, '/Dc/0/Current')

\t\t\tif capacity is not None and installed is not None and current is not None and current > 0.1:
\t\t\t\tttg = max(0, (capacity - installed * 0.20) / current * 3600)

\t\t\tnewvalues['/Dc/Battery/TimeToGo'] = ttg"""

if old not in data:
    print("❌ Could not find original TimeToGo line")
    sys.exit(1)

data = data.replace(old, new, 1)

with open(file, "w") as f:
    f.write(data)

print("✅ Battery Time Estimator code installed")
PY

    python3 -c "compile(open('$SYSTEMCALC').read(), '$SYSTEMCALC', 'exec')"

    echo "✅ Systemcalc syntax OK"

    NEED_SYSTEMCALC_RESTART=1
}


remove_battery()
{
    echo
    echo "Removing Battery Time Estimator..."
    echo

    restore_file "$SYSTEMCALC" "ttg"

    NEED_SYSTEMCALC_RESTART=1
}

# ============================================================
# Live Sensor Status Bar Mod
# ============================================================

install_sensors()
{
    if sensors_installed; then

        echo
        echo "⚠ Sensor mod backup detected!"
        echo "A previous modification exists."
        echo "Restore the original before installing again."
        echo

        return 1
    fi

    echo "Installing Live Sensor Status Bar"

    backup_file "$STATUSBAR_LANDSCAPE" "sensors"

    install_sensor_icons

    python3 - "$STATUSBAR_LANDSCAPE" <<'PY'
import sys

file = sys.argv[1]

with open(file, "r") as f:
    data = f.read()

marker = '''\tLabel {
\t\tid: clockLabel
\t\tanchors.centerIn: parent
\t\tfont.pixelSize: Theme.font_size_body2
\t\tvisible: !breadcrumbs.visible
\t\ttext: ClockTime.currentTime
\t}

\tRow {
\t\tid: connectivityRow
'''

if marker not in data:
    print("❌ Could not find StatusBar_Landscape insertion point")
    sys.exit(1)

custom = r'''	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: Theme.font_size_body2
		visible: !breadcrumbs.visible
		text: ClockTime.currentTime
	}

// === Custom Live Sensor Row with Icons (Final) ===

	Row {
		id: liveSensorRow
		spacing: 16
		anchors.verticalCenter: parent.verticalCenter
		anchors.right: clockLabel.left
		anchors.rightMargin: 20
		visible: true
		opacity: !breadcrumbs.visible ? 1 : 0

		Behavior on opacity {
			enabled: Global.animationEnabled
			OpacityAnimator {
				duration: Theme.animation_page_idleOpacity_duration
			}
		}

		VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }
		VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }
		VeQuickItem { id: fridgeTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }
		VeQuickItem { id: hotWaterTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_0/Temperature" }
		VeQuickItem { id: waterRemaining; uid: "dbus/com.victronenergy.tank.mopeka_df4fd70d0f62/Remaining" }
		VeQuickItem { id: themeMode; uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme" }

		Row {
			spacing: 4

			Image {
				width: 20
				height: 20
				fillMode: Image.PreserveAspectFit
				source: themeMode.value === 1
					? "file:///data/custom-icons/tempB.svg"
					: "file:///data/custom-icons/temp.svg"
			}

			Label {
				text: internalTemp.valid
					? internalTemp.value.toFixed(1) + "°C"
					: "--.-°C"
				font.bold: true
				font.pixelSize: 18
			}
		}

		Row {
			spacing: 4

			Image {
				width: 20
				height: 20
				fillMode: Image.PreserveAspectFit
				source: themeMode.value === 1
					? "file:///data/custom-icons/externalB.svg"
					: "file:///data/custom-icons/external.svg"
			}

			Label {
				text: externalTemp.valid
					? externalTemp.value.toFixed(1) + "°C"
					: "--.-°C"
				font.bold: true
				font.pixelSize: 18
			}
		}

		Row {
			spacing: 4

			Image {
				width: 20
				height: 20
				fillMode: Image.PreserveAspectFit
				source: themeMode.value === 1
					? "file:///data/custom-icons/snowflakeB.svg"
					: "file:///data/custom-icons/snowflake.svg"
			}

			Label {
				text: fridgeTemp.valid
					? fridgeTemp.value.toFixed(1) + "°C"
					: "--.-°C"
				font.bold: true
				font.pixelSize: 18
			}
		}
	}

	Row {
		id: water
		spacing: 4
		anchors.verticalCenter: parent.verticalCenter

		anchors.left: alarmButton.visible && alarmButton.enabled
			? alarmButton.right
			: notificationButton.visible
				? notificationButton.right
				: connectivityRow.right

		anchors.leftMargin: 20

		visible: true
		opacity: !breadcrumbs.visible ? 1 : 0

		Behavior on opacity {
			enabled: Global.animationEnabled

			OpacityAnimator {
				duration: Theme.animation_page_idleOpacity_duration
			}
		}

		Row {
			spacing: 4

			Image {
				width: 20
				height: 20
				fillMode: Image.PreserveAspectFit
				source: themeMode.value === 1
					? "file:///data/custom-icons/waterB.svg"
					: "file:///data/custom-icons/water.svg"
			}

			Label {
				text: waterRemaining.valid
					? (waterRemaining.value * 1000).toFixed(0) + "L"
					: ""
				font.bold: true
				font.pixelSize: 18
			}
		}
	}

// === End Custom Live Sensor Row ===

	Row {
		id: connectivityRow
'''

data = data.replace(marker, custom, 1)

with open(file, "w") as f:
    f.write(data)

print("✅ Sensor mod inserted into StatusBar_Landscape.qml")
PY

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

if ac_input_installed || ac_loads_installed; then

    echo
    echo "⚠ AC Widget mod backup detected!"
    echo "A previous modification exists."
    echo "Restore the original before installing again."
    echo

    return 1

fi


echo "Installing AC Widget Enhancements"



# ----------------------------
# AC Input Widget
# ----------------------------

if ac_input_installed; then

	echo "AC Input mod already installed"

else

	backup_file "$ACINPUT" "ac"

	cd "$WIDGETS"


	cat > "$ACINPUT" <<'EOF'
/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcWidget {
	id: root

	readonly property AcInputSystemInfo inputInfo: input?.inputInfo ?? null
	property AcInput input
	readonly property bool inputOperational: input && input.operational

	title: !!inputInfo ? Global.acInputs.sourceToText(inputInfo.source) : ""
	icon.source: !!inputInfo ? Global.acInputs.sourceIcon(inputInfo.source) : ""
	rightPadding: sideGaugeLoader.active ? Theme.geometry_overviewPage_widget_sideGauge_margins : 0
	quantityLabel.sourceType: VenusOS.ElectricalQuantity_Source_AcInputOnly
	quantityLabel.dataObject: inputOperational ? input : null
	quantityLabel.leftPadding: acInputDirectionIcon.visible ? (acInputDirectionIcon.width + Theme.geometry_acInputDirectionIcon_rightMargin) : 0
	phaseCount: inputOperational ? input.phases.count : 0
	enabled: !!inputInfo
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		width: parent.width
		model: root.input.phases
		widgetSize: root.size
		inputMode: true
	}

// AC INPUT CURRENT (real system value)
VeQuickItem {
    id: acCurrent
    uid: "dbus/com.victronenergy.system/Ac/Grid/L1/Current"
}

// VOLTAGE fallback (VE.Bus inverter output)
VeQuickItem {
    id: acVoltage
    uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/V"
}

// FREQUENCY (VE.Bus output)
VeQuickItem {
    id: acFrequency
    uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/F"
}


// SAFE OVERLAY (DOES NOT BREAK TILE MODES)
Item {
    anchors.fill: parent
    z: 999

    Label {
        text:
            (acVoltage.valid ? acVoltage.value.toFixed(0) + " V" : "--- V") + "  " +
            (acCurrent.valid ? acCurrent.value.toFixed(1) + " A" : "--.- A") + "  " +
            (acFrequency.valid ? acFrequency.value.toFixed(1) + " Hz" : "--.- Hz")

        font.pixelSize: 16
        color: Theme.color_font_primary

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.geometry_baseline_spacing
        }

        visible: root.inputOperational &&
                 root.input &&
                 root.input.connected
    }
}
//end edit//

	onClicked: {
		const inputServiceUid = BackendConnection.serviceUidFromName(root.inputInfo.serviceName, root.inputInfo.deviceInstance)
		if (root.inputInfo.serviceType === "acsystem") {
			Global.pageManager.pushPage("/pages/settings/devicelist/rs/PageRsSystem.qml",
					{ "bindPrefix": inputServiceUid })
		} else if (root.inputInfo.serviceType === "vebus") {
			Global.pageManager.pushPage( "/pages/vebusdevice/PageVeBus.qml", {
				"bindPrefix": inputServiceUid
			})
		} else if (root.inputInfo.serviceType === "genset") {
			Global.pageManager.pushPage( "/pages/settings/devicelist/PageGenset.qml", {
				"bindPrefix": inputServiceUid
			})
		} else {
			// Assume this is on a generic AC input
			Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml", {
				"bindPrefix": inputServiceUid
			})
		}
	}

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}
		active: root.inputOperational && root.size >= VenusOS.OverviewWidget_Size_M
		sourceComponent: ThreePhaseBarGauge {
			valueType: VenusOS.Gauges_ValueType_NeutralPercentage
			phaseModel: root.input.phases
			minimumValue: root.inputInfo?.minimumCurrent ?? NaN
			maximumValue: root.inputInfo?.maximumCurrent ?? NaN
			inputMode: true
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}

	Label {
		anchors {
			top: root.extraContent.top
			topMargin: Theme.geometry_overviewPage_widget_extraContent_topMargin
			left: root.extraContent.left
			leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			right: root.extraContent.right
			rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
		}
		elide: Text.ElideRight
		text: root.inputInfo && root.inputInfo.source === VenusOS.AcInputs_InputSource_Generator
				? CommonWords.stopped
				: CommonWords.disconnected
		visible: !root.inputOperational
	}

	AcInputDirectionIcon {
		id: acInputDirectionIcon
		parent: root.quantityLabel
		anchors.verticalCenter: parent.verticalCenter
		input: root.input
	}
}

EOF



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


	cat > "$ACLOADS" <<'EOF'
/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

AcWidget {
	id: root

	readonly property ObjectAcConnection measurements: Global.system.showInputLoads
			? Global.system.load.acIn
			: Global.system.load.ac

	//% "AC Loads"
	title: qsTrId("overview_widget_acloads_title")
	icon.source: "qrc:/images/acloads.svg"
	type: VenusOS.OverviewWidget_Type_AcLoads
	quantityLabel.dataObject: root.measurements
	phaseCount: root.measurements.phases.count

//start edit//
////////////////////////////////////////////////////////////

// --- LIVE AC VOLTAGE, CURRENT, FREQUENCY ---
VeQuickItem {
    id: acVoltage
    uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/V"
}
VeQuickItem {
    id: acCurrent
    uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/I"
}
VeQuickItem {
    id: acFrequency
    uid: "dbus/com.victronenergy.vebus.ttyS4/Ac/Out/L1/F"
}

Label {
    text: (acVoltage.valid ? acVoltage.value.toFixed(0) + " V" : "--- V") + "  " +
          (acCurrent.valid ? acCurrent.value.toFixed(1) + " A" : "--.- A") + "  " +
          (acFrequency.valid ? acFrequency.value.toFixed(1) + " Hz" : "--.- Hz")

    font.pixelSize: 18
    color: Theme.color_font_primary
    anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: Theme.geometry_baseline_spacing
    }

    visible: root.size >= VenusOS.OverviewWidget_Size_L &&
             acVoltage.valid &&
             acVoltage.value >= 10
}
//end edit//
	extraContentLoader.sourceComponent: ThreePhaseDisplay {
		model: root.measurements.phases
		widgetSize: root.size
		valueType: VenusOS.Gauges_ValueType_RisingPercentage
		maximumValue: Global.system.load.maximumAcCurrent
	}
	extraContentLoader.active: root.phaseCount > 1 || root.measurements.l2AndL1OutSummed

	// AC meters with Position=1 (AC input) are considered as "AC Loads", so they are
	// accessible from this AC Loads widget.
	// For 3-phase systems, the drilldown is always enabled.
	// For 1-phase systems, only enable the drilldown if there are devices to be shown.
	enabled: root.measurements.phaseCount > 1 || acLoadDevices.count > 0

	onClicked: {
		Global.pageManager.pushPage("/pages/loads/AcLoadListPage.qml", {
			title: root.title,
			measurements: root.measurements,
			model: acLoadDevices,
		})
	}

	FilteredDeviceModel {
		id: acLoadDevices
		serviceTypes: ["acload", "evcharger", "heatpump"]
		childFilterIds: Global.system.showInputLoads
				? { "acload": ["Position"], "evcharger": ["Position"], "heatpump": ["Position"] }
				: {}
		childFilterFunction: (device, childItems) => {
			// If a service does not have a /Position value, assume it is in the "input" position.
			const pos = childItems["Position"]
			return !pos || pos.value === undefined || pos.value === VenusOS.AcPosition_AcInput
		}
	 }
}

EOF



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


if [ "$NEED_SYSTEMCALC_RESTART" = "1" ]; then
    echo "Restarting systemcalc..."
    svc -t /service/dbus-systemcalc-py
fi

if [ "$NEED_RESTART" = "1" ]; then
    echo "Restarting Venus GUI..."
    sleep 2
    svc -t /service/start-gui
fi



echo
echo "======================================"
echo "✅ Venus GUI Mods Complete"
echo "======================================"
