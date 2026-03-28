import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

SettingsPage {
    id: root
    
    title: "Wallpaper & Effects"

    GridLayout {
        columns: 2
        rowSpacing: Theme.geometry.spacing.dynamicPadding
        columnSpacing: Theme.geometry.spacing.dynamicPadding
        Layout.fillWidth: true

        BaseText {
            text: "Configure your desktop background, dynamic theming, and visual effects."
            color: Theme.colors.text
            pixelSize: Theme.typography.size.medium
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.columnSpan: 2
            Layout.bottomMargin: Theme.geometry.spacing.small
        }

        // --- General ---
        BaseText {
            text: "General"
            weight: Theme.typography.weights.bold
            color: Theme.colors.primary
            pixelSize: Theme.typography.size.large
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.small
        }

        BaseText {
            text: "Enable Gowall Theming:"
            pixelSize: Theme.typography.size.medium
        }

        BaseSwitch {
            checked: Preferences.gowallEnabled
            onToggled: Preferences.gowallEnabled = checked
            Layout.alignment: Qt.AlignLeft
        }

        BaseText {
            text: "Wallpaper Gallery:"
            pixelSize: Theme.typography.size.medium
        }

        BaseButton {
            text: "Open Gallery"
            implicitHeight: 42
            onClicked: PopoutService.toggleWallpaper()
            Layout.alignment: Qt.AlignLeft
        }

        BaseSeparator {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.medium
            Layout.bottomMargin: Theme.geometry.spacing.medium
        }

        // --- Visual Effects ---
        BaseText {
            text: "Visual Effects"
            weight: Theme.typography.weights.bold
            color: Theme.colors.primary
            pixelSize: Theme.typography.size.large
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.large
        }

        BaseText {
            text: "Parallax Effect:"
            pixelSize: Theme.typography.size.medium
        }

        BaseSwitch {
            checked: Preferences.wallpaperParallaxEnabled
            onToggled: Preferences.wallpaperParallaxEnabled = checked
            Layout.alignment: Qt.AlignLeft
        }

        BaseText {
            text: "Parallax Strength:"
            pixelSize: Theme.typography.size.medium
            enabled: Preferences.wallpaperParallaxEnabled
            opacity: enabled ? 1 : 0.5
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.geometry.spacing.large
            enabled: Preferences.wallpaperParallaxEnabled
            opacity: enabled ? 1 : 0.5

            BaseSlider {
                id: strengthSlider
                Layout.fillWidth: true
                from: 5
                to: 100
                stepSize: 1
                value: Preferences.wallpaperParallaxEnabled ? Preferences.wallpaperParallaxStrength : 20
                onMoved: Preferences.wallpaperParallaxStrength = Math.round(value)
            }

            BaseText {
                text: Math.round(strengthSlider.value) + "px"
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }
        }

        BaseSeparator {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.medium
            Layout.bottomMargin: Theme.geometry.spacing.medium
        }

        // --- Storage ---
        BaseText {
            text: "Storage"
            weight: Theme.typography.weights.bold
            color: Theme.colors.primary
            pixelSize: Theme.typography.size.large
            Layout.columnSpan: 2
            Layout.topMargin: Theme.geometry.spacing.large
        }

        BaseText {
            text: "Specify the folder where your background images are stored."
            color: Theme.colors.text
            pixelSize: Theme.typography.size.medium
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.columnSpan: 2
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            spacing: Theme.geometry.spacing.small

            BaseInput {
                id: dirInput
                Layout.fillWidth: true
                implicitHeight: 42
                inputPadding: 10
                text: Preferences.wallpaperDirectory
                placeholderText: "e.g. /home/user/Pictures/Wallpapers"
                onEditingFinished: Preferences.wallpaperDirectory = text
            }

            BaseButton {
                id: browseBtn
                icon: browserVisible ? "expand_less" : "folder"
                property bool browserVisible: false
                Layout.preferredHeight: dirInput.height
                Layout.preferredWidth: dirInput.height
                onClicked: browserVisible = !browserVisible
            }
        }

        // Warning when no directory is set
        BaseBlock {
            visible: Preferences.wallpaperDirectory === ""
            backgroundColor: Theme.alpha(Theme.colors.warning, 0.1)
            borderEnabled: true
            borderColor: Theme.colors.warning
            Layout.fillWidth: true
            Layout.columnSpan: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.medium
                
                BaseIcon {
                    icon: "warning"
                    color: Theme.colors.warning
                    size: Theme.dimensions.iconMedium
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    BaseText {
                        text: "No Wallpaper Directory Set"
                        font.bold: true
                        color: Theme.colors.warning
                    }
                    BaseText {
                        text: "The wallpaper gallery is disabled until you select a folder containing images."
                        pixelSize: Theme.typography.size.base
                        color: Theme.colors.text
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Inline folder browser, shown/hidden on toggle
        BaseFolderDialog {
            id: folderBrowser
            Layout.fillWidth: true
            Layout.columnSpan: 2
            visible: browseBtn.browserVisible
            currentFolder: Preferences.wallpaperDirectory
            onFolderSelected: (path) => {
                Preferences.wallpaperDirectory = path;
                dirInput.text = path;
                browseBtn.browserVisible = false;
            }
        }
    }
}
