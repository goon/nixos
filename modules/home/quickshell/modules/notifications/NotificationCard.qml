import ".."
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs

BaseBlock {
    id: root

    property var notification: null
    property real progress: 0
    property bool showCloseButton: true
    property var time: new Date()
    property string timeString: "now"
    property int density: Preferences.notificationDensity
    readonly property bool compactMode: density === 0

    signal closeClicked()

    function updateTime() {
        if (!time)
            return ;

        timeString = Qt.formatDateTime(time, "hh:mm");
    }

    borderEnabled: true
    borderWidth: 1
    borderColor: Theme.colors.border
    padding: 0
    onTimeChanged: root.updateTime()

    Component.onCompleted: root.updateTime()
    Layout.fillWidth: true
    implicitWidth: 350

    // Inner Content Block
    Rectangle {
        property real innerPadding: root.compactMode ? Theme.geometry.spacing.small : Theme.geometry.spacing.dynamicPadding

        Layout.fillWidth: true

        Layout.preferredHeight: notifContent.implicitHeight + (innerPadding * 2)
        color: Theme.alpha(Theme.colors.surface, Theme.blur.surfaceOpacity)
        radius: Theme.geometry.radius

        ColumnLayout {
            id: notifContent

            anchors.fill: parent
            anchors.margins: parent.innerPadding
            spacing: root.compactMode ? Theme.geometry.spacing.small : Theme.geometry.spacing.medium


            // Progress Bar (inset)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                color: Theme.colors.transparent
                visible: root.progress > 0
                clip: true
                radius: Theme.geometry.radius * 0.2

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * root.progress
                    color: {
                        if (!root.notification)
                            return Theme.colors.primary;

                        const text = (root.notification.summary + " " + root.notification.appName).toLowerCase();
                        if (text.includes("error") || text.includes("fail") || text.includes("alert"))
                            return Theme.colors.error;

                        if (text.includes("warn") || text.includes("low") || text.includes("weak"))
                            return Theme.colors.warning;

                        if (text.includes("success") || text.includes("complete") || text.includes("update"))
                            return Theme.colors.success;

                        return Theme.colors.primary;
                    }
                }

            }

            // Top section: Icon, Info, Close
            RowLayout {
                Layout.fillWidth: true
                spacing: root.compactMode ? Theme.geometry.spacing.small : Theme.geometry.spacing.large
                Layout.alignment: Qt.AlignTop


                // App icon
                Rectangle {
                    Layout.preferredWidth: root.compactMode ? 24 : headerCol.height
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: root.compactMode ? Qt.AlignVCenter : Qt.AlignTop

                    color: Theme.colors.transparent
                    radius: 0

                    function resolveSource(src) {
                        return LauncherService.resolveIcon(src);
                    }

                    // 1. Specific Image (Hightest Priority)
                    // e.g. User Avatar, Album Art
                    Image {
                        id: specificImage
                        anchors.centerIn: parent
                        width: Math.min(root.compactMode ? 20 : Theme.dimensions.iconLarge, parent.width - 4)
                        height: width

                        source: parent.resolveSource(root.notification ? root.notification.image : "")
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        visible: status === Image.Ready && source.toString() !== ""
                    }

                    // 2. App Icon (Middle Priority)
                    // e.g. Discord Logo, Spotify Logo
                    // Visible if Specific Image is missing or failed to load
                    Image {
                        id: appIconImage
                        anchors.centerIn: parent
                        width: Math.min(root.compactMode ? 20 : Theme.dimensions.iconLarge, parent.width - 4)
                        height: width

                        source: parent.resolveSource(root.notification ? root.notification.appIcon : "")
                        sourceSize.width: width
                        sourceSize.height: height
                        smooth: true
                        visible: !specificImage.visible && status === Image.Ready && source.toString() !== ""
                    }

                    // 3. Material Symbol (Custom Fallback)
                    // Visible if appIcon or image starts with 'symbol:'
                    Text {
                        id: symbolIcon
                        anchors.centerIn: parent
                        font.pixelSize: root.compactMode ? 16 : Theme.dimensions.iconMedium
                        font.family: Theme.typography.iconFamily
                        text: {
                            if (!root.notification) return "";
                            const ai = root.notification.appIcon || "";
                            const img = root.notification.image || "";
                            
                            function extract(s) {
                                if (s.startsWith("symbol:")) return s.substring(7);
                                const idx = s.indexOf("symbol:");
                                if (idx !== -1) return s.substring(idx + 7);
                                return "";
                            }
                            
                            const res = extract(ai);
                            if (res) return res;
                            return extract(img);
                        }
                        visible: text !== ""
                        color: Theme.colors.primary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        z: 10
                    }

                    // 4. Icon Fallback (Lowest Priority)
                    // Visible if NO images or symbols are loaded
                    BaseIcon {
                        anchors.centerIn: parent
                        visible: !specificImage.visible && !appIconImage.visible && !symbolIcon.visible
                        icon: "notifications_unread"
                        size: root.compactMode ? 16 : Theme.dimensions.iconMedium
                        width: size
                        height: size
                        color: Theme.colors.primary
                    }
                }

                // Header info: App name and Summary
                ColumnLayout {
                    id: headerCol
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0

                    // App name
                    BaseText {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 100 // Hint to help Layout
                        color: Theme.colors.text
                        visible: !root.compactMode
                        text: (root.notification ? (root.notification.appName || "Notification").toUpperCase() : "") + " • " + root.timeString.toUpperCase()
                        elide: Text.ElideRight
                        pixelSize: Theme.typography.size.small
                    }


                    // Summary
                    BaseText {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 // Hint to help Layout
                        color: Theme.colors.text
                        pixelSize: root.compactMode ? Theme.typography.size.medium : Theme.typography.size.large
                        weight: Theme.typography.weights.bold
                        text: root.notification ? (root.notification.summary || "") : ""
                        wrapMode: Text.Wrap
                        maximumLineCount: root.compactMode ? 1 : 2
                        elide: Text.ElideRight
                    }


                }

                // Close button
                BaseButton {
                    Layout.preferredWidth: Theme.dimensions.iconMedium
                    Layout.preferredHeight: Theme.dimensions.iconMedium
                    Layout.alignment: Qt.AlignTop
                    visible: root.showCloseButton
                    icon: "close"
                    iconColor: containsMouse ? Theme.colors.surface : Theme.colors.error
                    normalColor: Theme.colors.transparent
                    hoverColor: Theme.colors.error
                    size: Theme.typography.size.large
                    onClicked: root.closeClicked()
                }

            }

            // Body section: Spans full width
            BaseText {
                Layout.fillWidth: true
                Layout.preferredWidth: 200 // Hint to help Layout
                color: Theme.colors.text
                bold: false
                text: root.notification ? (root.notification.body || "") : ""
                wrapMode: Text.Wrap
                maximumLineCount: 8
                elide: Text.ElideRight
                visible: text !== "" && !root.compactMode
            }


        }

    }

}
