import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import qs

Item {
    id: root

    visible: Media.activePlayer !== null

    // Sizing logic
    implicitWidth: Math.min(background.implicitWidth, 350)
    implicitHeight: Theme.dimensions.barItemHeight

    Component.onCompleted: PopoutService.nowPlayingItem = root
    Component.onDestruction: PopoutService.nowPlayingItem = null

    BaseBlock {
        id: background

        anchors.fill: parent
        paddingHorizontal: Theme.geometry.spacing.dynamicPadding
        paddingVertical: 0
        implicitHeight: Theme.dimensions.barItemHeight
        hoverEnabled: false
        Layout.fillWidth: false
        // Left-click opens media popout anchored to this widget
        clickable: true
        onClicked: {
            PopoutService.toggleMediaPopout();
        }

        // Match standard capsule look
        blockRadius: Theme.geometry.radius
        implicitWidth: mediaWidget.implicitWidth + (paddingHorizontal * 2)

        // Now Playing Media Widget
        RowLayout {
            id: mediaWidget

            property color contentColor: background.containsMouse ? Theme.colors.primary : Theme.colors.text

            Layout.alignment: Qt.AlignCenter
            spacing: Theme.geometry.spacing.medium
            Layout.maximumWidth: 350
            // Only show if media is actually available
            visible: Media.activePlayer !== null

            // Play/Pause & Progress Bar
            Item {
                id: albumArtContainer
                width: Theme.dimensions.iconMedium
                height: Theme.dimensions.iconMedium
                Layout.preferredWidth: width
                Layout.preferredHeight: height
                Layout.alignment: Qt.AlignVCenter

                readonly property real progress: Media.progressRatio
                property real animatedProgress: progress
                
                Behavior on animatedProgress {
                    BaseAnimation.Spring { profile: "snappy" }
                }
                
                onAnimatedProgressChanged: progressCanvas.requestPaint()

                property real wavePhase: 0
                property real waveAmplitude: 1.5
                property real waveFrequency: 6 // Peaks around the circle

                BaseAnimation {
                    from: 0
                    to: Math.PI * 2
                    duration: 2000
                    loops: Animation.Infinite
                    running: Media.playbackState === MprisPlaybackState.Playing
                    target: albumArtContainer
                    property: "wavePhase"
                    easing.type: Easing.Linear
                }

                onWavePhaseChanged: progressCanvas.requestPaint()

                // Circular Progress Bar
                Canvas {
                    id: progressCanvas
                    anchors.fill: parent
                    antialiasing: true

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);

                        var cx = width / 2;
                        var cy = height / 2;
                        var baseRadius = 9.5; 
                        var startAngle = -Math.PI / 2; // Start from top
                        var endAngle = startAngle + (Math.PI * 2 * albumArtContainer.animatedProgress);

                        // Track Background
                        ctx.beginPath();
                        ctx.arc(cx, cy, baseRadius, 0, Math.PI * 2, false);
                        ctx.lineWidth = 1.5;
                        ctx.strokeStyle = Theme.alpha(mediaWidget.contentColor, 0.1);
                        ctx.stroke();

                        // Wavy Progress Arc
                        if (albumArtContainer.animatedProgress > 0) {
                            ctx.beginPath();
                            ctx.lineWidth = 2;
                            
                            var gradient = ctx.createLinearGradient(cx - baseRadius, 0, cx + baseRadius, 0);
                            gradient.addColorStop(0, Theme.colors.primary);
                            gradient.addColorStop(1, Theme.colors.secondary);
                            ctx.strokeStyle = gradient;
                            
                            ctx.lineCap = "round";

                            var segments = 60;
                            var step = (endAngle - startAngle) / segments;
                            
                            for (var i = 0; i <= segments; i++) {
                                var angle = startAngle + (step * i);
                                var r = baseRadius + Math.sin(angle * albumArtContainer.waveFrequency + albumArtContainer.wavePhase) * albumArtContainer.waveAmplitude;
                                var x = cx + r * Math.cos(angle);
                                var y = cy + r * Math.sin(angle);
                                
                                if (i === 0) ctx.moveTo(x, y);
                                else ctx.lineTo(x, y);
                            }
                            ctx.stroke();
                        }
                    }
                }

                // Centered Play/Pause Icon
                BaseIcon {
                    anchors.centerIn: parent
                    icon: Media.playbackState === MprisPlaybackState.Playing ? "pause" : "play_arrow"
                    size: Theme.dimensions.iconSmall
                    color: mediaWidget.contentColor

                    rotation: Media.playbackState === MprisPlaybackState.Playing ? 180 : 0
                    Behavior on rotation { BaseAnimation { speed: "fast"; easing.type: Easing.InOutBack } }
                    Behavior on icon { BaseAnimation { speed: "fast" } }
                }
            }

            // Song Info
                Item {
                    id: songInfoContainer
                    Layout.fillWidth: true
                    Layout.maximumWidth: 228 // Increased by 48px (~6 chars)
                    Layout.preferredHeight: 32
                    // Use a more stable width calculation
                    implicitWidth: Math.min(songInfoText.implicitWidth, 228)
                    Layout.alignment: Qt.AlignVCenter
                    clip: true

                    BaseText {
                        id: songInfoText

                        // Fixed threshold for stability
                        readonly property int maxAvailableWidth: 230
                        readonly property bool shouldScroll: implicitWidth > maxAvailableWidth
                        
                        width: shouldScroll ? implicitWidth : parent.width
                        anchors.verticalCenter: parent.verticalCenter

                        text: (Media.trackArtist ? Media.trackArtist + " - " : "") + Media.trackTitle
                        pixelSize: Theme.typography.size.medium
                        color: mediaWidget.contentColor
                        
                        x: 0
                        // Reset scroll position on track change
                        onTextChanged: x = 0

                        SequentialAnimation {
                            id: scrollAnimation
                            running: songInfoText.shouldScroll && Media.activePlayer !== null
                            loops: Animation.Infinite

                            BaseAnimation {
                                target: songInfoText
                                property: "x"
                                to: -(songInfoText.implicitWidth - songInfoContainer.width)
                                duration: Math.max(0, (songInfoText.implicitWidth - songInfoContainer.width) * 50)
                                easing.type: Easing.Linear
                            }

                            PauseAnimation {
                                duration: Theme.animations.slow * 2
                            }

                            BaseAnimation {
                                target: songInfoText
                                property: "x"
                                to: 0
                                duration: Math.max(0, (songInfoText.implicitWidth - songInfoContainer.width) * 50)
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    // Edge Fades (overlays)
                    // Added more descriptive logic for fades
                    Rectangle {
                        id: leftFade
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 15
                        z: 1
                        visible: songInfoText.shouldScroll
                        // Only show left fade if we've scrolled significantly to the left
                        opacity: Math.min(1.0, Math.abs(songInfoText.x) / 10)
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: background.color }
                            GradientStop { position: 1; color: Theme.colors.transparent }
                        }
                    }

                    Rectangle {
                        id: rightFade
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 15
                        z: 1
                        visible: songInfoText.shouldScroll
                        readonly property real maxScroll: -(songInfoText.implicitWidth - songInfoContainer.width)
                        // Only show right fade if we haven't reached the end yet
                        opacity: Math.min(1.0, Math.abs(songInfoText.x - maxScroll) / 10)
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Theme.colors.transparent }
                            GradientStop { position: 1; color: background.color }
                        }
                    }
                }

        }

    }

    // Mouse interactions for play/pause and track navigation
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.MiddleButton || mouse.button === Qt.RightButton) {
                Media.togglePlayPause()
            }
        }
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                Media.previous()
            } else {
                Media.next()
            }
        }
    }

    // Smooth size transitions with snappy easing
    Behavior on implicitWidth {
            BaseAnimation {
                speed: "fast"
                easing.type: Easing.OutExpo
            }

    }

}

