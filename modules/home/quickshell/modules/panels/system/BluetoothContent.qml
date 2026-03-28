import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.geometry.spacing.large
    Layout.fillWidth: true

    function resolveBluetoothIcon(bluezIcon) {
        if (!bluezIcon)
            return "bluetooth";

        switch (bluezIcon) {
        case "audio-card":
        case "audio-headphones":
        case "audio-headset":
            return "headset";
        case "phone":
            return "smartphone";
        case "video-display":
            return "computer";
        case "input-keyboard":
            return "keyboard";
        case "input-mouse":
            return "mouse";
        case "input-gaming":
            return "videogame_asset";
        default:
            return "bluetooth";
        }
    }

    function isResolvable(name, address) {
        if (!name)
            return false;

        var cleanName = name.replace(/[:\-]/g, "").toLowerCase();
        var cleanAddress = address.replace(/[:\-]/g, "").toLowerCase();
        if (cleanName === cleanAddress)
            return false;

        return !/^[0-9a-f]{12}$/.test(cleanName);
    }

    property var availableDevices: {
        var list = [];
        for (var i = 0; i < Bluetooth.devices.length; i++) {
            var dev = Bluetooth.devices[i];
            if (!dev.paired && !dev.bonded && !dev.trusted && root.isResolvable(dev.name, dev.address))
                list.push(dev);
        }
        return list;
    }

    property var pairedDevices: {
        var list = [];
        for (var i = 0; i < Bluetooth.devices.length; i++) {
            var dev = Bluetooth.devices[i];
            if (dev.paired || dev.bonded || dev.trusted)
                list.push(dev);
        }
        return list;
    }

    // --- BLUETOOTH POWER BLOCK ---
    BaseBlock {
        id: powerBlock
        Layout.fillWidth: true
        padding: 4
        blockRadius: Theme.geometry.radius

        BaseMultiButton {
            model: [
                { text: "Disabled", icon: "bluetooth_disabled" },
                { text: "Enabled", icon: "bluetooth" }
            ]
            selectedIndex: Bluetooth.powered ? 1 : 0
            buttonCustomRadius: powerBlock.blockRadius - powerBlock.padding
            onButtonClicked: (index) => {
                if ((index === 1 && !Bluetooth.powered) || (index === 0 && Bluetooth.powered)) {
                    Bluetooth.togglePower();
                }
            }
        }
    }

    // --- SEARCH / SCAN BLOCK ---
    BaseBlock {
        id: bluetoothBlock
        Layout.fillWidth: true
        clip: true
        visible: !!Bluetooth.powered

        ColumnLayout {
            spacing: Theme.geometry.spacing.medium
            Layout.fillWidth: true

            // Search Button
            BaseButton {
                id: searchButton

                property real scanProgress: 0

                Layout.fillWidth: true
                Layout.preferredHeight: 64
                normalColor: Theme.colors.transparent
                hoverEnabled: false
                text: ""
                icon: ""
                onClicked: Bluetooth.toggleScan()
                visible: !!Bluetooth.powered

                Item {
                    anchors.fill: parent
                    z: -2
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.geometry.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Theme.colors.primary }
                            GradientStop { position: 1; color: Theme.colors.secondary }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1.5
                        radius: Theme.geometry.radius - 1.5
                        color: Theme.colors.surface
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.alpha(Theme.colors.primary, 0.08)
                        }
                    }
                }

                BaseText {
                    id: idleLabel
                    anchors.centerIn: parent
                    text: "Search"
                    color: Theme.colors.text
                    pixelSize: searchButton.textSize
                    weight: searchButton.weight
                    opacity: Bluetooth.scanning ? 0.0 : 1.0
                    visible: opacity > 0
                    
                    Behavior on opacity {
                        BaseAnimation { duration: Theme.animations.normal }
                    }
                }

                BaseAnimation {
                    target: searchButton
                    property: "scanProgress"
                    from: 0
                    to: 1
                    duration: 15000
                    running: Bluetooth.scanning
                    easing.type: Easing.Linear
                    onFinished: {
                        if (Bluetooth.scanning)
                            Bluetooth.toggleScan();
                    }
                }

                Canvas {
                    id: scanCanvas
                    anchors.fill: parent
                    z: -1
                    opacity: Bluetooth.scanning ? 1 : 0
                    visible: opacity > 0
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        var r = parent.radius;
                        ctx.beginPath();
                        ctx.moveTo(r, 0);
                        ctx.lineTo(width - r, 0);
                        ctx.arcTo(width, 0, width, r, r);
                        ctx.lineTo(width, height - r);
                        ctx.arcTo(width, height, width - r, height, r);
                        ctx.lineTo(r, height);
                        ctx.arcTo(0, height, 0, height - r, r);
                        ctx.lineTo(0, r);
                        ctx.arcTo(0, 0, r, 0, r);
                        ctx.closePath();
                        ctx.clip();

                        var fillHeight = height * searchButton.scanProgress;
                        var surfaceY = height - fillHeight;
                        ctx.beginPath();
                        ctx.moveTo(-10, height + 10);
                        ctx.lineTo(-10, surfaceY);
                        var amplitude = 6 * Math.sin(searchButton.scanProgress * Math.PI);
                        for (var x = -10; x <= width + 10; x += 5) {
                            var sine = Math.sin(x / 15 + Date.now() / 150) * amplitude;
                            ctx.lineTo(x, surfaceY + sine);
                        }
                        ctx.lineTo(width + 10, height + 10);
                        ctx.closePath();
                        var grad = ctx.createLinearGradient(0, 0, width, 0);
                        grad.addColorStop(0, Theme.colors.primary);
                        grad.addColorStop(1, Theme.colors.secondary);
                        ctx.fillStyle = grad;
                        ctx.fill();
                    }

                    Timer {
                        interval: 16
                        repeat: true
                        running: scanCanvas.visible
                        onTriggered: scanCanvas.requestPaint()
                    }

                    Behavior on opacity {
                        BaseAnimation { duration: 500 }
                    }
                }
            }

            // Paired Devices
            BaseText {
                visible: !!Bluetooth.powered && root.pairedDevices.length > 0
                text: "Paired Devices"
                weight: Theme.typography.weights.bold
                color: Theme.colors.primary
                Layout.fillWidth: true
                Layout.topMargin: Theme.geometry.spacing.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: !!Bluetooth.powered && root.pairedDevices.length > 0

                Repeater {
                    model: root.pairedDevices
                    delegate: deviceDelegate
                }
            }

            // Available Devices
            BaseText {
                visible: !!Bluetooth.powered && root.availableDevices.length > 0
                text: "Available Devices"
                weight: Theme.typography.weights.bold
                color: Theme.colors.primary
                Layout.fillWidth: true
                Layout.topMargin: Theme.geometry.spacing.medium
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: !!Bluetooth.powered && root.availableDevices.length > 0

                Repeater {
                    model: root.availableDevices
                    delegate: deviceDelegate
                }
            }
        }
    }

    Component {
        id: deviceDelegate

        Item {
            id: delegateRoot
            property bool hovered: mouseArea.containsMouse || 
                                 connectButton.containsMouse || 
                                 forgetButton.containsMouse || 
                                 (modelData && modelData.connected)

            Layout.fillWidth: true
            Layout.preferredHeight: 50

            Rectangle {
                id: mainBackground
                anchors.fill: parent
                radius: Theme.geometry.radius
                color: Theme.colors.transparent

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }

                Item {
                    anchors.fill: parent
                    opacity: delegateRoot.hovered ? 1 : 0
                    visible: opacity > 0

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Theme.colors.primary }
                            GradientStop { position: 1; color: Theme.colors.secondary }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1.5
                        radius: parent.parent.radius - 1.5
                        color: Theme.colors.surface

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.alpha(Theme.colors.primary, 0.08)
                            visible: delegateRoot.hovered
                        }
                    }

                    Behavior on opacity { BaseAnimation { } }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: parent.radius - 1
                    visible: delegateRoot.hovered
                    gradient: Gradient {
                        GradientStop { position: 0; color: Theme.alpha(Theme.colors.text, 0.05) }
                        GradientStop { position: 1; color: Theme.colors.transparent }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 20
                    scale: mouseArea.pressed ? 0.98 : 1

                    BaseIcon {
                        icon: root.resolveBluetoothIcon(modelData.icon)
                        color: delegateRoot.hovered ? Theme.colors.primary : Theme.colors.muted
                        size: Theme.dimensions.iconMedium
                        Layout.preferredWidth: 20
                        Layout.alignment: Qt.AlignLeft
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignLeft

                        BaseText {
                            text: modelData.name || modelData.address
                            elide: Text.ElideRight
                            color: delegateRoot.hovered ? Theme.colors.text : Theme.colors.muted
                            weight: delegateRoot.hovered ? Theme.typography.weights.bold : Theme.typography.weights.normal
                        }

                        BaseText {
                            text: modelData.connected ? "Connected" : (modelData.paired || modelData.bonded || modelData.trusted ? "Paired" : "Available")
                            color: delegateRoot.hovered ? Theme.alpha(Theme.colors.text, 0.7) : Theme.colors.muted
                            pixelSize: Theme.typography.size.small
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: Theme.geometry.spacing.small

                        BaseButton {
                            id: connectButton
                            text: modelData.connecting ? "Connecting" : (modelData.connected ? "Disconnect" : "Connect")
                            textSize: 10
                            textWeight: Theme.typography.weights.bold
                            textColor: Theme.colors.text
                            paddingHorizontal: 16
                            paddingVertical: 8
                            normalColor: modelData.connected ? Theme.alpha(Theme.colors.error, 0.6) : Theme.colors.transparent
                            hoverColor: modelData.connected ? Theme.alpha(Theme.colors.error, 0.8) : Theme.alpha(Theme.colors.text, 0.1)
                            onClicked: function(mouse) {
                                if (modelData.connected)
                                    Bluetooth.disconnectDevice(modelData.address);
                                else
                                    Bluetooth.connectDevice(modelData.address);
                            }

                            Rectangle {
                                anchors.fill: parent
                                z: -1
                                radius: parent.radius
                                visible: !modelData.connected
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0; color: Theme.colors.primary }
                                    GradientStop { position: 1; color: Theme.colors.secondary }
                                }
                            }
                        }

                        BaseButton {
                            id: forgetButton
                            visible: modelData.paired || modelData.bonded || modelData.trusted
                            text: "Forget"
                            textSize: 10
                            textWeight: Theme.typography.weights.bold
                            textColor: Theme.colors.text
                            paddingHorizontal: 16
                            paddingVertical: 8
                            normalColor: Theme.alpha(Theme.colors.error, 0.6)
                            hoverColor: Theme.alpha(Theme.colors.error, 0.8)
                            onClicked: Bluetooth.removeDevice(modelData.address)
                        }
                    }

                    Behavior on scale { BaseAnimation { speed: "fast" } }
                }
            }
        }
    }
}
