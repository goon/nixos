import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs
pragma Singleton

Singleton {
    id: root

    property PwNode audioSink: Pipewire.defaultAudioSink
    property PwNode audioSource: Pipewire.defaultAudioSource
    property real volume: (audioSink && audioSink.audio) ? audioSink.audio.volume : 0
    property bool muted: (audioSink && audioSink.audio) ? audioSink.audio.muted : false
    property real inputVolume: (audioSource && audioSource.audio) ? audioSource.audio.volume : 0
    property bool inputMuted: (audioSource && audioSource.audio) ? audioSource.audio.muted : false
    readonly property string volumeIcon: {
        if (muted)
            return "volume_off";

        if (volume <= 0)
            return "volume_mute";

        if (volume < 0.6)
            return "volume_down";

        return "volume_up";
    }
    readonly property int volumePercent: Math.round(volume * 100)
    readonly property string inputVolumeIcon: inputMuted ? "mic_off" : "mic"
    readonly property int inputVolumePercent: Math.round(inputVolume * 100)
    property var unavailableNodes: []
    property var sinks: Pipewire.nodes.values.filter((node) => {
        return node.isSink && !node.isStream && node.audio && !unavailableNodes.includes(node.name);
    })
    property var sources: Pipewire.nodes.values.filter((node) => {
        return !node.isSink && !node.isStream && node.audio && !unavailableNodes.includes(node.name);
    })
    property var apps: Pipewire.nodes.values.filter((node) => {
        if (!node.isStream || !node.audio)
            return false;

        var name = (node.name || "").toLowerCase();
        var props = node.properties || {
        };
        var appName = (props["application.name"] || "").toLowerCase();
        if (name.includes("cava") || appName.includes("cava"))
            return false;

        return true;
    })

    signal externalVolumeChanged()
    signal externalMuteChanged()

    function updateAvailability() {
        if (!availabilityProcess.running)
            availabilityProcess.running = true;
    }
    function getNodeName(node) {
        if (!node)
            return "Unknown";

        return node.nickname || node.properties["node.nick"] || node.description || node.properties["node.description"] || node.name || "Unknown";
    }

    function getAppName(node) {
        if (!node)
            return "Unknown";

        var props = node.properties || {};
        var appName = props["application.name"] || "";
        var binary = props["application.process.binary"] || "";
        var mediaName = [props["media.name"] || "", props["node.description"] || ""].find(s => s !== "");

        // List of generic names that we want to improve if possible
        var genericNames = ["chromium", "chromium input", "web content", "playback", "recordstream", "pulseaudio-quickshell", "firefox", "pulse-input"];
        var isGeneric = !appName || genericNames.includes(appName.toLowerCase());

        if (isGeneric) {
            // Try extracting from binary first (e.g. "vesktop")
            if (binary) {
                var bName = binary.split('/').pop();
                if (!genericNames.includes(bName.toLowerCase())) {
                    appName = bName.charAt(0).toUpperCase() + bName.slice(1);
                    
                    // Restore "Input" distinction if it was present in the generic name
                    if (props["application.name"] && props["application.name"].toLowerCase().includes("input")) {
                        appName += " Input";
                    }
                }
            }
        }

        // Always try to use mediaName if it's descriptive (e.g. "Netflix", "YouTube Title")
        if (mediaName && !genericNames.includes(mediaName.toLowerCase())) {
            // Browsers usually provide descriptive media names per tab
            var browsers = ["firefox", "chromium", "google-chrome", "brave", "edge", "opera", "vivaldi"];
            var isBrowser = browsers.includes((appName || "").toLowerCase()) || browsers.includes((props["application.name"] || "").toLowerCase());
            
            if (isBrowser || !appName || isGeneric) {
                // If the app is a browser or its name is generic, we prefer the media name
                // (e.g. Firefox + Netflix tab -> "Netflix")
                return mediaName;
            }
        }

        return appName || getNodeName(node);
    }

    function getAppIcon(node) {
        if (!node)
            return "";

        var props = node.properties || {};
        var genericIcons = ["chromium-browser", "chromium", "web-browser", "audio-card", "audio-speakers", "audio-input-microphone", "audio-card-pci"];
        
        var icon = props["application.icon-name"] || props["icon-name"] || "";
        var binary = props["application.process.binary"] || "";
        var appName = props["application.name"] || "";

        var isGeneric = !icon || genericIcons.includes(icon.toLowerCase());

        if (isGeneric) {
            // Try resolving from binary
            if (binary) {
                var bName = binary.split('/').pop();
                if (!genericIcons.includes(bName.toLowerCase())) {
                    // Try to find a better icon from desktop entries using the binary name
                    var desktopIcon = LauncherService.getIconFromDesktop(bName);
                    if (desktopIcon) return desktopIcon;
                    return bName;
                }
            }
            // Try resolving from appName
            if (appName && !genericIcons.includes(appName.toLowerCase())) {
                var desktopIcon = LauncherService.getIconFromDesktop(appName);
                if (desktopIcon) return desktopIcon;
                return appName.toLowerCase();
            }
        }

        return icon || "audio-card";
    }
    function toggleMute() {
        if (audioSink && audioSink.audio)
            audioSink.audio.muted = !audioSink.audio.muted;

    }

    function setVolume(val) {
        if (audioSink && audioSink.audio) {
            audioSink.audio.muted = false;
            audioSink.audio.volume = val;
        }
    }

    function toggleInputMute() {
        if (audioSource && audioSource.audio)
            audioSource.audio.muted = !audioSource.audio.muted;

    }

    function setInputVolume(val) {
        if (audioSource && audioSource.audio) {
            audioSource.audio.muted = false;
            audioSource.audio.volume = val;
        }
    }

    function toggleAppMute(id) {
        var node = Pipewire.nodes.values.find((n) => {
            return n.id === id;
        });
        if (node && node.audio && node.ready)
            node.audio.muted = !node.audio.muted;

    }

    function setAppVolume(id, val) {
        var node = Pipewire.nodes.values.find((n) => {
            return n.id === id;
        });
        if (node && node.audio && node.ready)
            node.audio.volume = val;

    }

    function selectSink(id) {
        var node = Pipewire.nodes.values.find((n) => {
            return n.id === id;
        });
        if (node)
            Pipewire.preferredDefaultAudioSink = node;

    }

    function selectSource(id) {
        var node = Pipewire.nodes.values.find((n) => {
            return n.id === id;
        });
        if (node)
            Pipewire.preferredDefaultAudioSource = node;

    }

    Component.onCompleted: updateAvailability()

    // --- Process Management ---
    // Rule 1: NO persistent background subshells (leaks on reload)
    // Rule 2: Use transient processes triggered by native signals

    Process {
        // Rule 2: "Unknown" phantoms (S/PDIF, etc) on cards that have real "Available" ports
        // Rule 3: Contradictory roles (Monitor sinks on Microphones)

        id: availabilityProcess

        command: ["pactl", "--format=json", "list"]
        running: false

        stdout: StdioCollector {
            onDataChanged: {
                if (!text)
                    return ;

                try {
                    var data = JSON.parse(text);
                    var cardsWithAvailableSinks = {
                    };
                    var cardsWithAvailableSources = {
                    };
                    // First pass: Identify "Available" hardware
                    if (data.sinks)
                        data.sinks.forEach((sink) => {
                        var props = sink.properties || {
                        };
                        var card = props["device.name"] || props["api.alsa.card"] || "unknown";
                        var activePort = sink.ports.find((p) => {
                            return p.name === sink.active_port;
                        });
                        if (activePort && activePort.availability === "available")
                            cardsWithAvailableSinks[card] = true;

                    });

                    if (data.sources)
                        data.sources.forEach((source) => {
                        var props = source.properties || {
                        };
                        var card = props["device.name"] || props["api.alsa.card"] || "unknown";
                        var activePort = source.ports.find((p) => {
                            return p.name === source.active_port;
                        });
                        if (activePort && activePort.availability === "available")
                            cardsWithAvailableSources[card] = true;

                    });

                    // Second pass: Filter phantoms
                    var unavailable = [];
                    if (data.sinks)
                        data.sinks.forEach((sink) => {
                        var props = sink.properties || {
                        };
                        var card = props["device.name"] || props["api.alsa.card"] || "unknown";
                        var formFactor = props["device.form_factor"] || "";
                        var activePort = sink.ports.find((p) => {
                            return p.name === sink.active_port;
                        });
                        var avail = activePort ? activePort.availability : "unknown";
                        // Rule 1: Explicitly not available
                        if (avail === "not available")
                            unavailable.push(sink.name);
                        else if (avail === "availability unknown" && cardsWithAvailableSinks[card])
                            unavailable.push(sink.name);
                        else if (avail === "availability unknown" && formFactor === "microphone")
                            unavailable.push(sink.name);
                    });

                    if (data.sources)
                        data.sources.forEach((source) => {
                        var props = source.properties || {
                        };
                        var card = props["device.name"] || props["api.alsa.card"] || "unknown";
                        var activePort = source.ports.find((p) => {
                            return p.name === source.active_port;
                        });
                        var avail = activePort ? activePort.availability : "unknown";
                        if (avail === "not available")
                            unavailable.push(source.name);
                        else if (avail === "availability unknown" && cardsWithAvailableSources[card])
                            unavailable.push(source.name);
                    });

                    root.unavailableNodes = unavailable;
                } catch (e) {
                    console.error("Failed to parse pactl output:", e);
                }
            }
        }

    }

    // --- Dynamic Triggers ---
    // Instead of a persistent subshell, we trigger updates based on 
    // native Pipewire signals or an occasional safety poll.
    
    property Timer availabilityDebounce: Timer {
        interval: 500
        repeat: false
        onTriggered: updateAvailability()
    }

    Connections {
        target: Pipewire.nodes
        function onValuesChanged() { availabilityDebounce.restart(); }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() { availabilityDebounce.restart(); }
        function onDefaultAudioSourceChanged() { availabilityDebounce.restart(); }
    }

    // Safety poll (e.g. for card profile changes that don't trigger PW node values)
    property Timer safetyPoll: Timer {
        interval: 30000 // 30s is plenty for a safety net
        running: true
        repeat: true
        onTriggered: updateAvailability()
    }

    // --- Core Pipewire Tracker ---
    // Ensures we subscribe to changes for nodes/meta/etc.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSource, Pipewire.defaultAudioSink, Pipewire.nodes, Pipewire.links]
    }

}
