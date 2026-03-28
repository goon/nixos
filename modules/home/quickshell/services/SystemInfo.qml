import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {

    id: root

    // Exposed properties
    property string username: ""
    property string hostname: ""
    property string uptime: ""
    property string kernelVersion: ""
    property string cpuModel: "..."
    property string gpuModel: "..."
    property string osName: "..."
    property string de: "..."
    property string wm: "..."
    // Specs process (Run once)
    property var specsProcess
    // Fast process for uptime/hostname
    property var userInfoProcess
    property var refreshTimer
    property var startupTimer

    Component.onCompleted: {
    }
    Component.onDestruction: {
        refreshTimer.stop();
        if (userInfoProcess.running)
            userInfoProcess.running = false;

    }

    specsProcess: Process {
        id: specsProcess

        command: ["bash", "-c", "cat /etc/os-release | grep '^PRETTY_NAME=' | cut -d'\"' -f2; lscpu | grep 'Model name' | cut -d':' -f2 | sed 's/^[ \t]*//'; { if command -v lspci >/dev/null; then lspci | grep -i 'vga\\|display' | cut -d':' -f3; elif command -v glxinfo >/dev/null; then glxinfo 2>/dev/null | grep -i 'device:' | cut -d':' -f2-; else echo '...'; fi; } | sed 's/^[ \t]*//' | tr '\\n' '|'; echo ''; echo $XDG_CURRENT_DESKTOP; echo $XDG_SESSION_DESKTOP; echo 'END'"]
        running: false

        stdout: SplitParser {
            splitMarker: "END\n"
            onRead: (data) => {
                var lines = data.trim().split('\n');
                if (lines.length >= 5) {
                    root.osName = lines[0].trim();
                    root.cpuModel = lines[1].trim();
                    // GPU Priority: NVIDIA > AMD > Intel > Other
                    var gpus = (lines[2] || "").split('|').filter((g) => {
                        return g.trim().length > 0;
                    });
                    var discrete = gpus.find((g) => {
                        return g.includes("NVIDIA");
                    }) || gpus.find((g) => {
                        return g.includes("Radeon") || g.includes("AMD");
                    }) || gpus.find((g) => {
                        return !g.includes("Intel");
                    });
                    var cleanGpu = (name) => {
                        var n = name.trim();
                        // Vendor replacement
                        var vendor = "";
                        if (n.match(/Advanced Micro Devices|AMD\/ATI/i))
                            vendor = "AMD";
                        else if (n.match(/NVIDIA/i))
                            vendor = "NVIDIA";
                        else if (n.match(/Intel/i))
                            vendor = "Intel";
                        // Clean up revs first to avoid matching them if they were brackets (usually parens though)
                        n = n.replace(/\(rev.*?\)/gi, "");
                        n = n.replace(/\(.*?(?:DRM|mesa|ACO|radeonsi|navi).*?\)/gi, "");
                        n = n.replace(/\(0x[0-9a-fA-F]+\)$/gi, "");
                        // Find all [...] content
                        // Global match to get all groups
                        var matches = n.match(/\[([^\]]+)\]/g);
                        // If we found brackets, usually the last one is the specific marketing model
                        if (matches && matches.length > 0) {
                            var content = matches[matches.length - 1]; // Get last "[...]"
                            content = content.replace(/^\[|\]$/g, "").trim(); // Remove braces
                            // If it contains slashes, it's often a list of models e.g. "RX 7900 XT/7900 XTX"
                            // We take the first one.
                            if (content.indexOf('/') !== -1)
                                content = content.split('/')[0].trim();

                            // If it's a useful string, use it
                            if (content.length > 2)
                                n = content;

                        }
                        // Clean up
                        n = n.replace(/Radeon/g, "").replace(/Corporation/g, "").replace(/Integrated Graphics Controller/g, "IGP").replace(/\s+/g, ' ').trim();
                        // Re-add vendor if missing
                        if (vendor && !n.toUpperCase().startsWith(vendor))
                            n = vendor + " " + n;

                        return n;
                    };
                    root.gpuModel = cleanGpu(discrete || gpus[0] || "...");
                    root.de = lines[3].trim() || "N/A";
                    root.wm = lines[4].trim() || "N/A";
                }
            }
        }

    }

    userInfoProcess: Process {
        id: userInfoProcess

        command: ["bash", "-c", "echo $(whoami); uname -n; awk '{print int($1)}' /proc/uptime; uname -r; echo 'END'"]
        running: false
        stderr: null

        stdout: SplitParser {
            splitMarker: "END\n"
            onRead: (data) => {
                var lines = data.trim().split('\n');
                if (lines.length >= 4) {
                    root.username = lines[0].trim();
                    root.hostname = lines[1].trim();
                    var totalSeconds = parseInt(lines[2].trim());
                    var h = Math.floor(totalSeconds / 3600);
                    var m = Math.floor((totalSeconds % 3600) / 60);
                    var s = totalSeconds % 60;
                    var pad = (n) => {
                        return n < 10 ? "0" + n : n;
                    };
                    root.uptime = pad(h) + ":" + pad(m) + ":" + pad(s);
                    root.kernelVersion = lines[3].trim();
                }
            }
        }

    }

    refreshTimer: Timer {
        interval: 1000 // 1 second for seconds in uptime
        running: false // Wait for startupTimer
        repeat: true
        triggeredOnStart: false
        onTriggered: userInfoProcess.running = true
    }

    startupTimer: Timer {
        id: startupTimer

        interval: 1000 // 1s delay
        running: true
        repeat: false
        onTriggered: {
            refreshTimer.running = true;
            userInfoProcess.running = true;
            specsProcess.running = true;
        }
    }

}
