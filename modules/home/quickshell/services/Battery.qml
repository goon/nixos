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
    
    // Connected device batteries (wireless peripherals)
    property var connectedDevices: []
    
    // Internal state
    property bool _mainBatteryCheckDone: false
    
    // Common manufacturer prefixes to strip for deduplication
    readonly property var manufacturerPrefixes: [
        "logitech", "razer", "corsair", "steelseries", "hyperx",
        "razer", "asus", "msi", "corsair", "cooler master",
        "apple", "samsung", "sony", "microsoft", "jbl",
        "bose", "audio-technica", "sennheiser", "anker"
    ]
    
    // Icon based on battery level (Android Frame horizontal style)
    readonly property string batteryIcon: {
        if (isCharging) return "battery_android_frame_charging";
        if (percentage >= 90) return "battery_android_frame_5";
        if (percentage >= 70) return "battery_android_frame_4";
        if (percentage >= 50) return "battery_android_frame_3";
        if (percentage >= 30) return "battery_android_frame_2";
        if (percentage >= 20) return "battery_android_frame_1";
        return "battery_android_frame_0";
    }
    
    // Icon color based on battery level
    readonly property color batteryColor: {
        if (isCharging) return Theme.colors.success;
        if (percentage <= 20) return Theme.colors.error;
        if (percentage <= 40) return Theme.colors.warning;
        return Theme.colors.text;
    }
    
    // Normalize device name for deduplication (removes manufacturer prefixes)
    function normalizeDeviceName(name) {
        var normalized = name.toLowerCase().trim();
        for (var i = 0; i < manufacturerPrefixes.length; i++) {
            var prefix = manufacturerPrefixes[i];
            if (normalized.startsWith(prefix + " ")) {
                normalized = normalized.substring(prefix.length + 1).trim();
                break;
            }
        }
        return normalized;
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
    
    // Update connected device batteries from both upower and sysfs
    function updateConnectedDevices() {
        // Collect devices from both sources
        var allDevices = [];
        var processedNormalizedNames = {}; // Track normalized names to avoid duplicates
        
        // First, scan sysfs for HID++ devices (Logitech mice, etc.)
        ProcessService.run(["bash", "-c", "for dev in /sys/class/power_supply/hidpp_battery_*/uevent; do if [ -f \"$dev\" ]; then echo \"---DEVICE_START---\"; cat \"$dev\"; echo \"---DEVICE_END---\"; fi; done"], function(sysfsOutput) {
            if (sysfsOutput && sysfsOutput.trim() !== "") {
                root.parseSysfsDevices(sysfsOutput, allDevices, processedNormalizedNames);
            }
            
            // Then, scan upower for other devices
            ProcessService.run(["upower", "-d"], function(upowerOutput) {
                if (upowerOutput && upowerOutput.trim() !== "") {
                    root.parseUpowerDevices(upowerOutput, allDevices, processedNormalizedNames);
                }
                
                root.connectedDevices = allDevices;
            });
        });
    }
    
    function parseSysfsDevices(output, devices, processedNormalizedNames) {
        var deviceBlocks = output.split("---DEVICE_START---");
        
        for (var i = 1; i < deviceBlocks.length; i++) {
            var block = deviceBlocks[i].split("---DEVICE_END---")[0].trim();
            if (!block) continue;
            
            var device = {
                name: "Unknown Device",
                percentage: 0,
                icon: "devices_other"
            };
            
            var lines = block.split("\n");
            
            for (var j = 0; j < lines.length; j++) {
                var line = lines[j].trim();
                
                if (line.startsWith("POWER_SUPPLY_MODEL_NAME=")) {
                    var model = line.replace("POWER_SUPPLY_MODEL_NAME=", "").trim();
                    if (model && model !== "") {
                        device.name = model;
                    }
                } else if (line.startsWith("POWER_SUPPLY_CAPACITY=")) {
                    var capacity = line.replace("POWER_SUPPLY_CAPACITY=", "");
                    var pct = parseInt(capacity);
                    if (!isNaN(pct)) {
                        device.percentage = pct;
                    }
                } else if (line.startsWith("POWER_SUPPLY_MANUFACTURER=")) {
                    var manufacturer = line.replace("POWER_SUPPLY_MANUFACTURER=", "").trim();
                    if (manufacturer && manufacturer !== "" && device.name !== "Unknown Device") {
                        device.name = manufacturer + " " + device.name;
                    }
                }
            }
            
            // Normalize name for deduplication
            var normalizedName = root.normalizeDeviceName(device.name);
            
            // Skip if we already processed a device with this normalized name
            if (processedNormalizedNames[normalizedName]) continue;
            
            // Determine icon based on device name
            var nameLower = device.name.toLowerCase();
            if (nameLower.includes("mouse") || nameLower.includes("mice")) {
                device.icon = "mouse";
            } else if (nameLower.includes("keyboard") || nameLower.includes("key")) {
                device.icon = "keyboard";
            } else if (nameLower.includes("controller") || nameLower.includes("gamepad") || nameLower.includes("game")) {
                device.icon = "gamepad";
            } else if (nameLower.includes("headset") || nameLower.includes("headphone") || nameLower.includes("ear") || nameLower.includes("buds")) {
                device.icon = "headphones";
            } else if (nameLower.includes("speaker")) {
                device.icon = "speaker";
            } else if (nameLower.includes("pen") || nameLower.includes("stylus")) {
                device.icon = "edit";
            } else if (nameLower.includes("tablet")) {
                device.icon = "tablet";
            } else if (nameLower.includes("phone") || nameLower.includes("mobile")) {
                device.icon = "smartphone";
            } else if (nameLower.includes("watch")) {
                device.icon = "watch";
            }
            
            // Add device if valid
            if (device.name !== "Unknown Device" || device.percentage > 0) {
                devices.push(device);
                processedNormalizedNames[normalizedName] = true;
            }
        }
    }
    
    function parseUpowerDevices(output, devices, processedNormalizedNames) {
        var sections = output.split("\n\n");
        
        for (var i = 0; i < sections.length; i++) {
            var section = sections[i].trim();
            
            // Skip if no content
            if (!section || section.length < 10) continue;
            
            // Skip main system batteries
            if (section.includes("battery_BAT")) continue;
            if (section.includes("/org/freedesktop/UPower/devices/battery_BAT")) continue;
            
            // Check if this section represents a battery-powered device
            var hasNativePath = section.includes("native-path:");
            var hasPercentage = section.match(/percentage:\s*\d+/) !== null;
            var isDisplay = section.match(/type:\s*Display/) !== null;
            
            // Skip if doesn't meet criteria or has null native-path
            if (!hasNativePath || !hasPercentage || isDisplay) continue;
            
            // Check for null/invalid native-path
            var nativePathMatch = section.match(/native-path:\s*(.+)/);
            if (nativePathMatch && nativePathMatch[1].trim() === "(null)") continue;
            
            var device = {
                name: "Unknown Device",
                percentage: 0,
                icon: "devices_other"
            };
            
            var lines = section.split("\n");
            
            for (var j = 0; j < lines.length; j++) {
                var line = lines[j].trim();
                
                if (line.startsWith("model:")) {
                    var modelName = line.replace("model:", "").trim();
                    if (modelName && modelName !== "") {
                        device.name = modelName;
                    }
                } else if (line.startsWith("percentage:")) {
                    var pctMatch = line.match(/(\d+)/);
                    if (pctMatch) {
                        device.percentage = parseInt(pctMatch[1]);
                    }
                }
            }
            
            // Try to get a better name from the device path if model is unknown
            if (device.name === "Unknown Device") {
                var pathMatch = section.match(/\/org\/freedesktop\/UPower\/devices\/([^\n\s]+)/);
                if (pathMatch) {
                    var deviceId = pathMatch[1];
                    deviceId = deviceId.replace(/^battery_/, "").replace(/^hid_/, "");
                    device.name = deviceId.replace(/_/g, " ").replace(/\b\w/g, function(l) { return l.toUpperCase(); });
                }
            }
            
            // Normalize name for deduplication
            var normalizedName = root.normalizeDeviceName(device.name);
            
            // Skip if already processed from sysfs (same normalized name)
            if (processedNormalizedNames[normalizedName]) continue;
            
            // Determine icon based on device name
            var nameLower = device.name.toLowerCase();
            if (nameLower.includes("mouse") || nameLower.includes("mice")) {
                device.icon = "mouse";
            } else if (nameLower.includes("keyboard") || nameLower.includes("key")) {
                device.icon = "keyboard";
            } else if (nameLower.includes("controller") || nameLower.includes("gamepad") || nameLower.includes("game")) {
                device.icon = "gamepad";
            } else if (nameLower.includes("headset") || nameLower.includes("headphone") || nameLower.includes("ear") || nameLower.includes("buds")) {
                device.icon = "headphones";
            } else if (nameLower.includes("speaker")) {
                device.icon = "speaker";
            } else if (nameLower.includes("pen") || nameLower.includes("stylus")) {
                device.icon = "edit";
            } else if (nameLower.includes("tablet")) {
                device.icon = "tablet";
            } else if (nameLower.includes("phone") || nameLower.includes("mobile")) {
                device.icon = "smartphone";
            } else if (nameLower.includes("watch")) {
                device.icon = "watch";
            }
            
            // Add device if valid
            if (device.percentage >= 0) {
                devices.push(device);
                processedNormalizedNames[normalizedName] = true;
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
        interval: 10000 // 10 seconds
        running: root.hasBattery
        repeat: true
        triggeredOnStart: false
        onTriggered: root.updateBatteryStatus()
    }
    
    property Timer deviceCheckTimer: Timer {
        interval: 120000 // 2 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateConnectedDevices()
    }
    
    property Timer powerProfileTimer: Timer {
        interval: 5000 // 5 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updatePowerProfile()
    }
    
    property Timer presenceCheckTimer: Timer {
        interval: 30000 // Check every 30 seconds if battery appears/disappears
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.checkBatteryPresence()
    }
    
    Component.onCompleted: {
        checkBatteryPresence();
        
        // Check for powerprofilesctl binary
        ProcessService.run(["bash", "-c", "which powerprofilesctl"], function(output) {
            root.hasPowerProfilesCtl = output.trim() !== "";
            if (root.hasPowerProfilesCtl) {
                updatePowerProfile();
            }
        });
        
        updateConnectedDevices();
    }
}
