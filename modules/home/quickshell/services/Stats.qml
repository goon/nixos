pragma Singleton
import QtQuick
import Quickshell
import qs

QtObject {
    id: root

    // --- CPU Statistics ---
    property real currentCpu: 0
    property var cpuHistory: Array(31).fill(0)
    property real currentTemp: 0
    property string cpuTempPath: ""
    property var tempHistory: Array(31).fill(20) // Start at a reasonable 20C
    property var _lastCpu: null
    
    // --- RAM Statistics ---
    property real currentRam: 0
    property string ramText: "0 B / 0 B"
    property var ramHistory: Array(31).fill(0)
    property real memTotalSize: 0
    property string totalRam: formatBytes(memTotalSize * 1024)
    property real memUsedSize: 0

    // --- GPU Statistics ---
    property real currentGpu: 0
    property var gpuHistory: Array(31).fill(0)
    property real currentGpuTemp: 0
    property var gpuTempHistory: Array(31).fill(20)
    property string gpuTempPath: ""
    property string gpuLoadPath: ""

    // --- Network Statistics ---
    property real currentNetworkRx: 0
    property real currentNetworkTx: 0
    property var networkRxHistory: Array(31).fill(0)
    property var networkTxHistory: Array(31).fill(0)
    property var _lastNet: null

    // --- Disk Statistics ---
    property real currentDiskRead: 0
    property real currentDiskWrite: 0
    property var diskReadHistory: Array(31).fill(0)
    property var diskWriteHistory: Array(31).fill(0)
    property var _lastDisk: null
    
    // --- Drive/Partition Information ---
    property var drives: []

    Component.onCompleted: {
        // Broad search for AMD GPU temperature path
        ProcessService.run(["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do if [ -f \"$h/name\" ] && grep -q \"amdgpu\" \"$h/name\"; then echo \"$h/temp1_input\"; break; fi; done"], function(path) {
            if (path && path.trim()) {
                gpuTempPath = path.trim();
                // Predict load path: it's often in device/gpu_busy_percent relative to hwmon, or in the hwmon folder itself
                ProcessService.run(["sh", "-c", "if [ -f \"" + gpuTempPath.replace("temp1_input", "device/gpu_busy_percent") + "\" ]; then echo \"" + gpuTempPath.replace("temp1_input", "device/gpu_busy_percent") + "\"; elif [ -f \"" + gpuTempPath.replace("temp1_input", "gpu_busy_percent") + "\" ]; then echo \"" + gpuTempPath.replace("temp1_input", "gpu_busy_percent") + "\"; fi"], function(loadPath) {
                    if (loadPath && loadPath.trim()) gpuLoadPath = loadPath.trim();
                });
            }
        });

        // Broad search for CPU temperature path
        // Priority: coretemp (hwmon), x86_pkg_temp (thermal_zone), k10temp (AMD CPU), fallback to thermal_zone0
        ProcessService.run(["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do if [ -f \"$h/name\" ]; then name=$(cat \"$h/name\"); if [ \"$name\" = \"coretemp\" ] || [ \"$name\" = \"k10temp\" ]; then for t in \"$h\"/temp*_input; do if [ -f \"$t\" ]; then label_file=\"${t%_input}_label\"; if [ ! -f \"$label_file\" ] || grep -qiE \"package|die|tctl\" \"$label_file\"; then echo \"$t\"; exit 0; fi; fi; done; fi; fi; done; for t in /sys/class/thermal/thermal_zone*; do if [ -f \"$t/type\" ] && grep -qiE \"x86_pkg_temp|cpu|pkg\" \"$t/type\"; then echo \"$t/temp\"; exit 0; fi; done; echo \"/sys/class/thermal/thermal_zone0/temp\""], function(path) {
            if (path && path.trim()) {
                cpuTempPath = path.trim();
            }
        });
    }

    function parseCpu(data) {
        if (!data) return;
        var lines = data.split("\n");
        if (lines.length === 0) return;
        
        var firstLine = lines[0].trim();
        if (!firstLine.startsWith("cpu ")) return;
        
        var parts = firstLine.split(/\s+/);
        if (parts.length < 5) return;
        
        var idle = parseInt(parts[4]);
        var total = 0;
        for (var i = 1; i < parts.length; i++) {
            total += parseInt(parts[i] || 0);
        }

        if (_lastCpu) {
            var diffIdle = idle - _lastCpu.idle;
            var diffTotal = total - _lastCpu.total;
            var usage = diffTotal > 0 ? (1 - (diffIdle / diffTotal)) : 0;
            currentCpu = usage;
            
            var newHistory = cpuHistory.concat([usage]);
            if (newHistory.length > 31) newHistory.shift();
            cpuHistory = newHistory;
        }

        _lastCpu = { idle: idle, total: total };
    }

    function parseMem(data) {
        if (!data) return;
        var lines = data.split("\n");
        var total = 0, free = 0, cached = 0, buffers = 0, sReclaimable = 0;
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            var parts = line.split(/\s+/);
            if (parts.length < 2) continue;
            if (line.startsWith("MemTotal:")) total = parseInt(parts[1]);
            else if (line.startsWith("MemFree:")) free = parseInt(parts[1]);
            else if (line.startsWith("Cached:")) cached = parseInt(parts[1]);
            else if (line.startsWith("Buffers:")) buffers = parseInt(parts[1]);
            else if (line.startsWith("SReclaimable:")) sReclaimable = parseInt(parts[1]);
        }
        memTotalSize = total;
        memUsedSize = total - free - cached - buffers - sReclaimable;
        currentRam = total > 0 ? (memUsedSize / total) : 0;
        ramText = formatBytes(memUsedSize * 1024) + " / " + formatBytes(total * 1024);
        
        var newHistory = ramHistory.concat([currentRam]);
        if (newHistory.length > 31) newHistory.shift();
        ramHistory = newHistory;
    }

    function parseTemp(data) {
        if (!data) return;
        currentTemp = Math.round(parseInt(data.trim()) / 1000);
        
        var newHistory = tempHistory.concat([currentTemp]);
        if (newHistory.length > 31) newHistory.shift();
        tempHistory = newHistory;
    }

    function parseDiskStat(data) {
        if (!data) return;
        var lines = data.split("\n");
        var readSectors = 0;
        var writeSectors = 0;
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (!line) continue;
            var parts = line.split(/\s+/);
            if (parts.length >= 10) {
                var dev = parts[2];
                // Match physical drives (nvme0n1, sda, vda) and exclude partitions (nvme0n1p1, sda1)
                if (dev && (dev.match(/^(sd[a-z]+|nvme[0-9]+n[0-9]+|vd[a-z]+)$/))) {
                    readSectors += parseInt(parts[5]) || 0;
                    writeSectors += parseInt(parts[9]) || 0;
                }
            }
        }

        if (_lastDisk) {
            var interval = Math.max(0.1, pollTimer.interval / 1000);
            currentDiskRead = (readSectors - _lastDisk.read) * 512 / interval;
            currentDiskWrite = (writeSectors - _lastDisk.write) * 512 / interval;
            
            var newReadHistory = diskReadHistory.concat([currentDiskRead]);
            if (newReadHistory.length > 30) newReadHistory.shift();
            diskReadHistory = newReadHistory;

            var newWriteHistory = diskWriteHistory.concat([currentDiskWrite]);
            if (newWriteHistory.length > 30) newWriteHistory.shift();
            diskWriteHistory = newWriteHistory;
        }
        _lastDisk = { read: readSectors, write: writeSectors };
    }

    function parseNet(data) {
        if (!data) return;
        var lines = data.split("\n");
        var down = 0, up = 0;
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            var colonIndex = line.indexOf(":");
            if (colonIndex === -1) continue;
            
            var interfaceName = line.substring(0, colonIndex).trim();
            if (interfaceName === "lo" || interfaceName.startsWith("vbox") || interfaceName.startsWith("virbr") || interfaceName.startsWith("docker")) continue;
            
            var statsPart = line.substring(colonIndex + 1).trim();
            var parts = statsPart.split(/\s+/);
            if (parts.length >= 9) {
                down += parseInt(parts[0]) || 0;
                up += parseInt(parts[8]) || 0;
            }
        }

        if (_lastNet) {
            var interval = Math.max(0.1, pollTimer.interval / 1000);
            currentNetworkRx = (down - _lastNet.down) / interval;
            currentNetworkTx = (up - _lastNet.up) / interval;
            
            var newRxHistory = networkRxHistory.concat([currentNetworkRx]);
            if (newRxHistory.length > 30) newRxHistory.shift();
            networkRxHistory = newRxHistory;

            var newTxHistory = networkTxHistory.concat([currentNetworkTx]);
            if (newTxHistory.length > 30) newTxHistory.shift();
            networkTxHistory = newTxHistory;
        }
        _lastNet = { down: down, up: up };
    }

    function parseDisk(lsblkData, dfData) {
        if (!lsblkData || !dfData) return;

        var dfStats = {};
        var dfLines = dfData.trim().split("\n");
        for (var i = 1; i < dfLines.length; i++) {
            var parts = dfLines[i].split(/\s+/);
            if (parts.length >= 7) {
                var fs = parts[0];
                if (fs.startsWith("/dev/")) {
                    var devName = fs.substring(5);
                    dfStats[devName] = {
                        "size": parts[2],
                        "used": parts[3],
                        "avail": parts[4],
                        "percent": (parseInt(parts[5].replace("%", "")) || 0) / 100,
                        "filesystem": fs,
                        "type": parts[1]
                    };
                }
            }
        }

        var lsblkJson;
        try {
            lsblkJson = JSON.parse(lsblkData);
        } catch (e) { return; }

        if (!lsblkJson || !lsblkJson.blockdevices) return;

        var allDrives = [];
        for (var j = 0; j < lsblkJson.blockdevices.length; j++) {
            var dev = lsblkJson.blockdevices[j];
            if (dev.name.startsWith("loop") || dev.name.startsWith("ram") || dev.name.startsWith("zram")) continue;
            if (dev.type !== "disk") continue;

            var driveSize = parseInt(dev.size) || 0;
            var drive = {
                "name": dev.name,
                "size": formatBytes(driveSize),
                "totalSizeBytes": driveSize,
                "removable": !!(dev.rm === true || dev.rm === 1 || dev.rm === "1" || dev.rm === "true" || dev.hotplug === true || dev.hotplug === 1 || dev.tran === "usb"),
                "totalUsedBytes": 0,
                "used": "0 B",
                "filesystem": dev.fstype || "Multiple",
                "partitions": []
            };

            if (dev.children) {
                for (var k = 0; k < dev.children.length; k++) {
                    var part = dev.children[k];
                    if (part.type !== "part") continue;

                    var partStats = dfStats[part.name] || null;
                    if (partStats || part.mountpoint || (part.mountpoints && part.mountpoints.length > 0)) {
                        var mount = part.mountpoint || (part.mountpoints && part.mountpoints.length > 0 ? part.mountpoints[0] : "");
                        
                        // Partition Labeling
                        var label = part.label || part.name || "Unknown";
                        if (mount === "/") label = "root";
                        else if (mount === "/home") label = "home";
                        else if (mount === "/boot") label = "boot";
                        else if (mount) {
                            var mountParts = mount.split("/");
                            label = mountParts[mountParts.length - 1] || label;
                        }
                        
                        if (label.length > 15) label = label.substring(0, 12) + "...";

                        // Best guess for drive name if it's currently just a device ID
                        if (drive.name === dev.name || drive.name === "Unknown") {
                            if (mount === "/") drive.name = "System";
                            else if (mount === "/home") drive.name = "Home";
                            else if (mount && !mount.startsWith("/boot")) {
                                var dName = mount.split("/").pop();
                                if (dName) drive.name = dName;
                            }
                        }

                        var uBytes = partStats ? (parseInt(partStats.used) || 0) : 0;
                        var sBytes = parseInt(part.size) || 0;
                        drive.totalUsedBytes += uBytes;

                        drive.partitions.push({
                            "name": part.name,
                            "label": label,
                            "mount": mount,
                            "size": formatBytes(sBytes),
                            "sizeBytes": sBytes,
                            "used": formatBytes(uBytes),
                            "usedBytes": uBytes,
                            "percent": (partStats && !isNaN(partStats.percent)) ? partStats.percent : 0,
                            "filesystem": part.fstype || (partStats ? partStats.type : "Unknown")
                        });
                    }
                }
            }
            // Capitalize drive name for the header
            if (drive.name && drive.name !== dev.name) {
                drive.name = drive.name.charAt(0).toUpperCase() + drive.name.slice(1);
            }
            
            drive.used = formatBytes(drive.totalUsedBytes);
            if (drive.partitions.length > 0) {
                // If only one partition, use its filesystem as the drive's filesystem
                if (drive.partitions.length === 1) {
                    drive.filesystem = drive.partitions[0].filesystem;
                } else {
                    // Try to find a "main" partition (root or home)
                    for (var m = 0; m < drive.partitions.length; m++) {
                        if (drive.partitions[m].mount === "/" || drive.partitions[m].mount === "/home") {
                            drive.filesystem = drive.partitions[m].filesystem;
                            break;
                        }
                    }
                }
                allDrives.push(drive);
            }
        }
        
        allDrives.sort(function(a, b) {
            if (a.removable === b.removable) return a.name.localeCompare(b.name);
            return a.removable ? 1 : -1;
        });
        drives = allDrives;
    }

    function formatBytes(bytes) {
        if (isNaN(bytes) || bytes === 0) return "0 B";
        var k = 1024;
        var sizes = ["B", "KB", "MB", "GB", "TB", "PB"];
        var i = Math.floor(Math.log(Math.abs(bytes)) / Math.log(k));
        if (i < 0) i = 0;
        if (i >= sizes.length) i = sizes.length - 1;
        
        var val = bytes / Math.pow(k, i);
        if (sizes[i] === "TB" || sizes[i] === "PB") {
            return val.toFixed(1) + " " + sizes[i];
        } else {
            return Math.ceil(val) + " " + sizes[i];
        }
    }

    function parseAmdTemp(data) {
        if (!data) return;
        var temp = Math.round(parseInt(data.trim()) / 1000);
        currentGpuTemp = temp;
        
        var newHistory = gpuTempHistory.concat([temp]);
        if (newHistory.length > 31) newHistory.shift();
        gpuTempHistory = newHistory;
    }

    function parseAmdLoad(data) {
        if (!data) return;
        var val = (parseInt(data.trim()) || 0) / 100;
        currentGpu = val;
        
        var newHistory = gpuHistory.concat([val]);
        if (newHistory.length > 31) newHistory.shift();
        gpuHistory = newHistory;
    }

    function updateFast() {
        var tempCmd = root.cpuTempPath ? "cat " + root.cpuTempPath : "[ -f /sys/class/thermal/thermal_zone0/temp ] && cat /sys/class/thermal/thermal_zone0/temp || echo 0";
        var cmd = "cat /proc/stat; echo '---SEP---'; cat /proc/meminfo; echo '---SEP---'; " + tempCmd + "; echo '---SEP---'; cat /proc/net/dev; echo '---SEP---'; cat /proc/diskstats";
        
        if (root.gpuTempPath) cmd += "; echo '---SEP---'; cat " + root.gpuTempPath;
        if (root.gpuLoadPath) cmd += "; echo '---SEP---'; [ -f \"" + root.gpuLoadPath + "\" ] && cat \"" + root.gpuLoadPath + "\" || echo 0";

        ProcessService.run(["sh", "-c", cmd], function(out) {
            if (!out) return;
            var sections = out.split("---SEP---");
            if (sections.length >= 5) {
                parseCpu(sections[0]);
                parseMem(sections[1]);
                parseTemp(sections[2]);
                parseNet(sections[3]);
                parseDiskStat(sections[4]);
                
                if (root.gpuTempPath && sections[5]) parseAmdTemp(sections[5]);
                if (root.gpuLoadPath && sections[6]) parseAmdLoad(sections[6]);
            }
        });
    }

    function updateSlow() {
        var cmd = "lsblk -b -J -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,LABEL,PKNAME,RM,MOUNTPOINTS,HOTPLUG,TRAN; echo '---SEP---'; df -B1 -T";
        ProcessService.run(["sh", "-c", cmd], function(out) {
            if (!out) return;
            var sections = out.split("---SEP---");
            if (sections.length >= 2) {
                parseDisk(sections[0], sections[1]);
            }
        });
    }

    property Timer pollTimer: Timer {
        interval: 500 // 2Hz for faster graph updates
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateFast()
    }

    property Timer slowPollTimer: Timer {
        interval: 10000 // 10s for disk and partition info
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateSlow()
    }
}
