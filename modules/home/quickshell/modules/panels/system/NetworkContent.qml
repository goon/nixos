import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.geometry.spacing.large
    Layout.fillWidth: true

    // Auto-scan while popout is open and Wi-Fi is selected
    Timer {
        id: scanTimer
        interval: 10000 // 10 seconds
        repeat: true
        running: root.visible && Network.wifiEnabled && interfaceToggle.currentIndex === 1
        triggeredOnStart: true
        onTriggered: Network.scan()
    }

    // --- ACTIVE INTERFACE TOGGLE ---
    BaseBlock {
        id: interfaceToggle
        Layout.fillWidth: true
        padding: 4
        blockRadius: Theme.geometry.radius

        property int selectedTab: -1
        readonly property int currentIndex: selectedTab !== -1 ? selectedTab : (Network.wifiEnabled ? 1 : 0)

        BaseMultiButton {
            id: multiButton
            model: [
                { text: "Ethernet", icon: "lan" },
                { text: "Wi-Fi", icon: "wifi" }
            ]
            selectedIndex: interfaceToggle.currentIndex
            buttonCustomRadius: interfaceToggle.blockRadius - interfaceToggle.padding
            onButtonClicked: (index) => {
                interfaceToggle.selectedTab = index;
            }
        }
    }

    // --- ACTIVE CONNECTION HERO (Ethernet Only) ---
    Item {
        id: heroSection
        Layout.fillWidth: true
        visible: interfaceToggle.currentIndex === 0 && Network.ethernetConnected
        height: 180

        Rectangle {
            anchors.fill: parent
            radius: Theme.geometry.radius * 1.5

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                opacity: 0.1
                color: Theme.colors.text
            }

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: Theme.colors.primary }
                GradientStop { position: 1; color: Theme.colors.secondary }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            BaseIcon {
                icon: "lan"
                size: Theme.dimensions.iconExtraLarge
                color: Theme.colors.base
                Layout.alignment: Qt.AlignCenter
            }

            BaseText {
                text: Network.ethernetName
                font.pixelSize: Theme.typography.size.large + 4
                weight: Theme.typography.weights.bold
                color: Theme.colors.base
                Layout.alignment: Qt.AlignCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter
                spacing: 12
                opacity: 0.8

                BaseText {
                    text: Network.ipv4
                    font.pixelSize: Theme.typography.size.base
                    color: Theme.colors.base
                }
            }
        }
    }

    // --- WI-FI BLOCK ---
    BaseBlock {
        title: "Wi-Fi"
        Layout.fillWidth: true
        visible: interfaceToggle.currentIndex === 1

        ColumnLayout {
            id: wifiContent
            Layout.fillWidth: true
            spacing: Theme.geometry.spacing.medium
            visible: Network.wifiEnabled

            readonly property var availableList: {
                var list = [];
                for (var i = 0; i < Network.availableNetworks.length; i++) {
                    var net = Network.availableNetworks[i];
                    if (!net.active) list.push(net);
                }
                return list;
            }

            // --- CONNECTED SECTION ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.medium
                visible: Network.connected

                BaseText {
                    text: "Connected"
                    weight: Theme.typography.weights.bold
                    color: Theme.colors.primary
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.geometry.spacing.medium
                }

                // Connected Wi-Fi Item
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.geometry.radius
                        
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

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 20

                        BaseIcon {
                            icon: "wifi"
                            size: Theme.dimensions.iconMedium
                            Layout.preferredWidth: 20
                            color: Theme.colors.primary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0
                            BaseText {
                                text: Network.ssid
                                font.pixelSize: Theme.typography.size.base
                                weight: Theme.typography.weights.bold
                                color: Theme.colors.text
                            }
                            BaseText {
                                text: (Network.ipv4 ? Network.ipv4 : "No IP") + " - " + Network.signalStrength + "%"
                                font.pixelSize: Theme.typography.size.small
                                color: Theme.alpha(Theme.colors.text, 0.7)
                            }
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: Theme.geometry.spacing.small
                            Layout.alignment: Qt.AlignVCenter
                            
                            BaseButton {
                                text: "Disconnect"
                                textSize: 10
                                textWeight: Theme.typography.weights.bold
                                textColor: Theme.colors.text
                                paddingHorizontal: 16
                                paddingVertical: 8
                                normalColor: Theme.alpha(Theme.colors.error, 0.6)
                                hoverColor: Theme.alpha(Theme.colors.error, 0.8)
                                onClicked: Network.disconnectWifi()
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.geometry.spacing.medium
                visible: wifiContent.availableList.length > 0

                BaseText {
                    text: "Available Networks"
                    weight: Theme.typography.weights.bold
                    color: Theme.colors.primary
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: wifiContent.availableList.length > 0

                Repeater {
                    model: wifiContent.availableList
                    delegate: ColumnLayout {
                        id: delegateRoot
                        property bool expanded: false
                        Layout.fillWidth: true
                        spacing: 0

                        Item {
                            id: networkItem
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            property bool selected: modelData.active
                            property bool hovered: mouseArea.containsMouse || connectButton.containsMouse
                            
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: (!modelData.active) ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    if (modelData.active) return;
                                    if (modelData.secured) {
                                        delegateRoot.expanded = !delegateRoot.expanded;
                                        if (delegateRoot.expanded)
                                            passwordInput.forceActiveFocus();
                                    } else {
                                        Network.connect(modelData.ssid, "");
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.geometry.radius
                                color: networkItem.hovered ? Theme.alpha(Theme.colors.text, 0.05) : Theme.colors.transparent
                                Behavior on color { BaseAnimation { speed: "fast" } }
                                
                                Item {
                                    anchors.fill: parent
                                    visible: networkItem.hovered || delegateRoot.expanded
                                    
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
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 20
                                scale: mouseArea.pressed ? 0.98 : 1.0
                                Behavior on scale { BaseAnimation { speed: "fast" } }

                                Item {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    Layout.alignment: Qt.AlignVCenter
                                    
                                    BaseIcon {
                                        anchors.centerIn: parent
                                        icon: "wifi"
                                        size: Theme.dimensions.iconMedium
                                        color: networkItem.hovered ? Theme.colors.primary : Theme.colors.muted
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 0

                                    BaseText {
                                        Layout.fillWidth: true
                                        text: modelData.ssid
                                        font.pixelSize: Theme.typography.size.base
                                        weight: networkItem.hovered ? Theme.typography.weights.bold : Theme.typography.weights.normal
                                        color: networkItem.hovered ? Theme.colors.text : Theme.colors.muted
                                        elide: Text.ElideRight
                                    }

                                    BaseText {
                                        Layout.fillWidth: true
                                        text: modelData.active ? "Connected" : (modelData.secured ? "Password Protected" : "Open")
                                        font.pixelSize: Theme.typography.size.small
                                        color: networkItem.hovered ? Theme.alpha(Theme.colors.text, 0.7) : Theme.colors.muted
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                RowLayout {
                                    spacing: Theme.geometry.spacing.small
                                    Layout.alignment: Qt.AlignVCenter

                                    BaseButton {
                                        id: connectButton
                                        visible: !modelData.active
                                        text: "Connect"
                                        textSize: 10
                                        textWeight: Theme.typography.weights.bold
                                        textColor: Theme.colors.text
                                        paddingHorizontal: 16
                                        paddingVertical: 8
                                        normalColor: Theme.colors.transparent
                                        hoverColor: Theme.alpha(Theme.colors.text, 0.1)
                                        
                                        onClicked: {
                                            if (modelData.secured) {
                                                delegateRoot.expanded = !delegateRoot.expanded;
                                                if (delegateRoot.expanded)
                                                    passwordInput.forceActiveFocus();
                                            } else {
                                                Network.connect(modelData.ssid, "");
                                            }
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            z: -1
                                            radius: parent.radius
                                            gradient: Gradient {
                                                orientation: Gradient.Horizontal
                                                GradientStop { position: 0; color: Theme.colors.primary }
                                                GradientStop { position: 1; color: Theme.colors.secondary }
                                            }
                                        }
                                    }
                                }

                                BaseIcon {
                                    icon: delegateRoot.expanded ? "expand_less" : "chevron_right"
                                    size: Theme.dimensions.iconMedium
                                    color: Theme.colors.muted
                                    visible: !modelData.active && modelData.secured && !delegateRoot.expanded && !networkItem.hovered
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: delegateRoot.expanded ? passwordBox.implicitHeight + 16 : 0
                            state: delegateRoot.expanded ? "expanded" : "collapsed"
                            clip: true

                            BaseBlock {
                                id: passwordBox
                                anchors.top: parent.top
                                anchors.topMargin: 8
                                anchors.left: parent.left
                                anchors.right: parent.right
                                backgroundColor: Theme.alpha(Theme.colors.surface, 0.5)

                                ColumnLayout {
                                    width: parent.width
                                    spacing: 12

                                    BaseInput {
                                        id: passwordInput
                                        Layout.fillWidth: true
                                        placeholderText: "Password"
                                        echoMode: TextInput.Password
                                        onAccepted: connectBtn.clicked()
                                    }

                                    BaseButton {
                                        id: connectBtn
                                        text: "Connect"
                                        Layout.fillWidth: true
                                        normalColor: Theme.colors.primary
                                        textColor: Theme.colors.text
                                        onClicked: {
                                            Network.connect(modelData.ssid, passwordInput.text);
                                            delegateRoot.expanded = false;
                                            passwordInput.text = "";
                                        }
                                    }
                                }
                            }

                            Behavior on Layout.preferredHeight { BaseAnimation { duration: 300 } }
                        }
                    }
                }

                BaseText {
                    visible: !Network.scanning && Network.availableNetworks.length === 0
                    text: "No networks found or scan needed."
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    color: Theme.colors.muted
                    Layout.topMargin: 20
                }
            }
        }

        headerItem: RowLayout {
            spacing: Theme.geometry.spacing.medium

            BaseIcon {
                icon: Network.wifiEnabled ? "wifi" : "wifi_off"
                iconSize: Theme.dimensions.iconBase
                text: Network.wifiEnabled ? "Enabled" : "Disabled"
                textSize: 12
                color: Network.wifiEnabled ? Theme.colors.primary : Theme.colors.muted
            }

            BaseSwitch {
                checked: Network.wifiEnabled
                onToggled: Network.toggleWifi()
            }
        }
    }
}
