import QtQuick
import Quickshell
import qs

Item {
    id: root

    // Data source array containing values (0.0 to 1.0 ideally, or raw max scaled)
    property var modelData: []
    
    // Line and Fill colors
    property color lineColor: Theme.colors.accent
    property color fillColor: Theme.alpha(lineColor, 0.2)
    
    // Value range properties
    property real maxValue: 1.0
    property real minValue: 0.0
    property bool autoScale: true // If true, max value adjusts to the highest point in modelData
    
    // Entrance animation progress (0.0 to 1.0)
    property real drawProgress: 1.0
    Behavior on drawProgress {
        BaseAnimation {
            duration: 800
            easing.type: Easing.OutCubic
        }
    }
    
    // Internal scaling state
    property real targetMax: maxValue
    property real currentMax: maxValue
    
    Behavior on currentMax {
        BaseAnimation {
            // Scale up quickly to catch spikes, scale down slowly to maintain context
            duration: root.currentMax < root.targetMax ? 100 : 2500 
            easing.type: Easing.OutCubic
        }
    }

    property int lineWidth: 2
    
    // Sliding smoothing
    property real slideOffset: 0
    BaseAnimation {
        id: slideAnim
        target: root
        property: "slideOffset"
        from: 1
        to: 0
        duration: Stats.pollTimer.interval
        easing.type: Easing.Linear
    }

    onSlideOffsetChanged: canvas.requestPaint()

    // Force canvas redraw when data changes
    onModelDataChanged: {
        if (root.autoScale) {
            var localMax = root.minValue
            for (var i = 0; i < root.modelData.length; i++) {
                if (root.modelData[i] > localMax)
                    localMax = root.modelData[i]
            }
            // Add a small 10% ceiling buffer if we auto-scale, or fallback to 1 passed max
            root.targetMax = localMax > 0 ? localMax * 1.1 : root.maxValue
        } else {
            root.targetMax = root.maxValue
        }

        slideOffset = 1 // Force immediate reset to start position
        slideAnim.restart()
        canvas.requestPaint()
    }

    onCurrentMaxChanged: canvas.requestPaint()
    onDrawProgressChanged: canvas.requestPaint()

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (!root.modelData || root.modelData.length < 2 || root.drawProgress <= 0)
                return

            // Apply corner clipping bounds matching BaseBlock properties
            ctx.save()
            ctx.beginPath()
            ctx.roundedRect(0, 0, width, height, Theme.geometry.radius, Theme.geometry.radius)
            ctx.clip()

            // Determine effective Max Value for scaling
            var effectiveMax = root.currentMax
            
            // Prevent divide by zero
            if (effectiveMax <= root.minValue)
                effectiveMax = root.minValue + 1

            var availableWidth = width * root.drawProgress
            var stepX = availableWidth / (root.modelData.length - 2)
            var rangeY = effectiveMax - root.minValue

            // Begin path
            ctx.beginPath()
            
            // Move to bottom-left corner
            ctx.moveTo(0, height)
            
            // Calculate and draw line points
            for (var j = 0; j < root.modelData.length; j++) {
                var x = (j - 1 + root.slideOffset) * stepX
                var val = Math.max(root.minValue, Math.min(root.modelData[j], effectiveMax))
                var y = height - ((val - root.minValue) / rangeY * height)

                if (j === 0) {
                    ctx.lineTo(x, y)
                } else {
                    ctx.lineTo(x, y)
                }
            }

            // Move to bottom-right corner to close the fill path
            var lastX = (root.modelData.length - 2 + root.slideOffset) * stepX
            ctx.lineTo(lastX, height)
            ctx.closePath()

            // Fill area
            ctx.fillStyle = root.fillColor
            ctx.fill()

            // Draw the top line explicitly
            ctx.beginPath()
            for (var k = 0; k < root.modelData.length; k++) {
                var px = (k - 1 + root.slideOffset) * stepX
                var pval = Math.max(root.minValue, Math.min(root.modelData[k], effectiveMax))
                var py = height - ((pval - root.minValue) / rangeY * height)

                if (k === 0) {
                    ctx.moveTo(px, py)
                } else {
                    ctx.lineTo(px, py)
                }
            }
            
            ctx.lineWidth = root.lineWidth
            ctx.strokeStyle = root.lineColor
            ctx.stroke()
            
            // Restore context bounds
            ctx.restore()
        }
    }
}
