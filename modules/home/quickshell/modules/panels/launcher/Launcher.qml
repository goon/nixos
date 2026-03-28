import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs

BasePopoutWindow {
    id: root
    
    fixedWidth: 600
    panelNamespace: "quickshell:launcher"

    function switchToTab(index) {
        if (root.bodyItem)
            root.bodyItem.switchTab(index);
    }
    
    property int currentTabIndex: 0
    property int activeListCount: (bodyItem && bodyItem.activeTabObject) ? bodyItem.activeTabObject.listCount : 0
    readonly property var activeTab: (bodyItem && bodyItem.activeTabObject) ? bodyItem.activeTabObject : null

    body: FocusScope {
        id: mainScope
        
        Connections {
            target: root
            function onOpening() {
                LauncherService.resetInputStates();
                LauncherService.lastInputMethod = "keyboard";
                searchBar.text = "";
                
                root.currentTabIndex = 0;
                mainScope.currentItem = null;
                
                 for (var i = 0; i < mainScope.tabModel.length; i++) {
                    var tab = mainScope.getTab(i);
                    if (tab) tab.isActive = (i === 0);
                    mainScope.resetTabToTop(i);
                }
                
                Qt.callLater(() => {
                    searchBar.focusInput();
                });
            }
            
            function onClosing() {
                for (var i = 0; i < mainScope.tabModel.length; i++) {
                    var tab = mainScope.getTab(i);
                    if (tab && tab.onLauncherClosed) tab.onLauncherClosed();
                    mainScope.resetTabToTop(i);
                }
            }
        }
        
        implicitWidth: 600
        implicitHeight: {
            var searchHeight = Theme.dimensions.launcherSearchHeight;
            var padLarge = Theme.geometry.spacing.large;

            if (mainScope.isWallpaperActive) {
                return 700;
            }

            var count = root.activeListCount;
            var maxItems = 8;
            var visibleItems = Math.min(count, maxItems);
            
            var itemHeight = Theme.dimensions.launcherItemHeight;

            if (visibleItems === 0) {
                return searchHeight;
            }

            // Calculation based on ColumnLayout spacing and Loader margins:
            // searchHeight (50) 
            // + columnSpacing (12) 
            // + resultsArea (loader margins 12 top/bottom + listContent)
            var listHeight = (visibleItems * itemHeight) + (Math.max(0, visibleItems - 1) * padLarge);
            return searchHeight + (3 * padLarge) + listHeight;
        }


        // Bind currentItem
        Binding {
            target: mainScope
            property: "currentItem"
            value: root.activeTab ? root.activeTab.currentItem : null
        }

        property var currentItem: null
        
        property var tabModel: [
            { icon: "dashboard", key: "", component: "AppList.qml", placeholder: "Search..." },
            { icon: "content_paste", key: "", component: "ClipboardHistory.qml", placeholder: "Search clipboard..." },
            { icon: "image", key: "", component: "wallpaper/WallpaperSwitcher.qml", placeholder: "Search wallpapers...", isWallpaper: true },
            { icon: "palette", key: "", component: "ThemeSwitcher.qml", placeholder: "Search themes..." }
        ]

        readonly property var activeTabObject: (tabRepeater && root.currentTabIndex >= 0 && root.currentTabIndex < tabRepeater.count) ? tabRepeater.itemAt(root.currentTabIndex).item : null
        readonly property bool isWallpaperActive: (root.currentTabIndex >= 0 && root.currentTabIndex < tabModel.length) ? !!tabModel[root.currentTabIndex].isWallpaper : false

        property string currentPlaceholder: {
            if (root.currentTabIndex >= 0 && root.currentTabIndex < tabModel.length) {
                return tabModel[root.currentTabIndex].placeholder; 
            }
            return "Search...";
        }

        function getTab(index) {
            if (index < 0 || index >= tabRepeater.count) return null;
            return tabRepeater.itemAt(index).item;
        }

        function getTabListView(tab) {
            return (tab && tab.listView) ? tab.listView : null;
        }

        function getCurrentListView() {
            var tab = getTab(root.currentTabIndex);
            return getTabListView(tab);
        }

        function resetTabToTop(index) {
            var tab = getTab(index);
            if (!tab) return;
            
            // Bypass reset for Wallpaper tab to preserve randomized starting position
            if (mainScope.tabModel[index].isWallpaper) return;

            var listView = getTabListView(tab);
            if (listView && listView.count > 0) {
                // Check if listView supports positionViewAtBeginning (standard ListView)
                if (listView.positionViewAtBeginning) {
                    listView.currentIndex = 0;
                    listView.positionViewAtBeginning();
                }
            }
        }

        function switchTab(newIndex) {
            if (newIndex < 0 || newIndex >= mainScope.tabModel.length) return;

            LauncherService.resetInputStates();
            searchBar.text = "";
            
            // Deactivate old tab
            var oldTab = getTab(root.currentTabIndex);
            if (oldTab) oldTab.isActive = false;

            root.currentTabIndex = newIndex;
            mainScope.resetTabToTop(newIndex);
            
            // Activate new tab
            var newTab = getTab(newIndex);
            if (newTab) {
                newTab.isActive = true;
                mainScope.currentItem = newTab.currentItem;
            }

            searchBar.focusInput();
        }

        function nextTab() {
            mainScope.switchTab((root.currentTabIndex + 1) % mainScope.tabModel.length);
        }

        function prevTab() {
            mainScope.switchTab((root.currentTabIndex - 1 + mainScope.tabModel.length) % mainScope.tabModel.length);
        }

        function navigateHorizontal(dir) {
            var listView = getCurrentListView();
            if (listView) {
                if (dir === -1 && listView.safeDecrement)
                    listView.safeDecrement();
                else if (dir === 1 && listView.safeIncrement)
                    listView.safeIncrement();
            }
        }

        function activateCurrentItem() {
            var tab = getTab(root.currentTabIndex);
            if (tab && tab.activateCurrentItem)
                tab.activateCurrentItem();
        }

        function navigateDown() {
            var tab = getTab(root.currentTabIndex);
            var listView = getCurrentListView();
            if (tab) tab.forceActiveFocus();

            // Ensure tab is focused for key events
            if (listView && listView.count > 0) {
                LauncherService.resetInputStates();
                listView.forceActiveFocus();
                if (listView.currentIndex === -1)
                    listView.currentIndex = 0;
                else
                    listView.incrementCurrentIndex();
            }
        }

        function navigateUp() {
            var listView = getCurrentListView();
            if (listView) {
                if (listView.currentIndex > 0) {
                    LauncherService.resetInputStates();
                    listView.decrementCurrentIndex();
                } else {
                    backToSearch("");
                }
            }
        }

        function backToSearch(text) {
            LauncherService.resetInputStates();
            searchBar.focusInput();
            if (text === "\b") {
                if (searchBar.text.length > 0)
                    searchBar.text = searchBar.text.substring(0, searchBar.text.length - 1);

            } else if (text && text.length > 0) {
                searchBar.text += text;
            }
        }

        function handleListMouseMove(listView, index, mouse) {
            var globalPos = listView.mapToGlobal(mouse.x, mouse.y);
            if (LauncherService.handleMouseMove(globalPos.x, globalPos.y))
                listView.currentIndex = index;
        }

        // Centralized Keyboard Handling
        Keys.onPressed: (event) => {
            var listView = getCurrentListView();
            if (event.key === Qt.Key_Down) {
                navigateDown();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                navigateUp();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                activateCurrentItem();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                root.close();
                event.accepted = true;
            } else if (listView && listView.activeFocus) {
                if (event.key === Qt.Key_Delete) {
                    event.accepted = false; 
                    return;
                }
                
                var isSpecial = (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab || event.key === Qt.Key_Left || event.key === Qt.Key_Right);
                if (!isSpecial && event.text.length > 0) {
                    backToSearch(event.text);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Backspace) {
                    backToSearch("\b");
                    event.accepted = true;
                }
            }
        }

        anchors.fill: parent
        focus: true

        Shortcut {
            sequence: "Tab"
            onActivated: mainScope.nextTab()
        }

        Shortcut {
            sequence: "Shift+Tab"
            onActivated: mainScope.prevTab()
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.geometry.spacing.large // Precise 12px gap between search and results

            LauncherSearch {
                id: searchBar

                property alias searchField: searchBar
                
                // Dynamic Placeholder Binding
                placeholderText: mainScope.currentPlaceholder

                activePageHints: {
                    var tab = mainScope.getTab(root.currentTabIndex);
                    return (tab && tab.pageHints) ? tab.pageHints : [];
                }
                clickable: true
                Layout.fillWidth: true
                tabModel: mainScope.tabModel
                currentIndex: root.currentTabIndex
                onTabClicked: (index) => {
                    return mainScope.switchTab(index);
                }
                
                visible: !mainScope.isWallpaperActive
                Layout.preferredHeight: visible ? Theme.dimensions.launcherSearchHeight : 0

                
                inputItem.Keys.onLeftPressed: (event) => {
                    if (mainScope.isWallpaperActive) {
                        mainScope.navigateHorizontal(-1);
                        event.accepted = true;
                    } else {
                        event.accepted = false;
                    }
                }
                inputItem.Keys.onRightPressed: (event) => {
                     if (mainScope.isWallpaperActive) {
                        mainScope.navigateHorizontal(1);
                        event.accepted = true;
                    } else {
                        event.accepted = false;
                    }
                }

                onDownPressed: mainScope.navigateDown()
                onPressedSignal: {
                    LauncherService.resetInputStates();
                    searchBar.focusInput();
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: mainScope.isWallpaperActive || root.activeListCount > 0

                // Page Background
                BaseBlock {
                    anchors.fill: parent
                    backgroundColor: mainScope.isWallpaperActive ? 
                        Theme.alpha(Theme.colors.background, Theme.blur.backgroundOpacity) : 
                        Theme.alpha(Theme.colors.surface, Theme.blur.surfaceOpacity)
                    borderEnabled: false
                    z: -1
                }


                // Dynamic Tab Loader Container
                FocusScope {
                    anchors.fill: parent

                    
                    Repeater {
                        id: tabRepeater
                        model: mainScope.tabModel
                        
                        Loader {
                            id: tabLoader
                            anchors.fill: parent
                            anchors.margins: modelData.isWallpaper ? 0 : Theme.geometry.spacing.large
                            
                            // Lazy loading logic: only load if active or previously loaded
                            property bool wasEverActive: false
                            active: (root.currentTabIndex === index) || wasEverActive
                            
                            onActiveChanged: {
                                if (active) wasEverActive = true;
                            }

                            source: modelData.component
                            
                            opacity: root.currentTabIndex === index ? 1 : 0
                            scale: root.currentTabIndex === index ? 1 : 0.98
                            z: root.currentTabIndex === index ? 1 : 0
                            
                            Behavior on opacity { BaseAnimation {} }
                            Behavior on scale { BaseAnimation { easing.type: Easing.OutBack } }

                            onLoaded: {
                                if (item) {
                                    // Connect signals
                                    item.closeRequested.connect(root.close);
                                    item.mouseMoveRequested.connect((index, mouse) => {
                                         mainScope.handleListMouseMove(item.listView, index, mouse);
                                    });
                                    item.tabRedirectRequested.connect((targetIndex) => {
                                         Qt.callLater(() => {
                                            searchBar.text = "";
                                            mainScope.switchTab(targetIndex);
                                         });
                                    });
                                    
                                    // Bind properties
                                    item.searchText = Qt.binding(() => searchBar.text);
                                    item.isActive = Qt.binding(() => root.currentTabIndex === index);
                                }
                            }
                            
                            Connections {
                                target: tabLoader.item || null
                                function onCurrentItemChanged() {
                                    if (root.currentTabIndex === index) {
                                        mainScope.currentItem = tabLoader.item.currentItem;
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
