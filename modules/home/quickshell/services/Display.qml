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
    // Constant for the detected monitor bus to speed up ddcutil
    readonly property string monitorBus: "20"

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
        } else {
            // Explicit bus and fast read flags
            ProcessService.run(["ddcutil", "--bus", root.monitorBus, "getvcp", "10", "--terse", "--sleep-multiplier", "0.01"], function(output) {
                var parts = output.trim().split(" ");
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
                        root.getBrightness();
                    }
                });
            } else {
                root.backend = "ddcutil";
                root.getBrightness();
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
            } else {
                ProcessService.run(["ddcutil", "--bus", root.monitorBus, "setvcp", "10", val.toString(), "--sleep-multiplier", "0.05", "--noverify", "--async"], function() {
                    root._brightnessUpdating = false;
                    if (root._targetBrightness !== -1)
                        brightnessUpdateTimer.restart();

                });
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
