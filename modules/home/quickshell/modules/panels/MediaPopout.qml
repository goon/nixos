import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs

BasePopoutWindow {
    id: root

    panelNamespace: "quickshell:media-popout"
    property real parallaxFactor: 30
    property real mouseX: 0.5
    property real mouseY: 0.5

    body: Item {
        implicitWidth: 380
        implicitHeight: 380 // Fixed height for media

        HoverHandler {
            id: hoverTracker
            onPointChanged: {
                if (parent.width > 0 && parent.height > 0) {
                    root.mouseX = point.position.x / parent.width;
                    root.mouseY = point.position.y / parent.height;
                }
            }
            onHoveredChanged: {
                if (!hovered) {
                    root.mouseX = 0.5;
                    root.mouseY = 0.5;
                }
            }
        }

        // Mask shape for album art rounded corners
        Rectangle {
            id: albumArtMask
            anchors.fill: parent
            radius: Preferences.cornerRadius
            color: Theme.colors.text
            visible: false
            layer.enabled: true
            layer.smooth: true
            layer.samples: 8
        }

        // Outer Layer: Handles Masking (sharp corners)
        Item {
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: albumArtMask
            }

            // Inner Layer: Handles Image + Blur
            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.5
                }

                Image {
                    anchors.centerIn: parent
                    width: parent.width * 1.25 // More bleed for factor 40
                    height: parent.height * 1.25
                    source: Media.albumArtUrl
                    fillMode: Image.PreserveAspectCrop
                    opacity: 0.45
                    visible: status === Image.Ready

                    transform: Translate {
                        x: (root.mouseX - 0.5) * -40 // Direct factor for testing
                        y: (root.mouseY - 0.5) * -40

                        Behavior on x { BaseAnimation { duration: Theme.animations.slow } }
                        Behavior on y { BaseAnimation { duration: Theme.animations.slow } }
                    }
                }
            }
        }

        ColumnLayout {
            width: parent.width
            anchors.centerIn: parent
            spacing: 24

            // Song Details
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                BaseText {
                    Layout.fillWidth: true
                    color: Theme.colors.primary
                    text: Media.activePlayer ? Media.trackTitle : "No Media Playing"
                    weight: Theme.typography.weights.bold
                    pixelSize: Theme.typography.size.large
                    horizontalAlignment: Text.AlignHCenter
                    shadow: true
                }

                BaseText {
                    Layout.fillWidth: true
                    text: Media.trackArtist
                    pixelSize: Theme.typography.size.medium
                    visible: Media.activePlayer !== null && text !== ""
                    horizontalAlignment: Text.AlignHCenter
                    shadow: true
                }
            }

            // Progress
            Slider {
                id: progressSlider

                property real wavePhase: 0
                property real waveAmplitude: 4
                property real waveFrequency: 0.15

                Layout.fillWidth: true
                Layout.leftMargin: 60
                Layout.rightMargin: 60
                value: Media.progressRatio
                
                Behavior on value {
                    enabled: !progressSlider.pressed
                    BaseAnimation.Spring { profile: "snappy" }
                }
                
                enabled: Media.canSeek && Media.trackLength > 0
                onMoved: Media.seek(value * Media.trackLength)

                BaseAnimation {
                    from: 0
                    to: -Math.PI * 2
                    speed: "slow"
                    loops: Animation.Infinite
                    running: Media.playbackState === MprisPlaybackState.Playing
                    target: progressSlider
                    property: "wavePhase"
                    easing.type: Easing.Linear
                }

                background: Item {
                    x: progressSlider.leftPadding
                    y: progressSlider.topPadding + (progressSlider.availableHeight / 2) - (height / 2)
                    width: progressSlider.availableWidth
                    height: 24

                    Canvas {
                        id: waveCanvas

                        property real progress: progressSlider.visualPosition
                        property color activeColor: Theme.colors.text
                        property color inactiveColor: Theme.colors.surface
                        property real phase: progressSlider.wavePhase

                        anchors.fill: parent
                        onProgressChanged: requestPaint()
                        onPhaseChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var midY = height / 2;
                            var amplitude = progressSlider.waveAmplitude;
                            var frequency = progressSlider.waveFrequency;
                            var progressX = progress * (width - 2);
                            var lineWidth = 4;
                            ctx.beginPath();
                            ctx.strokeStyle = inactiveColor;
                            ctx.lineWidth = lineWidth;
                            ctx.lineCap = "round";
                            ctx.moveTo(progressX, midY);
                            ctx.lineTo(width, midY);
                            ctx.stroke();
                            ctx.beginPath();
                            if (progressX > 0) {
                                var gradient = ctx.createLinearGradient(0, 0, progressX, 0);
                                gradient.addColorStop(0, Theme.colors.primary);
                                gradient.addColorStop(1, Theme.colors.secondary);
                                ctx.strokeStyle = gradient;
                            } else {
                                ctx.strokeStyle = activeColor;
                            }
                            ctx.lineWidth = lineWidth;
                            ctx.lineCap = "round";
                            if (progressX > 0) {
                                ctx.moveTo(0, midY + Math.sin(phase) * amplitude);
                                for (var x = 1; x <= progressX; x++) {
                                    var y = midY + Math.sin(x * frequency + phase) * amplitude;
                                    ctx.lineTo(x, y);
                                }
                                ctx.stroke();
                            }
                        }
                    }

                    Rectangle {
                        x: 0
                        y: parent.height / 2 - 10
                        width: 4
                        height: Theme.dimensions.iconMedium
                        radius: Math.max(2, Theme.geometry.radius * 0.5)
                        color: Theme.colors.text
                    }
                }

                handle: Rectangle {
                    z: 1
                    x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                    y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                    width: 4
                    height: Theme.dimensions.iconMedium
                    radius: Math.max(2, Theme.geometry.radius * 0.5)
                    color: Theme.colors.text
                }
            }

            // Controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 24

                BaseButton {
                    size: Theme.dimensions.iconBase
                    normalColor: Theme.colors.transparent
                    hoverGradient: true
                    icon: "skip_previous"
                    enabled: Media.canGoPrevious
                    onClicked: Media.previous()
                }

                BaseButton {
                    size: Theme.dimensions.iconBase
                    normalColor: Theme.colors.transparent
                    hoverGradient: true
                    icon: Media.playbackState === MprisPlaybackState.Playing ? "pause" : "play_arrow"
                    enabled: Media.activePlayer !== null
                    onClicked: Media.togglePlayPause()
                }

                BaseButton {
                    size: Theme.dimensions.iconBase
                    normalColor: Theme.colors.transparent
                    hoverGradient: true
                    icon: "skip_next"
                    enabled: Media.canGoNext
                    onClicked: Media.next()
                }
            }
        }
    }
}
