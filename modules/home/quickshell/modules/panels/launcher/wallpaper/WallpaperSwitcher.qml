import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.services
import qs

LauncherTab {
    id: root
    
    // Alias for the 'list view' equivalent, which is the carousel here. 
    property alias listView: carousel

    // Launcher expectation for currentItem
    property var currentItem: {
        if (carousel && carousel.model && carousel.model.length > 0 && carousel.currentIndex >= 0) {
            var path = carousel.model[carousel.currentIndex];
            if (!path) return null;
            var filename = path.split("/").pop();
            return {
                "name": filename,
                "description": path,
                "icon": "image",
                "category": "Wallpaper",
                "type": "wallpaper",
                "path": path
            };
        }
        return null;
    }

    // Explicit count override for robustness
    listCount: (carousel && carousel.model) ? (carousel.model.length || 0) : 0

    function activateCurrentItem() {
        if (root.currentItem) {
            Wallpaper.applyWallpaper(root.currentItem.path);
            root.closeRequested();
        }
    }

    function onActivated() {
    }

    function onLauncherClosed() {
        Wallpaper.ensureScanned();
        Wallpaper.shuffleWallpapers();
        carousel.setRandomIndex();
    }

    Component.onCompleted: {
        Wallpaper.ensureScanned();
        Wallpaper.shuffleWallpapers();
        carousel.setRandomIndex();
    }
    
    // Main Layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: Theme.geometry.spacing.medium

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // Mask Source
            Rectangle {
                id: mask
                anchors.fill: parent
                radius: Theme.geometry.radius
                visible: false
                layer.enabled: true
                color: Theme.colors.text
            }

            // Masked Container
            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: mask
                }

                WallpaperCarousel {
                    id: carousel
                    anchors.fill: parent

                    borderRadius: Theme.geometry.radius
                    
                    centerHeight: parent.height * 0.5
                    sideHeight: ((parent.height * 0.5) / 2) - gap
                    
                    focus: true
                    
                    onCloseRequested: root.closeRequested()
                    
                    function safeIncrement() { if (incrementCurrentIndex) incrementCurrentIndex() }
                    function safeDecrement() { if (decrementCurrentIndex) decrementCurrentIndex() }
                }
            }
        }
    }
}
