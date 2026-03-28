import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs

SettingsPage {
    id: root

    title: "Shell Configuration"

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.geometry.spacing.medium

        // --- Presets ---
        GridLayout {
            columns: 3
            rowSpacing: Theme.geometry.spacing.dynamicPadding
            columnSpacing: Theme.geometry.spacing.dynamicPadding
            Layout.fillWidth: true

            BaseText {
                text: "Save, load, and manage your custom bar configurations."
                color: Theme.colors.text
                pixelSize: Theme.typography.size.medium
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                Layout.columnSpan: 3
                Layout.bottomMargin: Theme.geometry.spacing.small
            }

            BaseInput {
                id: presetNameInput
                placeholderText: "Enter preset name..."
                Layout.fillWidth: true
                Layout.columnSpan: 2
                implicitHeight: 42
                font.pixelSize: Theme.typography.size.medium
            }

            BaseButton {
                text: "Save"
                icon: "save"
                Layout.fillWidth: true
                implicitHeight: 42
                gradient: true
                selected: containsMouse
                weight: Theme.typography.weights.normal
                textSize: Theme.typography.size.medium
                iconSize: Theme.dimensions.iconMedium
                onClicked: {
                    if (presetNameInput.text.trim() !== "") {
                        Preferences.savePreset(presetNameInput.text.trim());
                        presetNameInput.text = "";
                    }
                }
            }

            BaseComboBox {
                id: presetSelector
                Layout.fillWidth: true
                Layout.columnSpan: 1
                implicitHeight: 42
                font.pixelSize: Theme.typography.size.medium
                model: Object.keys(Preferences.presets)
            }

            BaseButton {
                text: "Load"
                icon: "download"
                Layout.fillWidth: true
                implicitHeight: 42
                gradient: true
                selected: containsMouse
                weight: Theme.typography.weights.normal
                textSize: Theme.typography.size.medium
                iconSize: Theme.dimensions.iconMedium
                enabled: presetSelector.currentText !== ""
                onClicked: Preferences.loadPreset(presetSelector.currentText)
            }

            BaseButton {
                text: "Delete"
                icon: "delete"
                Layout.fillWidth: true
                implicitHeight: 42
                gradient: true
                selected: containsMouse
                weight: Theme.typography.weights.normal
                textSize: Theme.typography.size.medium
                iconSize: Theme.dimensions.iconMedium
                enabled: presetSelector.currentText !== ""
                onClicked: Preferences.deletePreset(presetSelector.currentText)
            }
        }

        BaseSeparator {
            Layout.fillWidth: true
        }

        // --- Shell Configuration ---
        GridLayout {
            columns: 2
            rowSpacing: Theme.geometry.spacing.dynamicPadding
            columnSpacing: Theme.geometry.spacing.dynamicPadding
            Layout.fillWidth: true

            BaseText {
                text: "Adjust the core desktop environment's look, feel, and typography."
                color: Theme.colors.text
                pixelSize: Theme.typography.size.medium
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                Layout.columnSpan: 2
                Layout.bottomMargin: Theme.geometry.spacing.small
            }

            BaseText {
                text: "Globals"
                weight: Theme.typography.weights.bold
                color: Theme.colors.primary
                pixelSize: Theme.typography.size.large
                Layout.columnSpan: 2
            }

            BaseText {
                text: "Theme Preset:"
                pixelSize: Theme.typography.size.medium
            }

            BaseComboBox {
                Layout.fillWidth: true
                textRole: "name"
                model: ThemeService.availableStockThemes
                currentIndex: {
                    if (!model)
                        return -1;

                    for (var i = 0; i < model.length; i++) {
                        if (model[i].id === Preferences.currentTheme)
                            return i;

                    }
                    return -1;
                }
                onActivated: (index) => {
                    return ThemeService.setTheme(model[index].id);
                }
            }

            // Shell Font
            BaseText {
                text: "Shell Font:"
                pixelSize: Theme.typography.size.medium
            }

            BaseComboBox {
                Layout.fillWidth: true
                model: ThemeService.allFontFamilies
                searchable: true
                previewFonts: true
                currentIndex: {
                    var current = Preferences.shellFont;
                    for (var i = 0; i < model.length; i++) {
                        if (current === model[i])
                            return i;

                    }
                    return -1;
                }
                onActivated: (index) => {
                    Preferences.shellFont = model[index];
                }
            }

            BaseText {
                text: "Corner Radius:"
                pixelSize: Theme.typography.size.medium
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.large

                BaseSlider {
                    id: barRadiusSlider

                    Layout.fillWidth: true
                    from: 0
                    to: 30
                    stepSize: 1
                    value: Preferences.cornerRadius
                    onMoved: Preferences.cornerRadius = value
                }

                BaseText {
                    text: Math.round(barRadiusSlider.value) + "px"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }

            }

            BaseText {
                text: "Desktop Dimming:"
                pixelSize: Theme.typography.size.medium
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.large

                BaseSlider {
                    id: desktopDimSlider

                    Layout.fillWidth: true
                    from: 0
                    to: 0.5
                    stepSize: 0.01
                    value: Preferences.desktopDim
                    onMoved: Preferences.desktopDim = value
                }

                BaseText {
                    text: Math.round(desktopDimSlider.value * 100) + "%"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }

            }

            BaseText {
                text: "Background Blur:"
                pixelSize: Theme.typography.size.medium
            }

            BaseSwitch {
                id: blurSwitch
                checked: Preferences.blurEnabled
                onToggled: Preferences.blurEnabled = checked
                Layout.alignment: Qt.AlignLeft
            }

            BaseText {
                text: "Background Opacity:"
                pixelSize: Theme.typography.size.medium
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.large

                BaseSlider {
                    id: blurOpacitySlider

                    Layout.fillWidth: true
                    from: 0.3
                    to: 1.0
                    stepSize: 0.05
                    value: Preferences.blurOpacity
                    onMoved: Preferences.blurOpacity = value
                }

                BaseText {
                    text: Math.round(blurOpacitySlider.value * 100) + "%"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }

            BaseText {
                text: "Block Opacity:"
                pixelSize: Theme.typography.size.medium
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.large

                BaseSlider {
                    id: blockOpacitySlider

                    Layout.fillWidth: true
                    from: 0.3
                    to: 1.0
                    stepSize: 0.05
                    value: Preferences.blockOpacity
                    onMoved: Preferences.blockOpacity = value
                }

                BaseText {
                    text: Math.round(blockOpacitySlider.value * 100) + "%"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }

            BaseText {
                text: "Bar Dimensions"
                weight: Theme.typography.weights.bold
                color: Theme.colors.primary
                pixelSize: Theme.typography.size.large
                Layout.columnSpan: 2
                Layout.topMargin: Theme.geometry.spacing.large
            }

            BaseText {
                text: "Position:"
                pixelSize: Theme.typography.size.medium
            }

            BaseComboBox {
                Layout.fillWidth: true
                textRole: "label"
                model: [{
                    "label": "Top",
                    "value": "top"
                }, {
                    "label": "Bottom",
                    "value": "bottom"
                }]
                currentIndex: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i].value === Preferences.barPosition)
                            return i;

                    }
                    return -1;
                }
                onActivated: (index) => {
                    Preferences.barPosition = model[index].value;
                }
            }

            BaseText {
                text: "Fit to Content:"
                pixelSize: Theme.typography.size.medium
            }

            BaseSwitch {
                Layout.alignment: Qt.AlignLeft
                checked: Preferences.barFitToContent
                onToggled: {
                    if (checked) {
                        // Migrate components to center when enabling Fit to Content
                        let left = Array.from(Preferences.barLeftComponents);
                        let center = Array.from(Preferences.barCenterComponents);
                        let right = Array.from(Preferences.barRightComponents);
                        
                        let combined = center.concat(left, right);
                        Preferences.barCenterComponents = combined;
                        Preferences.barLeftComponents = [];
                        Preferences.barRightComponents = [];
                    }
                    Preferences.barFitToContent = checked;
                }
            }

            BaseText {
                text: "Bar Density:"
                pixelSize: Theme.typography.size.medium
            }

            BaseComboBox {
                Layout.fillWidth: true
                textRole: "label"
                model: [{
                    "label": "Compact",
                    "value": 0
                }, {
                    "label": "Default",
                    "value": 1
                }, {
                    "label": "Comfortable",
                    "value": 2
                }]
                currentIndex: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i].value === Preferences.barDensity)
                            return i;

                    }
                    return 1; // Default
                }
                onActivated: (index) => {
                    Preferences.barDensity = model[index].value;
                }
            }

            BaseText {
                text: "Top Margin:"
                pixelSize: Theme.typography.size.medium
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.large

                BaseSlider {
                    id: barTopMarginSlider

                    Layout.fillWidth: true
                    from: 0
                    to: 50
                    stepSize: 1
                    value: Preferences.barMarginTop
                    onMoved: Preferences.barMarginTop = value
                }

                BaseText {
                    text: Math.round(barTopMarginSlider.value) + "px"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }

            }

            BaseText {
                text: "Side Margin:"
                pixelSize: Theme.typography.size.medium
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.geometry.spacing.large

                BaseSlider {
                    id: barSideMarginSlider

                    Layout.fillWidth: true
                    from: 0
                    to: 50
                    stepSize: 1
                    value: Preferences.barMarginSide
                    onMoved: Preferences.barMarginSide = value
                }

                BaseText {
                    text: Math.round(barSideMarginSlider.value) + "px"
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }

            }

            BaseText {
                text: "Notification Layout:"
                pixelSize: Theme.typography.size.medium
            }

            BaseComboBox {
                Layout.fillWidth: true
                textRole: "label"
                model: [{
                    "label": "Compact",
                    "value": 0
                }, {
                    "label": "Comfortable",
                    "value": 1
                }]
                currentIndex: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i].value === Preferences.notificationDensity)
                            return i;

                    }
                    return 1; // Default
                }
                onActivated: (index) => {
                    Preferences.notificationDensity = model[index].value;
                }
            }

            BaseText {
                text: "Workspace Settings"
                weight: Theme.typography.weights.bold
                color: Theme.colors.primary
                pixelSize: Theme.typography.size.large
                Layout.columnSpan: 2
                Layout.topMargin: Theme.geometry.spacing.large
            }

            BaseText {
                text: "Workspace Style:"
                pixelSize: Theme.typography.size.medium
            }

            BaseComboBox {
                id: workspaceStyleSelector
                Layout.fillWidth: true
                textRole: "label"
                model: [
                    { "label": "English (1)", "value": 0 },
                    { "label": "Roman (I)", "value": 1 },
                    { "label": "Kanji (一)", "value": 2 }
                ]
                currentIndex: {
                    for (var i = 0; i < model.length; i++) {
                        if (model[i].value === Preferences.workspaceStyle)
                            return i;
                    }
                    return 0;
                }
                onActivated: (index) => {
                    Preferences.workspaceStyle = model[index].value;
                }
            }

            BaseText {

                text: "Bar Components"
                weight: Theme.typography.weights.bold
                color: Theme.colors.primary
                pixelSize: Theme.typography.size.large
                Layout.columnSpan: 2
                Layout.topMargin: Theme.geometry.spacing.large
            }

            BaseText {
                text: "Customize the layout and elements of your system bar."
                color: Theme.colors.text
                pixelSize: Theme.typography.size.medium
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                Layout.columnSpan: 2
                Layout.bottomMargin: Theme.geometry.spacing.small
            }

            BarConfiguration {
                Layout.columnSpan: 2
                Layout.fillWidth: true
            }


        }
    }

    // --- FROM Bar.qml (as a component) ---
    component BarConfiguration: ColumnLayout {
        id: barRoot

        // Component metadata mapping
        readonly property var componentMetadata: ({
            "workspaces": { name: "Workspaces", icon: "view_week" },
            "tray": { name: "System Tray", icon: "keyboard_arrow_up" },
            "volume": { name: "Volume Control", icon: "volume_up" },
            "clock": { name: "Clock", icon: "schedule" },
            "nowPlaying": { name: "Now Playing", icon: "music_note" },
            "notifications": { name: "Notifications", icon: "notifications" },
            "dock": { name: "Dock", icon: "vertical_split" },
            "stats": { name: "System Resources", icon: "monitoring" },
            "systemControl": { name: "System Control", icon: "tune" }
        })

        // Get all available component IDs
        readonly property var allComponents: Object.keys(componentMetadata)

        // Calculate available (unused) components
        function getAvailableComponents() {
            var used = Preferences.barLeftComponents.concat(
                Preferences.barCenterComponents,
                Preferences.barRightComponents
            );
            return allComponents.filter(function(id) {
                return !used.includes(id);
            });
        }

        // Add component to a specific section
        function addComponent(componentId, targetSection) {
            var list = [];
            if (targetSection === "barLeftComponents")
                list = Array.from(Preferences.barLeftComponents);
            else if (targetSection === "barCenterComponents")
                list = Array.from(Preferences.barCenterComponents);
            else if (targetSection === "barRightComponents")
                list = Array.from(Preferences.barRightComponents);
            
            // Prevent duplicates just in case
            if (list.includes(componentId)) return;

            list.push(componentId);
            
            updateList(targetSection, list);
        }

        // Remove component from a section
        function removeComponent(listName, index) {
            var list = getList(listName);
            list.splice(index, 1);
            updateList(listName, list);
        }

        function getList(listName) {
            if (listName === "barLeftComponents") return Array.from(Preferences.barLeftComponents);
            if (listName === "barCenterComponents") return Array.from(Preferences.barCenterComponents);
            if (listName === "barRightComponents") return Array.from(Preferences.barRightComponents);
            return [];
        }

        function updateList(listName, list) {
            if (listName === "barLeftComponents") Preferences.barLeftComponents = list;
            else if (listName === "barCenterComponents") Preferences.barCenterComponents = list;
            else if (listName === "barRightComponents") Preferences.barRightComponents = list;
        }

        // Unified move function
        function moveComponent(componentId, sourceSection, targetSection, targetIndex) {
            if (sourceSection === targetSection && targetSection === "available") return; // No-op

            // 1. Remove from source
            if (sourceSection !== "available") {
                var sourceList = getList(sourceSection);
                var sourceIndex = sourceList.indexOf(componentId);
                if (sourceIndex > -1) {
                    sourceList.splice(sourceIndex, 1);
                    updateList(sourceSection, sourceList);
                }
            }

            // 2. Add to target
            if (targetSection !== "available") {
                var targetList = getList(targetSection);
                if (targetIndex === -1 || targetIndex >= targetList.length) {
                    targetList.push(componentId);
                } else {
                    targetList.splice(targetIndex, 0, componentId);
                }
                updateList(targetSection, targetList);
            }
        }
        
        // Helper for colors
        property color primaryColor: Theme.colors.primary

        Layout.fillWidth: true

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.geometry.spacing.medium

            // Available Components Section
            ColumnLayout {
                Layout.fillWidth: true
                visible: getAvailableComponents().length > 0 || dropAreaAvailable.containsDrag

                BaseText {
                    text: "Available Components"
                    color: Theme.colors.muted
                    font.weight: Font.Medium
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: availableFlow.height + Theme.geometry.spacing.small * 2
                    color: dropAreaAvailable.containsDrag ? Theme.alpha(barRoot.primaryColor, 0.1) : Theme.colors.transparent
                    radius: Theme.geometry.radius
                    border.width: 1
                    border.color: dropAreaAvailable.containsDrag ? Theme.colors.primary : Theme.colors.transparent
                    
                    // DropArea to accept items moved back to available (Active -> Available)
                    DropArea {
                        id: dropAreaAvailable
                        anchors.fill: parent
                        keys: ["bar-component"]
                        
                        onDropped: (drop) => {
                            var data = drop.source && drop.source.dragData;
                            if (!data) return;
                            
                            // Move to "available" (which essentially removes it from source)
                            barRoot.moveComponent(data.componentId, data.sourceSection, "available", -1);
                            drop.accept();
                        }
                    }

                    Flow {
                        id: availableFlow
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: Theme.geometry.spacing.small

                        Repeater {
                            model: getAvailableComponents()

                            BarComponentItem {
                                componentId: modelData
                                sourceSection: "available"
                                label: barRoot.componentMetadata[modelData]?.name || modelData
                            }
                        }
                    }
                }
            }

            BaseSeparator {
                Layout.fillWidth: true
                visible: getAvailableComponents().length > 0
            }

            // Left Section
            ComponentList {
                Layout.fillWidth: true
                sectionName: "barLeftComponents"
                sectionTitle: "Left"
                components: Preferences.barLeftComponents
                visible: !Preferences.barFitToContent
            }

            BaseSeparator {
                Layout.fillWidth: true
                visible: !Preferences.barFitToContent
            }

            // Center Section
            ComponentList {
                Layout.fillWidth: true
                sectionName: "barCenterComponents"
                sectionTitle: "Center"
                components: Preferences.barCenterComponents
            }

            BaseSeparator {
                Layout.fillWidth: true
                visible: !Preferences.barFitToContent
            }

            // Right Section
            ComponentList {
                Layout.fillWidth: true
                sectionName: "barRightComponents"
                sectionTitle: "Right"
                components: Preferences.barRightComponents
                visible: !Preferences.barFitToContent
            }
        }

    }

    // Component Item (With Drag)
    component BarComponentItem: Item {
        id: itemRoot
        
        property string componentId
        property string sourceSection
        property string label
        property var dragData: ({ componentId: componentId, sourceSection: sourceSection })
        
        width: rect.width
        height: rect.height
        
        opacity: dragHandler.drag.active ? 0.3 : 1.0
        
        Rectangle {
            id: rect
            property var dragData: itemRoot.dragData
            readonly property bool isActive: dragHandler.containsMouse || dragHandler.drag.active

            width: innerRow.width + Theme.geometry.spacing.medium * 2
            height: innerRow.height + Theme.geometry.spacing.small * 2
            
            color: Theme.colors.surface
            radius: Theme.geometry.radius
            border.width: 1
            border.color: Theme.colors.border
            
            // Interaction Gradient Layer
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                visible: rect.isActive
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: Theme.colors.primary }
                    GradientStop { position: 1.0; color: Theme.colors.secondary }
                }
            }

            RowLayout {
                id: innerRow
                anchors.centerIn: parent
                spacing: 6

                BaseIcon {
                    icon: barRoot.componentMetadata[itemRoot.componentId]?.icon || "extension"
                    size: Theme.dimensions.iconBase
                    color: rect.isActive ? Theme.colors.background : Theme.colors.muted
                }

                BaseText {
                    text: itemRoot.label
                    color: rect.isActive ? Theme.colors.background : Theme.colors.muted
                }
            }

            Drag.active: dragHandler.drag.active
            Drag.keys: ["bar-component"]
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2

            MouseArea {
                id: dragHandler
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                drag.target: rect
                drag.axis: Drag.XAndYAxis
                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                
                onReleased: {
                    rect.Drag.drop();
                    rect.x = 0;
                    rect.y = 0;
                }

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton && sourceSection !== "available") {
                        var list = barRoot.getList(sourceSection);
                        var idx = list.indexOf(componentId);
                        if (idx > -1) {
                             barRoot.removeComponent(sourceSection, idx);
                        }
                    }
                }
            }
            
            states: [
                State {
                    when: dragHandler.drag.active
                    // Use root here since it's the root of the page
                    ParentChange {
                        target: rect
                        parent: root
                    }
                    AnchorChanges {
                        target: rect
                        anchors.horizontalCenter: undefined
                        anchors.verticalCenter: undefined
                    }
                }
            ]
        }
    }

    component ComponentList: ColumnLayout {
        id: section
        
        required property string sectionName
        required property string sectionTitle
        required property var components

        spacing: Theme.geometry.spacing.small

        BaseText {
            text: sectionTitle
            color: Theme.colors.muted
            font.weight: Font.Medium
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(flow.height, 50)
            color: dropArea.containsDrag ? Theme.alpha(barRoot.primaryColor, 0.1) : Theme.colors.transparent
            radius: Theme.geometry.radius
            border.width: 1
            border.color: dropArea.containsDrag ? Theme.colors.primary : Theme.colors.transparent

            DropArea {
                id: dropArea
                anchors.fill: parent
                keys: ["bar-component"]
                
                onDropped: (drop) => {
                    var data = drop.source && drop.source.dragData;
                    if (!data) return;
                    
                    barRoot.moveComponent(data.componentId, data.sourceSection, section.sectionName, -1);
                    drop.accept();
                }
            }
            
            BaseText {
                visible: section.components.length === 0 && !dropArea.containsDrag
                anchors.centerIn: parent
                text: "Drop components here"
                color: Theme.colors.muted
                font.italic: true
                padding: 4
            }

            Flow {
                id: flow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                spacing: Theme.geometry.spacing.small
                
                Repeater {
                    model: components

                    Item {
                        width: itemInstance.width
                        height: itemInstance.height
                        
                        BarComponentItem {
                            id: itemInstance
                            componentId: modelData
                            sourceSection: section.sectionName
                            label: barRoot.componentMetadata[modelData]?.name || modelData
                        }

                        DropArea {
                            anchors.fill: parent
                            keys: ["bar-component"]
                            
                            onDropped: (drop) => {
                                var data = drop.source && drop.source.dragData;
                                if (!data) return;
                                
                                barRoot.moveComponent(data.componentId, data.sourceSection, section.sectionName, index);
                                drop.accept();
                            }
                        }
                    }
                }
            }
        }
    }
}
