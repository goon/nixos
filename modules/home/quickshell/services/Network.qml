pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking
import qs

QtObject {
    id: root

    // Native Networking handles most states reactively for Wi-Fi
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    
    // Find Wi-Fi device natively
    property WifiDevice wifiDevice: {
        var devs = Networking.devices.values;
        for (var i = 0; i < devs.length; i++) {
            var dev = devs[i];
            if (dev && (dev.type === DeviceType.Wifi || DeviceType.toString(dev.type).toLowerCase() === "wifi")) return dev;
        }
        return null;
    }

    // Ethernet properties managed via nmcli fallback (since native API lacks Ethernet support)
    property string ethernetName: ""
    property bool ethernetConnected: false
    readonly property bool ethernetEnabled: ethernetName !== ""

    // Wi-Fi Properties
    readonly property bool connected: wifiDevice ? wifiDevice.connected : false
    readonly property string ssid: (wifiDevice && wifiDevice.connected && wifiDevice.networks.values.length > 0) ? getConnectedSsid() : "Disconnected"
    readonly property int signalStrength: (wifiDevice && wifiDevice.connected) ? getConnectedSignal() : 0
    property string ipv4: ""

    // Scanning & Networks
    property var availableNetworks: []
    property var savedConnections: []
    property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false
    property bool loading: false

    function getConnectedSsid() {
        if (!wifiDevice) return "Disconnected";
        var nets = wifiDevice.networks.values;
        for (var i = 0; i < nets.length; i++) {
            var net = nets[i];
            if (net.connected) return net.name;
        }
        return "Disconnected";
    }

    function getConnectedSignal() {
        if (!wifiDevice) return 0;
        var nets = wifiDevice.networks.values;
        for (var i = 0; i < nets.length; i++) {
            var net = nets[i];
            if (net.connected) return Math.round(net.signalStrength * 100);
        }
        return 0;
    }

    function refresh() {
        // Fetch saved connections
        ProcessService.run(["nmcli", "-t", "-f", "NAME", "connection", "show"], function(out) {
            root.savedConnections = out.split("\n").map(l => l.trim()).filter(l => l !== "");
        });

        // Poll nmcli for full device status including Ethernet (which native API misses)
        ProcessService.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"], function(out) {
            var lines = out.split("\n");
            var ethFound = false;
            
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line === "") continue;
                var parts = line.split(":");
                if (parts.length < 3) continue;
                
                var name = parts[0];
                var type = parts[1];
                var state = parts[2];
                
                if (type === "ethernet") {
                    root.ethernetName = name;
                    root.ethernetConnected = (state === "connected");
                    ethFound = true;
                    
                    if (state === "connected") {
                        ProcessService.run(["nmcli", "-t", "-f", "IP4.ADDRESS", "device", "show", name], function(ipOut) {
                            var ipParts = ipOut.split("\n");
                            for (var j = 0; j < ipParts.length; j++) {
                               var ipLine = ipParts[j].trim();
                               if (ipLine.startsWith("IP4.ADDRESS[")) {
                                   root.ipv4 = ipLine.split(":")[1].split("/")[0];
                                   break;
                               }
                            }
                        });
                    }
                } else if (type === "wifi" && state === "connected") {
                    ProcessService.run(["nmcli", "-t", "-f", "IP4.ADDRESS", "device", "show", name], function(ipOut) {
                        var ipParts = ipOut.split("\n");
                        for (var j = 0; j < ipParts.length; j++) {
                           var ipLine = ipParts[j].trim();
                           if (ipLine.startsWith("IP4.ADDRESS[")) {
                               root.ipv4 = ipLine.split(":")[1].split("/")[0];
                               break;
                           }
                        }
                    });
                }
            }
            if (!ethFound) {
                root.ethernetName = "";
                root.ethernetConnected = false;
                root.ethernetIP = "";
            }
        });

        // Update available networks list via native API
        if (wifiDevice) {
            var nets = [];
            var nativeNets = wifiDevice.networks.values;
            for (var i = 0; i < nativeNets.length; i++) {
                var net = nativeNets[i];
                nets.push({
                    "ssid": net.name,
                    "signal": Math.round(net.signalStrength * 100),
                    "security": net.security,
                    "active": net.connected,
                    "secured": net.security !== WifiSecurityType.Open,
                    "saved": root.savedConnections.indexOf(net.name) !== -1,
                    "native": net
                });
            }
            nets.sort((a, b) => b.signal - a.signal);
            root.availableNetworks = nets;
        }
    }

    function scan() {
        if (wifiDevice) {
            wifiDevice.scannerEnabled = false;
            wifiDevice.scannerEnabled = true;
            root.refresh();
        }
    }

    function connect(ssid, password) {
        if (!wifiDevice) return;
        
        var nativeNets = wifiDevice.networks.values;
        for (var i = 0; i < nativeNets.length; i++) {
            var net = nativeNets[i];
            if (net.name === ssid) {
                if (password) break; 
                net.connect();
                return;
            }
        }
        
        ProcessService.run(["nmcli", "dev", "wifi", "connect", ssid].concat(password ? ["password", password] : []), function() {
            refresh();
        });
    }

    function forget(ssid) {
        if (!wifiDevice) return;
        var nativeNets = wifiDevice.networks.values;
        for (var i = 0; i < nativeNets.length; i++) {
            var net = nativeNets[i];
            if (net.name === ssid) {
                net.forget();
                return;
            }
        }
        ProcessService.run(["nmcli", "connection", "delete", ssid], function() {
            refresh();
        });
    }

    function disconnectWifi() {
        if (!wifiDevice) return;
        ProcessService.run(["nmcli", "device", "disconnect", wifiDevice.name], function() {
            refresh();
        });
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function toggleEthernet() {
        if (ethernetName === "") return;
        var action = ethernetConnected ? "disconnect" : "connect";
        ProcessService.run(["nmcli", "device", action, ethernetName], function() {
            refresh();
        });
    }

    Component.onCompleted: {
        refresh();
        if (wifiDevice) {
            wifiDevice.scannerEnabled = true;
        }
    }

    property Timer refreshTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
