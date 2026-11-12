pragma ComponentBehavior: Bound
import QtQuick

// Drawn from primitives so previews stay crisp at any display scale.
Rectangle {
    id: root
    property string style: "island"
    property color accent: "#c4aff1"
    radius: 12
    color: "#17171d"
    clip: true
    gradient: Gradient {
        GradientStop { position: 0; color: "#33313e" }
        GradientStop { position: 1; color: "#16161c" }
    }

    component Capsule: Rectangle {
        color: "#29292f"
        border.color: "#605b6b"
        radius: height / 2
        height: 20
    }

    Capsule {
        x: root.style === "island" ? parent.width * 0.13 : 12
        y: 14
        width: root.style === "island" ? parent.width * 0.74 : parent.width * 0.23
        Row {
            x: 9; anchors.verticalCenter: parent.verticalCenter; spacing: 4
            Rectangle { width: 14; height: 5; radius: 3; color: root.accent }
            Repeater {
                model: 2
                Rectangle { width: 4; height: 4; radius: 2; color: "#8b8798" }
            }
        }
        Text {
            visible: root.style === "island"
            anchors.centerIn: parent
            text: "14:44"; color: "#eeedf3"; font.pixelSize: 8
        }
        Text {
            visible: root.style === "island"
            anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter
            text: "◉  ♫  ▰"; color: root.accent; font.pixelSize: 8
        }
    }
    Capsule {
        visible: root.style === "orbit"
        y: 14; width: 54; anchors.horizontalCenter: parent.horizontalCenter
        Text { anchors.centerIn: parent; text: "14:44"; color: "#eeedf3"; font.pixelSize: 8 }
    }
    Capsule {
        visible: root.style === "orbit"
        y: 14; width: parent.width * 0.23; anchors.right: parent.right; anchors.rightMargin: 12
        Text { anchors.centerIn: parent; text: "◉  ♫  ▰"; color: root.accent; font.pixelSize: 8 }
    }
    Rectangle {
        x: 18; y: 53; width: (parent.width - 44) * 0.46; height: parent.height - 69
        color: "#24242c"; radius: 7; border.color: root.accent
        Column {
            x: 10; y: 12; spacing: 6
            Repeater {
                model: 4
                Rectangle {
                    required property int index
                    width: index % 2 === 0 ? 48 : 66; height: 3; radius: 1
                    color: index === 0 ? root.accent : "#5d596c"
                }
            }
        }
    }
    Rectangle {
        anchors.right: parent.right; anchors.rightMargin: 18
        y: 53; width: (parent.width - 44) * 0.54; height: parent.height - 69
        color: "#24242c"; radius: 7; border.color: "#48464f"
        Column {
            x: 10; y: 12; spacing: 6
            Repeater {
                model: 4
                Rectangle {
                    required property int index
                    width: index % 2 === 0 ? 62 : 44; height: 3; radius: 1; color: "#5d596c"
                }
            }
        }
    }
}
