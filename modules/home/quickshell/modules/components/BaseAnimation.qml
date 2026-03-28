import QtQuick
import qs

/**
 * BaseAnimation - Standardized Animation Hub for the shell
 * Can be used as a simple PropertyAnimation or specialized for Springs/Staggers.
 */
SequentialAnimation {
    id: root
    
    // Compatibility properties
    property alias target: anim.target
    property alias targets: anim.targets
    property alias property: anim.property
    property alias to: anim.to
    property alias from: anim.from
    property alias easing: anim.easing
    
    // Extensions
    property int delay: 0
    property string speed: "normal" // fast, normal, slow
    property int duration: -1
    
    readonly property int _dur: {
        if (duration !== -1) return duration;
        if (speed === "fast") return Theme.animations.fast;
        if (speed === "slow") return Theme.animations.slow;
        return Theme.animations.normal;
    }

    PauseAnimation {
        duration: root.delay
    }

    PropertyAnimation {
        id: anim
        duration: root._dur
        easing.type: Theme.animations.easingType
        easing.bezierCurve: Theme.animations.bezierCurve
    }

    // Specialized Spring Component
    component Spring: SpringAnimation {
        property string profile: "gooey" // gooey, snappy
        
        spring: profile === "gooey" ? 4 : 2
        damping: profile === "gooey" ? 0.7 : 0.5
        mass: profile === "gooey" ? 0.8 : 1.0
    }
}
