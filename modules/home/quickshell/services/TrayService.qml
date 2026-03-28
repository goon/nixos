import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
pragma Singleton

QtObject {

    id: root

    // Currently open menu (TrayMenu instance)
    property var currentMenu: null
    // Mirror of SystemTray.items for tracking
    property var trayItems: SystemTray.items
    
    // Explicitly reactive count via property binding
    readonly property int itemCount: SystemTray.items.values.length

    // Quick check for menu state
    property bool hasOpenMenu: currentMenu !== null

    // Signals
    signal menuOpened(var menu)
    signal menuClosed()

    // Open a menu, closing any previous menu
    function openMenu(menu, trayItem, position) {
        // Close any existing menu first
        if (currentMenu)
            closeCurrentMenu();

        // Set the new menu as current
        currentMenu = menu;
        // Emit signal
        menuOpened(menu);
    }

    // Close the currently open menu
    function closeCurrentMenu() {
        if (currentMenu) {
            var menu = currentMenu;
            currentMenu = null;
            
            if (menu && menu.close !== undefined) {
                menu.close();
            } else if (menu && menu.hideMenu !== undefined) {
                menu.hideMenu();
            }
            
            // Emit signal
            menuClosed();
        }
    }

    // Force close all menus (safety function)
    function closeAllMenus() {
        closeCurrentMenu();
    }

    // Handle menu destroyed externally
    function onMenuDestroyed(menu) {
        if (currentMenu === menu) {
            currentMenu = null;
            menuClosed();
        }
    }

}
