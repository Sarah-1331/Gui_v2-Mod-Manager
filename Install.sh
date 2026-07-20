#!/bin/bash
#
# Venus OS GUI v2 Mod Manager
# Version 1.0
#

set -e

MOD_VERSION="1.0"

ORIG_GUI="/opt/victronenergy/gui-v2"
OVERLAY="/data/apps/overlay-fs/data/gui-v2/upper"

NEED_RESTART=0


# ============================================================
# Detect target
# ============================================================

if [ -d "$OVERLAY" ]; then
    GUI_ROOT="$OVERLAY"
    echo "✅ Overlay-fs detected"
else
    GUI_ROOT="$ORIG_GUI"
    echo "⚠ No overlay detected"
fi


STATUSBAR="$GUI_ROOT/Victron/VenusOS/components/StatusBar.qml"
BATTERY="$GUI_ROOT/Victron/VenusOS/components/widgets/BatteryWidget.qml"
ACWIDGET="$GUI_ROOT/Victron/VenusOS/components/widgets/AcInputWidget.qml"


echo
echo "======================================"
echo " Venus OS GUI v2 Mod Manager"
echo " Version $MOD_VERSION"
echo "======================================"
echo


# ============================================================
# Backup function
# ============================================================

backup_file()
{
    FILE="$1"

    if [ -f "$FILE" ]; then
        cp "$FILE" "$FILE.bak-$(date +%Y%m%d-%H%M%S)"
        echo "Backup created:"
        echo "$FILE"
    fi
}


# ============================================================
# Detection
# ============================================================

battery_installed()
{
    grep -q "Battery Time Estimator" "$BATTERY" 2>/dev/null
}


sensors_installed()
{
    grep -q "liveSensorRow" "$STATUSBAR" 2>/dev/null
}


ac_installed()
{
    grep -q "AC Widget Enhancement" "$ACWIDGET" 2>/dev/null
}



# ============================================================
# Battery Time Mod
# ============================================================

install_battery()
{
    echo "Installing Battery Time Estimator..."

    backup_file "$BATTERY"

    #
    # PATCH GOES HERE
    #

    NEED_RESTART=1
}



restore_battery()
{
    BACKUP=$(ls -t "$BATTERY.bak-"* 2>/dev/null | head -n1)

    if [ -f "$BACKUP" ]; then
        cp "$BACKUP" "$BATTERY"
        echo "Battery restored"
        NEED_RESTART=1
    else
        echo "No battery backup found"
    fi
}



# ============================================================
# Live Sensor Mod
# ============================================================

install_sensors()
{
    echo "Installing Live Sensors..."

    backup_file "$STATUSBAR"

    #
    # PATCH GOES HERE
    #

    NEED_RESTART=1
}



restore_sensors()
{
    BACKUP=$(ls -t "$STATUSBAR.bak-"* 2>/dev/null | head -n1)

    if [ -f "$BACKUP" ]; then
        cp "$BACKUP" "$STATUSBAR"
        echo "Sensors restored"
        NEED_RESTART=1
    else
        echo "No sensor backup found"
    fi
}



# ============================================================
# AC Widget Mod
# ============================================================

install_ac()
{
    echo "Installing AC Widget..."

    backup_file "$ACWIDGET"

    #
    # PATCH GOES HERE
    #

    NEED_RESTART=1
}



restore_ac()
{
    BACKUP=$(ls -t "$ACWIDGET.bak-"* 2>/dev/null | head -n1)

    if [ -f "$BACKUP" ]; then
        cp "$BACKUP" "$ACWIDGET"
        echo "AC widget restored"
        NEED_RESTART=1
    else
        echo "No AC backup found"
    fi
}



# ============================================================
# Status display
# ============================================================

echo "Installed Mods:"
echo

if battery_installed; then
    echo "1) Battery Time Estimator       ✅ Installed"
else
    echo "1) Battery Time Estimator       ❌ Not Installed"
fi


if sensors_installed; then
    echo "2) Live Sensor Status Bar       ✅ Installed"
else
    echo "2) Live Sensor Status Bar       ❌ Not Installed"
fi


if ac_installed; then
    echo "3) AC Widget Enhancement        ✅ Installed"
else
    echo "3) AC Widget Enhancement        ❌ Not Installed"
fi


echo
echo "--------------------------------------"
echo "4) Install All"
echo "5) Restore All"
echo "6) Exit"
echo

read -p "Select: " OPTION


case "$OPTION" in

1)
    if battery_installed; then
        restore_battery
    else
        install_battery
    fi
;;

2)
    if sensors_installed; then
        restore_sensors
    else
        install_sensors
    fi
;;

3)
    if ac_installed; then
        restore_ac
    else
        install_ac
    fi
;;

4)
    install_battery
    install_sensors
    install_ac
;;

5)
    restore_battery
    restore_sensors
    restore_ac
;;

6)
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
    echo "Restarting GUI..."

    svc -t /service/start-gui

fi


echo
echo "✅ Complete"
