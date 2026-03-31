import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
pragma Singleton

Item {
    // Removed direct calls to prevent startup freeze

    id: root

    property real brightness: 0.5
    // Internal state
    property int _targetBrightness: -1
    property bool _brightnessUpdating: false
    // Detected backend: "ddcutil" or "brightnessctl"
    property string backend: "ddcutil"
    // Detected monitor bus
    property string monitorBus: ""

    function getBrightness() {
        if (root.backend === "brightnessctl") {
            ProcessService.run(["brightnessctl", "g", "-m"], function(output) {
                var parts = output.trim().split(",");
                if (parts.length >= 4) {
                    var current = parseInt(parts[2]);
                    var max = parseInt(parts[4]);
                    if (max > 0)
                        root.brightness = current / max;
                }
            });
        } else if (root.monitorBus !== "") {
            // Explicit bus and fast read flags
            ProcessService.run(["ddcutil", "getvcp", "10", "--bus", root.monitorBus, "--terse", "--sleep-multiplier", "0.01"], function(output) {
                var parts = output.trim().split(" ");
                // Terse output for getvcp 10 (brightness) is: VCP 10 C <current> M <max>
                if (parts.length >= 5) {
                    var current = parseInt(parts[3]);
                    var max = parseInt(parts[4]);
                    if (max > 0)
                        root.brightness = current / max;
                }
            });
        }
    }

    function setBrightness(value) {
        root.brightness = value;
        root._targetBrightness = Math.round(value * 100);
        brightnessUpdateTimer.restart();
    }

    function detectMonitor() {
        ProcessService.run(["ddcutil", "detect", "--terse"], function(output) {
            var lines = output.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                // Terse ddcutil output looks like: I2C bus: /dev/i2c-9
                if (line.includes("I2C bus:")) {
                    var match = line.match(/\/dev\/i2c-(\d+)/);
                    if (match && match[1]) {
                        root.monitorBus = match[1];
                        root.getBrightness();
                        return;
                    }
                }
            }
        });
    }

    function detectBackend() {
        // First check for brightnessctl and active backlights
        ProcessService.run(["which", "brightnessctl"], function(output) {
            if (output.trim() !== "") {
                ProcessService.run(["brightnessctl", "-l", "-m"], function(devOutput) {
                    if (devOutput.trim() !== "" && devOutput.includes("backlight")) {
                        root.backend = "brightnessctl";
                        root.getBrightness();
                    } else {
                        root.backend = "ddcutil";
                        root.detectMonitor();
                    }
                });
            } else {
                root.backend = "ddcutil";
                root.detectMonitor();
            }
        });
    }

    Component.onCompleted: {
    }

    // High-performance brightness updates
    Timer {
        id: brightnessUpdateTimer

        interval: 150 // Increased from 20ms to reduce TTY pressure
        onTriggered: {
            if (root._brightnessUpdating || root._targetBrightness === -1)
                return ;

            var val = root._targetBrightness;
            root._targetBrightness = -1;
            root._brightnessUpdating = true;

            if (root.backend === "brightnessctl") {
                ProcessService.run(["brightnessctl", "s", val + "%"], function() {
                    root._brightnessUpdating = false;
                    if (root._targetBrightness !== -1)
                        brightnessUpdateTimer.restart();
                });
            } else if (root.monitorBus !== "") {
                ProcessService.run(["ddcutil", "setvcp", "10", val.toString(), "--bus", root.monitorBus, "--sleep-multiplier", "0.05", "--noverify", "--async"], function() {
                    root._brightnessUpdating = false;
                    if (root._targetBrightness !== -1)
                        brightnessUpdateTimer.restart();

                });
            } else {
                root._brightnessUpdating = false;
            }
        }
    }

    Timer {
        id: initTimer

        interval: 2000 // Wait 2s after startup to do heavy ddcutil scan
        running: true
        repeat: false
        onTriggered: {
            root.detectBackend();
        }
    }

}
