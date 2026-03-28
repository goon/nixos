import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

BaseBlock {
    id: root

    function syncModel() {
        const source = Compositor.windows;
        if (!source)
            return ;

        // 1. Remove items not in source
        for (let i = winModel.count - 1; i >= 0; i--) {
            let item = winModel.get(i);
            if (!source.find((w) => {
                return w.id === item.id;
            }))
                winModel.remove(i);

        }
        // 2. Add/Move/Update items
        for (let i = 0; i < source.length; i++) {
            let win = source[i];
            let existingIdx = -1;
            for (let j = 0; j < winModel.count; j++) {
                if (winModel.get(j).id === win.id) {
                    existingIdx = j;
                    break;
                }
            }
            if (existingIdx === -1) {
                winModel.insert(i, {
                    "id": win.id,
                    "appId": win.appId,
                    "title": win.title,
                    "isFocused": win.isFocused
                });
            } else {
                if (existingIdx !== i)
                    winModel.move(existingIdx, i, 1);

                winModel.set(i, {
                    "isFocused": win.isFocused,
                    "appId": win.appId,
                    "title": win.title
                });
            }
        }
    }

    visible: Compositor.windows.length > 0
    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: false
    paddingHorizontal: Theme.geometry.spacing.small
    paddingVertical: 0
    implicitHeight: 32
    // Sync on model change or initial load
    Component.onCompleted: syncModel()

    ListModel {
        id: winModel
    }

    Timer {
        id: debounceTimer

        interval: 10
        onTriggered: syncModel()
    }

    Connections {
        function onWindowsChanged() {
            debounceTimer.restart();
        }

        target: Compositor
    }

    ListView {
        id: listView

        Layout.alignment: Qt.AlignCenter
        orientation: ListView.Horizontal
        spacing: Theme.geometry.spacing.small
        interactive: false
        model: winModel
        implicitWidth: contentWidth
        implicitHeight: 32

        delegate: Item {
            id: windowItem

            readonly property bool isHovered: mouseArea.containsMouse
            readonly property bool isFocused: model.isFocused

            implicitHeight: 32
            implicitWidth: 32

            Image {
                id: icon

                anchors.centerIn: parent
                source: LauncherService.resolveIcon(model.appId) || "image://qsimage/application-x-executable"
                sourceSize: Qt.size(64, 64)
                width: Theme.dimensions.iconBase
                height: Theme.dimensions.iconBase
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                scale: (isFocused || isHovered) ? 1.2 : 1
                opacity: (isFocused || isHovered) ? 1 : 0.6

                Behavior on scale {
                    BaseAnimation {
                        speed: "fast"
                    }

                }

                Behavior on opacity {
                    BaseAnimation {
                        speed: "fast"
                    }

                }

            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Compositor.focusWindow(model.id)
            }

        }

        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: Theme.animations.normal
                easing.type: Easing.OutQuad
            }

        }

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.animations.fast
            }

            NumberAnimation {
                property: "scale"
                from: 0
                to: 1
                duration: Theme.animations.fast
                easing.type: Easing.OutBack
            }

        }

        remove: Transition {
            NumberAnimation {
                property: "opacity"
                to: 0
                duration: Theme.animations.fast
            }

            NumberAnimation {
                property: "scale"
                to: 0
                duration: Theme.animations.fast
            }

        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: Theme.animations.normal
                easing.type: Easing.OutQuad
            }

        }

    }

}
