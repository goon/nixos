pragma Singleton
import QtQuick
import Quickshell
import qs

QtObject {
    id: root

    // Main battery properties
    property bool hasBattery: false
    property int percentage: 0
    property bool isCharging: false
    property string timeRemaining: ""
    
    // Power profile
    property bool hasPowerProfilesCtl: false
    property string powerProfile: "balanced" // power-saver, balanced, performance
    
    // Connected device batteries (wireless peripherals) - Now kept empty as per user request
    property var connectedDevices: []
    
    // Internal state
    property bool _mainBatteryCheckDone: false
    
    // Icon based on battery level (Material Symbols style)
    readonly property string batteryIcon: {
        if (isCharging) return "battery_charging_full";
        if (percentage >= 90) return "battery_full";
        if (percentage >= 80) return "battery_6_bar";
        if (percentage >= 65) return "battery_5_bar";
        if (percentage >= 50) return "battery_4_bar";
        if (percentage >= 35) return "battery_3_bar";
        if (percentage >= 20) return "battery_2_bar";
        if (percentage >= 10) return "battery_1_bar";
        return "battery_0_bar";
    }
    
    // Icon color based on battery level
    readonly property color batteryColor: {
        if (isCharging) return Theme.colors.success;
        if (percentage <= 20) return Theme.colors.error;
        if (percentage <= 40) return Theme.colors.warning;
        return Theme.colors.text;
    }
    
    // Check if system has a battery (laptop)
    function checkBatteryPresence() {
        ProcessService.run(["bash", "-c", "ls /sys/class/power_supply/BAT* 2>/dev/null | head -1"], function(output) {
            root.hasBattery = output.trim() !== "";
            root._mainBatteryCheckDone = true;
        });
    }
    
    // Update main battery status
    function updateBatteryStatus() {
        if (!root.hasBattery) return;
        
        ProcessService.run(["upower", "-i", "/org/freedesktop/UPower/devices/battery_BAT0"], function(output) {
            if (output.trim() === "") {
                // Try BAT1
                ProcessService.run(["upower", "-i", "/org/freedesktop/UPower/devices/battery_BAT1"], function(output2) {
                    root.parseBatteryOutput(output2);
                });
            } else {
                root.parseBatteryOutput(output);
            }
        });
    }
    
    function parseBatteryOutput(output) {
        if (!output || output.trim() === "") return;
        
        var lines = output.split("\n");
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            
            if (line.startsWith("percentage:")) {
                var match = line.match(/(\d+)/);
                if (match) {
                    root.percentage = parseInt(match[1]);
                }
            } else if (line.startsWith("state:")) {
                root.isCharging = line.includes("state: charging") || line.includes("state: fully-charged");
            } else if (line.startsWith("time to ")) {
                var timeMatch = line.match(/time to \w+:\s*(.+)/);
                if (timeMatch) {
                    root.timeRemaining = timeMatch[1].trim();
                }
            }
        }
    }
    
    
    // Get current power profile
    function updatePowerProfile() {
        if (!root.hasPowerProfilesCtl) return;
        
        ProcessService.run(["powerprofilesctl", "get"], function(output) {
            var profile = output.trim();
            if (profile === "power-saver" || profile === "balanced" || profile === "performance") {
                root.powerProfile = profile;
            }
        });
    }
    
    // Set power profile
    function setPowerProfile(profile) {
        if (!root.hasPowerProfilesCtl) return;
        
        if (profile !== "power-saver" && profile !== "balanced" && profile !== "performance") {
            return;
        }
        
        ProcessService.run(["powerprofilesctl", "set", profile], function(output) {
            root.powerProfile = profile;
        });
    }
    
    // Timers
    property Timer batteryCheckTimer: Timer {
        interval: 15000 // 15 seconds
        running: root.hasBattery
        repeat: true
        triggeredOnStart: false
        onTriggered: root.updateBatteryStatus()
    }
    
    // Profile check timer
    property Timer profileCheckTimer: Timer {
        interval: 60000 // 1 minute
        running: root.hasPowerProfilesCtl
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updatePowerProfile()
    }
    
    Component.onCompleted: {
        checkBatteryPresence();
        
        // Initial detection of power-profiles-ctl
        ProcessService.run(["which", "powerprofilesctl"], function(output) {
            root.hasPowerProfilesCtl = output.trim() !== "";
            if (root.hasPowerProfilesCtl) {
                root.updatePowerProfile();
            }
        });
        
        // Initial battery check
        Qt.callLater(() => {
                root.updateBatteryStatus();
        });
    }
}
