// sizes match the Plymouth theme so boot and login splash line up
import QtQuick

Rectangle {
    id: root
    color: "black"

    property int stage  // 1..6, set by ksplash

    readonly property int logoSize: Math.round(Math.min(width, height) * 0.07)
    readonly property int barWidth: Math.round(width * 0.072)
    readonly property int barHeight: Math.max(4, Math.round(barWidth * 0.02))

    Image {
        id: logo
        anchors.centerIn: parent
        source: "images/apple.svg"
        sourceSize.width: root.logoSize
        sourceSize.height: root.logoSize
    }

    Rectangle {
        id: track
        anchors.horizontalCenter: parent.horizontalCenter
        y: logo.y + logo.height + Math.round(root.height * 0.035)
        width: root.barWidth
        height: root.barHeight
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.25)

        Rectangle {
            height: parent.height
            radius: parent.radius
            color: "white"
            width: parent.width * Math.min(1, root.stage / 6)
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        }
    }
}
