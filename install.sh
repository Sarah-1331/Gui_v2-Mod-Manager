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
    compgen -G "$BATTERY.bak-battery-*" > /dev/null
}


sensors_installed()
{
    compgen -G "$STATUSBAR.bak-sensors-*" > /dev/null
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
    echo "⚠ Battery mod backup detected!"
    echo "A previous modification exists."
    echo "Restore the original before installing again."
    echo

    return 1

fi


echo "Installing Battery Time Estimator"

backup_file "$BATTERY" "battery"

cd "$WIDGETS"


cat > "$BATTERY" <<'EOF'
/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

OverviewWidget {
	id: root

	readonly property bool preferRenewable: preferRenewableEnergy.valid
	readonly property bool preferRenewableOverride: preferRenewableEnergy.value === 0 || preferRenewableEnergy.value === 2
	readonly property bool preferRenewableOverrideGenset: remoteGeneratorSelected.value === 1 || Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Generator

	onClicked: {
		// If com.victronenergy.system/Batteries has only one battery, then show the device
		// settings for that battery; otherwise, show the full battery list using BatteryListPage.
		if (batteries.value.length === 1) {
			const batteryUids = batteries.value.map((info) => BackendConnection.serviceUidFromName(info.id, info.instance))

			// Show the vebus page if the battery is from a vebus service.
			if (BackendConnection.serviceTypeFromUid(batteryUids[0]) === "vebus") {
				Global.pageManager.pushPage("/pages/vebusdevice/PageVeBus.qml", {
					"bindPrefix": batteryUids[0],
				})
			} else {
				// Assume this is a battery service
				Global.pageManager.pushPage("/pages/settings/devicelist/battery/PageBattery.qml", {
					"bindPrefix": batteryUids[0]
				})
			}
		} else {
			Global.pageManager.pushPage("/pages/battery/BatteryListPage.qml")
		}
	}

	readonly property var batteryData: Global.system.battery
	readonly property real batterySoc: batteryData.stateOfCharge || 0

	readonly property int _normalizedStateOfCharge: Math.round(batteryData.stateOfCharge || 0)
	readonly property bool _animationReady: animationEnabled && !isNaN(batteryData.stateOfCharge)

	// Calculate whether voltage, current and power quantities fit on the footer together, if not use smaller font.
	// Discharging battery has negative amperes and its not unusual for the watts to be in the 1k+ range.
	readonly property bool _useSmallFont: !quantityLabelFits(batteryVoltageDisplay) || !quantityLabelFits(batteryPowerDisplay)

	function quantityLabelFits(label) {
		return root.width/2 - 2*Theme.geometry_overviewPage_widget_content_horizontalMargin
			> quantityLabelWidth(batteryCurrentDisplay.valueText, batteryCurrentDisplay.unitText)/2
			+ quantityLabelWidth(label.valueText, label.unitText)
	}

	function quantityLabelWidth(valueText, unitText){
		const valueTextRect = quantityLabelFont.tightBoundingRect(valueText)
		return quantityLabelFont.font, (valueTextRect.x + valueTextRect.width
										+ Theme.geometry_quantityLabel_spacing
										+ quantityLabelFont.advanceWidth(unitText))
	}

	FontMetrics {
		id: quantityLabelFont
		font.pixelSize: Theme.font_size_body2
		font.family: Global.quantityFontFamily
	}

	VeQuickItem {
		id: batteries
		uid: Global.system.serviceUid + "/Batteries"
	}

	VeQuickItem {
		id: preferRenewableEnergy

		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Dc/0/PreferRenewableEnergy" : ""
	}

	VeQuickItem {
		id: remoteGeneratorSelected

		uid: Global.system.veBus.serviceUid ? Global.system.veBus.serviceUid + "/Ac/State/RemoteGeneratorSelected" : ""
	}
	
	VeQuickItem {
		id: batteryCapacity

		uid: "dbus/com.victronenergy.battery.socketcan_vecan0/Capacity"
	}
	
	VeQuickItem { 
		id: batteryInstalledCapacity 
		
		uid: "dbus/com.victronenergy.battery.socketcan_vecan0/InstalledCapacity" 
	}

	title: CommonWords.battery
	icon.source: batteryData.icon
	type: VenusOS.OverviewWidget_Type_Battery
	enabled: batteries.valid

	quantityLabel.value: batteryData.stateOfCharge
	quantityLabel.unit: VenusOS.Units_Percentage
	quantityLabel.unitColor: Theme.color_overviewPage_widget_battery_font_secondary

	color: "transparent"

	BarGauge {
		id: animationRect
		z: -1

		anchors {
			fill: parent
			margins: root.border.width
		}

		animationEnabled: root.animationEnabled // Note: don't use _animationReady here.
		value: _normalizedStateOfCharge/100
		backgroundColor: Theme.color_overviewPage_widget_background
		foregroundColor: Theme.color_overviewPage_widget_battery_background
		radius: Theme.geometry_overviewPage_widget_battery_background_radius

		Item {
			id: animationClip

			width: parent.width
			height: parent.height * (animationRect.value)
			anchors.bottom: parent.bottom
			visible: batteryData.mode === VenusOS.Battery_Mode_Charging && root._animationReady
			clip: true
			z: 6 // greater than the explicit z-order specified in BarGauge.

			SequentialAnimation {
				property bool startAnimation: root._animationReady
				onStartAnimationChanged: if (startAnimation) start()
				onStopped: if (startAnimation) start()

				YAnimator {
					target: gradient
					from: animationClip.height
					to: -gradient.height
					duration: Theme.animation_overviewPage_widget_battery_animation_duration
					easing.type: Easing.OutQuad
				}

				PauseAnimation {
					duration: Theme.animation_overviewPage_widget_battery_animation_pause_duration
				}
			}

			Rectangle {
				id: gradient
				width: parent.width
				height: Theme.geometry_overviewPage_widget_battery_gradient_height
				gradient: Gradient {
					GradientStop {
						position: 0.0
						color: Qt.rgba(1,1,1,0.3)
					}
					GradientStop {
						position: 0.3
						color: Qt.rgba(1,1,1,0.15)
					}
					GradientStop {
						position: 1.0
						color: Qt.rgba(1,1,1,0.0)
					}
				}
			}
		}
	}

	QuantityLabel {
		id: batteryTempDisplay

		anchors {
			top: parent.top
			topMargin: root.verticalMargin
			right: parent.right
			rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
		}

		value: batteryData.temperature
		unit: Global.systemSettings.temperatureUnit
		unitColor: Theme.color_overviewPage_widget_battery_font_secondary
		font.pixelSize: Theme.font_size_body2
		alignment: Qt.AlignRight
		visible: !isNaN(batteryData.temperature)
	}

	extraContentChildren: [
		Column {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			Label {
				text: VenusOS.battery_modeToText(batteryData.mode)
				font.pixelSize: Theme.font_size_body1
				width: parent.width
				elide: Text.ElideRight
				color: Theme.color_overviewPage_widget_battery_font_secondary
			}
			
			Label {
				text: {
					const remainingAh = batteryCapacity.value;
					const fullAh = batteryInstalledCapacity.value;
					const reserveAh = fullAh * 0.20;   // calculate runtime down to 20%

					const current = batteryData.current;

					// Charging
					if (current > 0.1) {

						// Last 1% is finishing/balancing stage, no useful time estimate
						if (remainingAh >= fullAh * 0.99)
							return "Finishing charge";

						const chargeAh = fullAh - remainingAh;
						const hours = chargeAh / current;
						const seconds = hours * 3600;

						return "Time to full " + Utils.secondsToString(seconds);
					}

					// Discharging
					if (current < -0.1) {

						// Warning below 25%
						if (remainingAh <= fullAh * 0.25)
							return "WARNING";

						// Calculate remaining time down to 20%
						const usableAh = remainingAh - reserveAh;
						const hours = usableAh / Math.abs(current);
						const seconds = hours * 3600;

						return "Remaining " + Utils.secondsToString(seconds);
					}

					return "";
				}

				visible: true

				color: batteryCapacity.value <= batteryInstalledCapacity.value * 0.30
						? "red"
						: batteryCapacity.value <= batteryInstalledCapacity.value * 0.35
							? "orange"
							: Theme.color_font_primary

				width: parent.width
				elide: Text.ElideRight
				font.pixelSize: Theme.font_overviewPage_battery_timeToGo_pixelSize
			}	
		},

		CP.ColorImage {
			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: batteryVoltageDisplay.top
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			fillMode: Image.PreserveAspectFit
			color: Theme.color_font_primary
			visible: root.preferRenewableOverride
			source: root.preferRenewableOverrideGenset
					? "qrc:/images/icon_charging_generator.svg"
					: Global.acInputs.activeInSource === VenusOS.AcInputs_InputSource_Shore
					  ? "qrc:/images/icon_charging_shore.svg"
					  : "qrc:/images/icon_charging_grid.svg"
		},

		QuantityLabel {
			id: batteryVoltageDisplay

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}

			value: batteryData.voltage
			unit: VenusOS.Units_Volt_DC
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
			alignment: Qt.AlignLeft
		},

		QuantityLabel {
			id: batteryCurrentDisplay

			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			value: batteryData.current
			unit: VenusOS.Units_Amp
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
		},

		CP.ColorImage {
			anchors {
				bottom: batteryPowerDisplay.top
				bottomMargin: Theme.geometry_overviewPage_batterywidget_renewable_icon_bottom_margin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_batterywidget_renewable_icon_right_margin
			}

			fillMode: Image.PreserveAspectFit
			color: Theme.color_font_primary
			visible: root.preferRenewable
			source: "qrc:/images/icon_charging_renewables.svg"
		},

		QuantityLabel {
			id: batteryPowerDisplay

			anchors {
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_battery_bottomRow_bottomMargin
			}
			value: batteryData.power
			unit: VenusOS.Units_Watt
			unitColor: Theme.color_overviewPage_widget_battery_font_secondary
			font.pixelSize: root._useSmallFont ? Theme.font_size_body1 : Theme.font_size_body2
			alignment: Qt.AlignRight
		}
	]
}

EOF

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

if sensors_installed; then

    echo
    echo "⚠ Sensor mod backup detected!"
    echo "A previous modification exists."
    echo "Restore the original before installing again."
    echo

    return 1

fi


echo "Installing Live Sensor Status Bar"

backup_file "$STATUSBAR" "sensors"

install_sensor_icons

cd "$COMPONENTS"

cat > "$STATUSBAR" <<'EOF'
/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

FocusScope {
	id: root

	required property PageStack pageStack
	property string title
	property alias backgroundColor: backgroundRect.color

	property int leftButton: VenusOS.StatusBar_LeftButton_None
	property int rightButton: VenusOS.StatusBar_RightButton_None
	readonly property bool notificationButtonsEnabled: Global.mainView.currentPage && !!Global.mainView.currentPage.url && Global.mainView.currentPage.url.endsWith("NotificationsPage.qml")
	readonly property bool notificationButtonVisible: alarmButton.enabled || alarmButton.animating

	property bool animationEnabled

	signal leftButtonClicked()
	signal rightButtonClicked()
	signal auxButtonClicked()
	// PageStack.get(...) returns an Item, so the arg for 'popToPage' needs to be 'Item'. If we make it a 'Page', it works fine on the desktop,
	// but shows an unusual failure on the device. There is an error message about "passing incompatible arguments to signals is not supported",
	// and the page stack pops 1 too many pages.
	signal popToPage(toPage: Item)

	width: parent.width
	height: Theme.geometry_statusBar_height
	opacity: 0.0

	Component.onCompleted: if (!animationEnabled) { root.opacity = 1.0 }

	Rectangle {
		id: backgroundRect
		anchors.fill: parent
	}

	SequentialAnimation {
		running: !Global.splashScreenVisible && animationEnabled

		PauseAnimation {
			duration: Theme.animation_statusBar_initialize_delayedStart_duration
		}
		OpacityAnimator {
			target: root
			from: 0.0
			to: 1.0
			duration: Theme.animation_statusBar_initialize_fade_duration
		}
	}

	component StatusBarButton : Button {
		radius: 0
		defaultBackgroundWidth: Theme.geometry_statusBar_button_height
		defaultBackgroundHeight: Theme.geometry_statusBar_button_height
		backgroundColor: "transparent"  // don't show background when disabled
		display: Button.IconOnly
		color: Theme.color_ok
		opacity: enabled && Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive ? 1.0 : 0.0
		onActiveFocusChanged: {
			if (activeFocus) {
				breadcrumbs.updateFocusEdgeHint()
			}
		}

		// For convenience, bind the paddings to the offsets that are used to expand the clickable
		// area. If the button only contains an icon, no additional padding is required as the icon
		// fits within the default defaultBackgroundWidth/Height.
		leftPadding: leftInset
		rightPadding: rightInset
		topPadding: topInset
		bottomPadding: bottomInset

		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				duration: Theme.animation_page_idleOpacity_duration
			}
		}
	}

	component NotificationButton : Button {
		readonly property bool animating: animator.running

		opacity: enabled ? 1 : 0
		font.family: Global.fontFamily
		font.pixelSize: Theme.font_size_caption
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				id: animator
				duration: Theme.animation_toastNotification_fade_duration
			}
		}
	}

	StatusBarButton {
		id: leftButton

		// Expand clickable area on left and bottom edges.
		leftInset: Theme.geometry_statusBar_horizontalMargin
		bottomInset: Theme.geometry_statusBar_spacing

		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsInactive ? "qrc:/images/icon_controls_off_32.svg"
			: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive ? "qrc:/images/icon_controls_on_32.svg"
			: root.leftButton === VenusOS.StatusBar_LeftButton_Back ? "qrc:/images/icon_back_32.svg"
			: ""
		enabled: root.leftButton !== VenusOS.StatusBar_LeftButton_None
		KeyNavigation.right: auxButton

		onClicked: root.leftButtonClicked()
	}

	StatusBarButton {
		id: auxButton

		readonly property bool auxCardsOpened: Global.mainView.cardsActive
				&& root.leftButton !== VenusOS.StatusBar_LeftButton_ControlsActive

		// Expand clickable area on right and bottom edges, and on left if leftButton is hidden.
		anchors {
			left: leftButton.right
			leftMargin: -leftInset
		}
		leftInset: leftButton.enabled ? 0 : Theme.geometry_statusBar_spacing
		rightInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		visible: (!root.pageStack.opened && Global.switches.groups.count > 0)
				|| auxCardsOpened // allow cards to be closed if all switches are disconnected while opened
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive ? ""
				: auxCardsOpened ? "qrc:/images/icon_smartswitch_on_32.svg"
				: "qrc:/images/icon_smartswitch_off_32.svg"
		enabled: root.leftButton !== VenusOS.StatusBar_LeftButton_ControlsActive
		KeyNavigation.right: breadcrumbs

		onClicked: root.auxButtonClicked()
	}

	Breadcrumbs {
		id: breadcrumbs

		property int focusEdgeHint: Qt.LeftEdge

		function updateFocusEdgeHint() {
			// When breadcrumbs list is focused: if focus is arriving from the left side, focus the
			// the left-most breadcrumb, or if from the right side, focus the right-most breadcrumb.
			if (leftButton.activeFocus || auxButton.activeFocus) {
				focusEdgeHint = Qt.LeftEdge
			} else if (rightButton.activeFocus || sleepButton.activeFocus) {
				focusEdgeHint = Qt.RightEdge
			} else {
				// Focus is coming from the main list view below, so do not change the current index
				focusEdgeHint = -1
			}
		}

		anchors {
			top: parent.top
			topMargin: Theme.geometry_settings_breadcrumb_topMargin
			left: leftButton.right
			leftMargin: Theme.geometry_settings_breadcrumb_horizontalMargin
			right: rightButtonRow.left
		}
		height: Theme.geometry_settings_breadcrumb_height
		model: root.pageStack.opened ? root.pageStack.depth + 1 : null // '+ 1' because we insert a dummy breadcrumb with the text "Settings"
		visible: count >= 2
		enabled: visible // don't receive focus when invisble
		focus: false // don't give status bar initial focus to the breadcrumbs

		getText: function(index) {
			return index === 0
					? Global.mainView.navBar.activeButtonText // eg: "Settings"
					: pageStack.get(index - 1).title // eg: "Device list"
		}

		onClicked: function(index) {
			const isTopBreadcrumb = index === breadcrumbs.count - 1
			const isBottomBreadcrumb = index === 0

			if (isBottomBreadcrumb) { // the bottom breadcrumb is a special case, we inserted a dummy breadcrumb with the text "Settings" which doesn't relate to anything in the pageStack
				Global.pageManager.popAllPages()
				return
			}

			if (isTopBreadcrumb) { // ignore clicks on the top of the breadcrumb trail. We don't need to navigate there, we are already there...
				return
			}

			root.popToPage(pageStack.get(index - 1)) // subtract 1, because we inserted a dummy "Settings" breadcrumb at the beginning
		}

		onActiveFocusChanged: {
			if (activeFocus && focusEdgeHint >= 0) {
				// Focus the first (left-most) or last (right-most) breadcrumb, depending the side
				// that the key navigation is arriving from.
				currentIndex = focusEdgeHint === Qt.LeftEdge ? 0 : count - 1
				focusEdgeHint = -1
			}
		}

		KeyNavigation.right: notificationButton

		Connections {
			target: root.pageStack
			enabled: root.pageStack.opened && Global.keyNavigationEnabled
			function onDepthChanged() {
				// When pages are pushed/popped, reset the focus to be on the last breadcrumb.
				breadcrumbs.currentIndex = breadcrumbs.count - 1
			}
		}
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
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
// Always participate in layout, but fade in/out
    visible: true
    opacity: !breadcrumbs.visible ? 1 : 0

    Behavior on opacity {
        enabled: root.animationEnabled
        OpacityAnimator {
            duration: Theme.animation_page_idleOpacity_duration
        }
    }


    // — D-Bus Bindings —
    VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }
    VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }
    VeQuickItem { id: fridgeTemp;   uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }
    VeQuickItem { id: hotWaterTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_0/Temperature" }
    VeQuickItem { id: waterLevel;   uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level" }
    VeQuickItem { id: waterCapacity; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity" }
    VeQuickItem { id: themeMode;     uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme" }

    // — Internal Temp —
    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/tempB.svg"
                : "file:///data/custom-icons/temp.svg"
        }
        Label {
            text: internalTemp.valid ? internalTemp.value.toFixed(1) + "°C" : "--.-°C"
            font.bold: true; font.pixelSize: 18
        }
    }

    // — External Temp —
    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/externalB.svg"
                : "file:///data/custom-icons/external.svg"
        }
        Label {
            text: externalTemp.valid ? externalTemp.value.toFixed(1) + "°C" : "--.-°C"
            font.bold: true; font.pixelSize: 18
        }
    }

    // — Fridge Temp —
    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/snowflakeB.svg"
                : "file:///data/custom-icons/snowflake.svg"
        }
        Label {
            text: fridgeTemp.valid ? fridgeTemp.value.toFixed(1) + "°C" : "--.-°C"
            font.bold: true; font.pixelSize: 18
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
    
    
    
// Always in layout, but fade based on breadcrumbs
    visible: true
    opacity: !breadcrumbs.visible ? 1 : 0

    Behavior on opacity {
        enabled: root.animationEnabled
        OpacityAnimator {
            duration: Theme.animation_page_idleOpacity_duration
        }
    }

    // — Water Tank Level —
    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/waterB.svg"
                : "file:///data/custom-icons/water.svg"
        }
Label {
    text:
        (waterLevel.valid
            ? (waterCapacity.valid
                ? ((waterLevel.value / 100.0) * waterCapacity.value * 1000).toFixed(0) + "L"
                : waterLevel.value.toFixed(0) + "%")
            : "")
        + (hotWaterTemp.valid
            ? (waterLevel.valid ? "  " : "") + hotWaterTemp.value.toFixed(1) + "°C"
            : "")
    font.bold: true
    font.pixelSize: 18
}
    }
}


// === End Custom Live Sensor Row ===
	Row {
		id: connectivityRow

		anchors {
			left: clockLabel.right
			leftMargin: Theme.geometry_statusBar_spacing
			verticalCenter: parent.verticalCenter
		}
		visible: !breadcrumbs.visible
		spacing: Theme.geometry_statusBar_spacing

		CP.IconImage {
			anchors.verticalCenter: parent.verticalCenter
			color: Theme.color_font_primary
			source: {
				if (!signalStrength.valid) {
					return ""
				} else if (signalStrength.value > 75) {
					return "qrc:/images/icon_WiFi_4_32.svg"
				} else if (signalStrength.value > 50) {
					return "qrc:/images/icon_WiFi_3_32.svg"
				} else if (signalStrength.value > 25) {
					return "qrc:/images/icon_WiFi_2_32.svg"
				} else if (signalStrength.value > 0) {
					return "qrc:/images/icon_WiFi_1_32.svg"
				} else {
					return "qrc:/images/icon_WiFi_noconnection_32.svg"
				}
			}

			VeQuickItem {
				id: signalStrength

				uid: Global.venusPlatform.serviceUid +  "/Network/Wifi/SignalStrength"
			}
		}

		GsmStatusIcon {
			height: Theme.geometry_status_bar_gsmModem_icon_height
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	StatusBarButton {
		id: notificationButton

		anchors {
			left: connectivityRow.right
			leftMargin: Theme.geometry_statusBar_spacing
		}
		// Expand clickable area on right and bottom edges.
		rightInset: Theme.geometry_statusBar_spacing / 2
		bottomInset: Theme.geometry_statusBar_spacing

		// The notificationButton should always be shown, even when the page is not interactive
		opacity: 1
		visible: !breadcrumbs.visible && (Global.notifications?.statusBarNotificationIconVisible ?? false)

		color: Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Alarm
			   ? Theme.color_critical
			   : Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Warning
				 ? Theme.color_warning :
				   Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Info ? Theme.color_ok : "transparent"
		icon.source: Global.notifications?.statusBarNotificationIconPriority === VenusOS.Notification_Info ?
						 "qrc:/images/icon_info_32.svg" : "qrc:/images/icon_warning_32.svg"
		onClicked: Global.mainView.goToNotificationsPage()
		KeyNavigation.right: alarmButton
	}

	NotificationButton {
		id: alarmButton

		anchors {
			left: notificationButton.right
			verticalCenter: parent.verticalCenter
		}
		// Expand clickable area on horizontal and bottom edges.
		leftInset: Theme.geometry_statusBar_spacing / 2
		leftPadding: leftInset + Theme.geometry_silenceAlarmButton_horizontalPadding
		rightInset: Theme.geometry_statusBar_spacing / 2
		rightPadding: rightInset + Theme.geometry_silenceAlarmButton_horizontalPadding
		topInset: Theme.geometry_statusBar_spacing
		bottomInset: Theme.geometry_statusBar_spacing

		enabled: notificationButtonsEnabled && (Global.notifications?.silenceAlarmVisible ?? false)
		flat: false
		backgroundColor: down ? Theme.color_critical : Theme.color_critical_background
		borderWidth: 0
		// ensure highlight border can be seen against critical backgroundColor
		KeyNavigationHighlight.margins: -(4 * Theme.geometry_button_border_width)
		icon.source: "qrc:/images/icon_alarm_snooze_24.svg"
		text: CommonWords.silence_alarm

		onClicked: NotificationModel.acknowledgeAll()
	}

	Row {
		id: rightButtonRow

		height: parent.height
		anchors.right: parent.right

		StatusBarButton {
			id: rightButton

			// Expand clickable area on left and bottom edges.
			leftInset: Theme.geometry_statusBar_spacing
			bottomInset: Theme.geometry_statusBar_spacing

			enabled: root.rightButton != VenusOS.StatusBar_RightButton_None
			visible: enabled
			icon.source: root.rightButton === VenusOS.StatusBar_RightButton_SidePanelActive
						 ? "qrc:/images/icon_sidepanel_on_32.svg"
						 : root.rightButton === VenusOS.StatusBar_RightButton_SidePanelInactive
						   ? "qrc:/images/icon_sidepanel_off_32.svg"
						   : root.rightButton === VenusOS.StatusBar_RightButton_Add
							 ? "qrc:/images/icon_plus.svg"
							 : root.rightButton === VenusOS.StatusBar_RightButton_Refresh
							   ? "qrc:/images/icon_refresh_32.svg"
							   : ""
			KeyNavigation.left: alarmButton
			KeyNavigation.right: sleepButton

			onClicked: root.rightButtonClicked()
		}

		StatusBarButton {
			id: sleepButton

			// Expand clickable area on right and bottom edges, and on left edge if right button is
			// hidden. This is the right-most button in the row, so on the right edge, use
			// Theme.geometry_statusBar_horizontalMargin instead of Theme.geometry_statusBar_spacing.
			leftInset: rightButton.visible ? 0 : Theme.geometry_statusBar_spacing
			rightInset: Theme.geometry_statusBar_horizontalMargin
			bottomInset: Theme.geometry_statusBar_spacing

			icon.source: "qrc:/images/icon_screen_sleep_32.svg"
			visible: enabled
			enabled: ScreenBlanker.supported
					&& ScreenBlanker.enabled
					&& Global.pageManager?.interactivity === VenusOS.PageManager_InteractionMode_Interactive
			onClicked: ScreenBlanker.setDisplayOff()
		}
	}

	// The status bar should never become the focused item; if it does, it means there was no
	// previously focused button in the status bar, or the last focused button is now disabled and
	// not focusable. So, find the first available button and focus that instead.
	Connections {
		target: Global.main
		enabled: Global.keyNavigationEnabled
		function onActiveFocusItemChanged() {
			if (Global.main.activeFocusItem === root) {
				for (const button of [leftButton, auxButton, breadcrumbs, notificationButton, alarmButton, rightButton, sleepButton]) {
					if (button.enabled) {
						button.focus = true
						break
					}
				}
			}
		}
	}
}

EOF


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
