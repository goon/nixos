import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.folderlistmodel
import qs

// Inline folder browser - embed directly as a child component
ColumnLayout {
    id: root

    property string currentFolder: Preferences.wallpaperDirectory ? Preferences.wallpaperDirectory : (StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/Pictures/Wallpapers")
    signal folderSelected(string path)

    spacing: Theme.geometry.spacing.small

    FolderListModel {
        id: folderModel
        folder: {
            var p = root.currentFolder;
            if (p.indexOf("file://") === 0) return p;
            return "file://" + p;
        }
        showFiles: false
        showDirs: true
        showDotAndDotDot: false
    }

    FolderListModel {
        id: fileModel
        folder: folderModel.folder
        showFiles: true
        showDirs: false
        showDotAndDotDot: false
    }

    // Toolbar: up, home, path input, select button
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.geometry.spacing.small

        BaseButton {
            icon: "arrow_upward"
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            onClicked: folderModel.folder = folderModel.parentFolder
        }

        BaseButton {
            icon: "home"
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            onClicked: folderModel.folder = "file://" + StandardPaths.writableLocation(StandardPaths.HomeLocation)
        }

        BaseInput {
            id: pathInput
            Layout.fillWidth: true
            inputPadding: 10
            text: {
                var path = folderModel.folder.toString();
                if (path.indexOf("file://") === 0) path = path.substring(7);
                return path;
            }
            onAccepted: {
                var p = text;
                if (p.indexOf("file://") !== 0) p = "file://" + p;
                folderModel.folder = p;
            }
        }

        BaseButton {
            text: "Select"
            normalColor: Theme.colors.primary
            textColor: Theme.colors.base
            onClicked: {
                var finalPath = folderModel.folder.toString();
                if (finalPath.indexOf("file://") === 0) finalPath = finalPath.substring(7);
                root.folderSelected(finalPath);
            }
        }
    }

    // Split pane: folder list | file preview
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 300
        spacing: folderModel.count > 0 ? Theme.geometry.spacing.medium : 0

        Behavior on spacing {
            BaseAnimation { speed: "normal"; easing.type: Easing.InOutQuad }
        }

        // Left: Folders
        Rectangle {
            Layout.preferredWidth: folderModel.count > 0 ? 200 : 0
            Layout.fillHeight: true
            color: Theme.colors.surface
            radius: Theme.geometry.radius
            clip: true

            Behavior on Layout.preferredWidth {
                BaseAnimation { speed: "normal"; easing.type: Easing.InOutQuad }
            }

            ListView {
                anchors.fill: parent
                anchors.margins: 6
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                clip: true
                model: folderModel

                delegate: BaseButton {
                    width: ListView.view.width
                    height: 36
                    contentAlignment: Qt.AlignLeft
                    paddingHorizontal: Theme.geometry.spacing.large
                    icon: "folder"
                    text: fileName
                    normalColor: Theme.colors.transparent
                    hoverColor: Theme.colors.background
                    onClicked: folderModel.folder = fileUrl
                }
            }
        }

        // Right: Files / Previews
        Rectangle {
            id: previewPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.colors.surface
            radius: Theme.geometry.radius

            // Mask shape for scroll clip rounding
            Rectangle {
                id: previewMask
                anchors.fill: parent
                radius: parent.radius
                visible: false
                layer.enabled: true
            }

            BaseText {
                anchors.centerIn: parent
                text: "No files in this folder"
                color: Theme.colors.muted
                visible: fileModel.count === 0
                z: 1
            }

            // Masked wrapper so scrolling tiles clip to rounded panel corners
            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: previewMask
                }

                GridView {
                    id: previewGrid
                    anchors.fill: parent
                    anchors.margins: Theme.geometry.spacing.small
                    clip: true
                    model: fileModel

                    // Calculate how many columns fit, then divide evenly
                    property int columns: Math.max(1, Math.floor(width / 150))
                    cellWidth: width / columns
                    cellHeight: cellWidth

                delegate: Item {
                    width: previewGrid.cellWidth
                    height: previewGrid.cellHeight

                    property bool isImage: {
                        var n = fileName.toLowerCase();
                        return n.endsWith(".jpg") || n.endsWith(".jpeg") || n.endsWith(".png") || n.endsWith(".webp");
                    }

                    Item {
                        id: tileRoot
                        anchors.fill: parent
                        anchors.margins: 4

                        // Hidden mask shape for MultiEffect
                        Rectangle {
                            id: tileMask
                            anchors.fill: parent
                            radius: Theme.geometry.radius
                            visible: false
                            layer.enabled: true
                        }

                        // Content clipped to rounded shape via MultiEffect mask
                        Item {
                            anchors.fill: parent
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: tileMask
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.colors.surface
                                radius: Theme.geometry.radius
                            }

                            Image {
                                anchors.fill: parent
                                source: tileRoot.parent.isImage ? fileUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true
                                cache: true
                                visible: tileRoot.parent.isImage

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.colors.surface
                                    visible: parent.status !== Image.Ready
                                }
                            }

                            BaseIcon {
                                anchors.centerIn: parent
                                icon: "insert_drive_file"
                                size: Theme.dimensions.iconLarge
                                color: Theme.colors.muted
                                visible: !tileRoot.parent.isImage
                            }

                            // Filename label at bottom
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 22
                                color: Theme.alpha(Theme.colors.base, 0.55)
                                BaseText {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: {
                                        var n = fileName;
                                        var dot = n.lastIndexOf(".");
                                        return dot > 0 ? n.substring(0, dot) : n;
                                    }
                                    color: Theme.colors.text
                                    elide: Text.ElideMiddle
                                    pixelSize: 10
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
  }
}