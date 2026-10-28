import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: root
    width: 1920
    height: 1080

    readonly property string fontFamily: config.font || "SF Pro Display"
    property string userName: ""
    property string realName: ""
    property string userIcon: ""
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property date now: new Date()

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.now = new Date()
    }

    Repeater {
        model: userModel
        delegate: Item {
            Component.onCompleted: {
                const wanted = userModel.lastIndex >= 0 ? userModel.lastIndex : 0;
                if (index === wanted) {
                    root.userName = model.name;
                    root.realName = model.realName || model.name;
                    root.userIcon = model.icon || "";
                }
            }
        }
    }

    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Slight dim so white text stays readable on bright wallpapers.
    Rectangle { anchors.fill: parent; color: "black"; opacity: 0.12 }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.07
        spacing: -root.height * 0.012

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(root.now, "dddd, MMMM d")
            color: Qt.rgba(1, 1, 1, 0.9)
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.height * 0.024)
            font.weight: Font.DemiBold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(root.now, "h:mm")
            color: Qt.rgba(1, 1, 1, 0.92)
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.height * 0.13)
            font.weight: Font.Bold
        }
    }

    Column {
        id: login
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.68
        spacing: Math.round(root.height * 0.012)

        Item {
            id: avatar
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(root.height * 0.065)
            height: width

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(1, 1, 1, 0.25)
                visible: face.status !== Image.Ready
                Text {
                    anchors.centerIn: parent
                    text: root.realName.charAt(0).toUpperCase()
                    color: "white"
                    font.family: root.fontFamily
                    font.pixelSize: parent.height * 0.45
                    font.weight: Font.DemiBold
                }
            }
            Image {
                id: face
                anchors.fill: parent
                source: root.userIcon
                sourceSize.width: width * 2
                sourceSize.height: height * 2
                fillMode: Image.PreserveAspectCrop
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: face
                visible: face.status === Image.Ready
                maskEnabled: true
                maskSource: faceMask
            }
            Item {
                id: faceMask
                anchors.fill: parent
                layer.enabled: true
                visible: false
                Rectangle { anchors.fill: parent; radius: width / 2 }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.realName
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.height * 0.015)
            font.weight: Font.DemiBold
        }

        TextField {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(root.height * 0.19)
            height: Math.round(root.height * 0.03)
            echoMode: TextInput.Password
            passwordCharacter: "●"
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.height * 0.0125)
            horizontalAlignment: TextInput.AlignHCenter
            focus: true
            background: Rectangle {
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.2)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, password.activeFocus ? 0.35 : 0.15)
            }
            onAccepted: sddm.login(root.userName, text, root.sessionIndex)

            Text {
                anchors.centerIn: parent
                visible: password.text.length === 0
                text: "Enter Password"
                color: Qt.rgba(1, 1, 1, 0.6)
                font: password.font
            }

            SequentialAnimation on x {
                id: shake
                running: false
                loops: 2
                NumberAnimation { to: password.x - 10; duration: 50 }
                NumberAnimation { to: password.x + 10; duration: 100 }
                NumberAnimation { to: password.x; duration: 50 }
            }
        }

        Text {
            id: hint
            anchors.horizontalCenter: parent.horizontalCenter
            text: keyboard.capsLock ? "Caps Lock is on" : ""
            color: Qt.rgba(1, 1, 1, 0.75)
            font.family: root.fontFamily
            font.pixelSize: Math.round(root.height * 0.011)
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.round(root.height * 0.05)
        spacing: Math.round(root.height * 0.04)

        Repeater {
            model: [
                { label: "Sleep", glyph: "☾", act: function () { sddm.suspend(); }, on: sddm.canSuspend },
                { label: "Restart", glyph: "↻", act: function () { sddm.reboot(); }, on: sddm.canReboot },
                { label: "Shut Down", glyph: "⏻", act: function () { sddm.powerOff(); }, on: sddm.canPowerOff }
            ]
            delegate: Column {
                visible: modelData.on
                spacing: Math.round(root.height * 0.006)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(root.height * 0.034)
                    height: width
                    radius: width / 2
                    color: Qt.rgba(1, 1, 1, area.containsMouse ? 0.3 : 0.18)
                    Text {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        color: "white"
                        font.pixelSize: parent.height * 0.5
                    }
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: modelData.act()
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: modelData.label
                    color: Qt.rgba(1, 1, 1, 0.85)
                    font.family: root.fontFamily
                    font.pixelSize: Math.round(root.height * 0.0105)
                }
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = "";
            hint.text = "Incorrect password";
            shake.start();
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
