import qs
import QtQuick
import Quickshell

/**
 * BaseLazyLoader - Optimized loader for shell modules
 * Handles asynchronous loading and ensures the item is toggled once ready.
 */
Item {
    id: root

    property alias source: loader.source
    property alias item: loader.item
    property alias status: loader.status
    property alias active: loader.active

    function toggle() {
        if (!loader.active)
            loader.active = true;

        if (loader.status === Loader.Ready) {
            loader.item.toggle();
        } else {
            var connection = loader.statusChanged.connect(function() {
                if (loader.status === Loader.Ready) {
                    loader.item.toggle();
                    loader.statusChanged.disconnect(connection);
                }
            });
        }
    }

    function close() {
        if (loader.active && loader.status === Loader.Ready)
            loader.item.close();

    }

    Loader {
        id: loader

        active: false
        anchors.fill: parent
    }

}
