import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs
pragma Singleton

Singleton {
    // No-op for compatibility, as native bindings update automatically

    id: root

    property var adapter: Bluetooth.defaultAdapter
    property bool powered: adapter ? adapter.enabled : false
    property bool scanning: adapter ? adapter.discovering : false
    property var devices: adapter ? adapter.devices.values : []
    property int connectedCount: {
        var count = 0;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].connected) count++;
        }
        return count;
    }

    function togglePower() {
        if (adapter)
            adapter.enabled = !adapter.enabled;

    }

    function toggleScan() {
        if (adapter)
            adapter.discovering = !adapter.discovering;

    }

    function connectDevice(address) {
        var dev = findDevice(address);
        if (dev) {
            dev.trusted = true; // Ensure persistent record
            if (!dev.paired && !dev.bonded) {
                dev.pair();
            } else {
                dev.connect();
            }
        }

    }

    function disconnectDevice(address) {
        var dev = findDevice(address);
        if (dev)
            dev.disconnect();

    }

    function removeDevice(address) {
        var dev = findDevice(address);
        if (dev)
            dev.forget();

    }

    function findDevice(address) {
        if (!adapter)
            return null;

        var list = adapter.devices.values;
        for (var i = 0; i < list.length; i++) {
            if (list[i].address === address)
                return list[i];

        }
        return null;
    }

    function refresh() {
    }

}
