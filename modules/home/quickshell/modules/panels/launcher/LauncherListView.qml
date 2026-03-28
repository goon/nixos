import QtQuick
import QtQuick.Controls
import qs

ListView {
    id: root

    // Common Configuration
    clip: true
    spacing: Theme.geometry.spacing.large
    activeFocusOnTab: false
    
    // Disable highlight animations for snappier feel
    highlightMoveDuration: 0
    highlightResizeDuration: 0

    // Common ScrollBar
    ScrollBar.vertical: BaseScrollBar {
        policy: ScrollBar.AlwaysOff
    }

    // Helper functions often used in tabs
    function safeIncrement() {
        if (currentIndex < count - 1) {
            incrementCurrentIndex();
        }
    }

    function safeDecrement() {
        if (currentIndex > 0) {
            decrementCurrentIndex();
        }
    }
}
