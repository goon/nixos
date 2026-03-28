import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// Simplified process execution wrapper
 Singleton {
    id: root

    property Component processComponent

    function run(cmd, callback) {
        var p = processComponent.createObject(root, {
            "command": Array.isArray(cmd) ? cmd : [cmd],
            "callback": callback || null,
            "running": true
        });
        return p;
    }

    function runDetached(cmd) {
        run(cmd, null);
    }

    processComponent: Component {
        Process {
            id: proc

            property var callback: null
            property int capturedExitCode: -1
            property Timer cleanupTimer

            onExited: (code) => {
                capturedExitCode = code;
                cleanupTimer.start();
            }

            cleanupTimer: Timer {
                id: cleanupTimer

                interval: 50
                repeat: false
                onTriggered: {
                    if (proc.callback) {
                        try {
                            proc.callback(collector.text, proc.capturedExitCode);
                        } catch (e) {
                            console.warn("ProcessService: Callback error", e);
                        }
                    }
                    proc.destroy();
                }
            }

            stdout: StdioCollector {
                id: collector
            }

        }

    }

}
