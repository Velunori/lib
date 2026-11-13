//@ pragma OmarchyLoadPatch
import QtQuick
import Quickshell
import "../kit" as V

ShellRoot {
    FloatingWindow {
        visible: true; implicitWidth: 960; implicitHeight: 600; color: "#202026"
        Rectangle {
            id: sheet
            anchors.fill: parent; color: "#202026"
            Text { x: 48; y: 33; text: "VELUNORI   /   VISUAL IDENTITY"; color: "#a4a2b1"; font.pixelSize: 10; font.letterSpacing: 2 }
            V.BrandMark { x: 51; y: 104; width: 104; height: 104 }
            Text { x: 199; y: 125; text: "Velunori"; color: "#eeedf3"; font.family: "Nimbus Roman"; font.pixelSize: 52; font.weight: Font.Normal; font.letterSpacing: 0 }
            Text { x: 202; y: 184; text: "PRYZMAT  ·  Three planes. One clear identity."; color: "#a4a2b1"; font.pixelSize: 14 }
            Rectangle { x: 48; y: 260; width: 864; height: 1; color: "#48464f" }
            Row {
                x: 48; y: 298; spacing: 16
                Repeater {
                    model: ["#c4aff1", "#a0ddbf", "#e8dfd1", "#eeedf3"]
                    Rectangle {
                        required property string modelData
                        width: 138; height: 125; radius: 16; color: "#29292f"; border.color: "#48464f"
                        V.BrandMark { width: 48; height: 48; anchors.horizontalCenter: parent.horizontalCenter; y: 20; ink: parent.modelData }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 92; text: parent.modelData; color: "#a4a2b1"; font.pixelSize: 11; font.family: "monospace" }
                    }
                }
                Rectangle {
                    width: 138; height: 125; radius: 16; color: "#eeedf3"
                    V.BrandMark { width: 48; height: 48; anchors.horizontalCenter: parent.horizontalCenter; y: 20; ink: "#202026" }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; y: 92; text: "MONO"; color: "#48464f"; font.pixelSize: 11; font.letterSpacing: 2 }
                }
            }
            Rectangle {
                x: 48; y: 478; width: 224; height: 40; radius: 20; color: "#202026"; border.color: "#48464f"
                V.BrandMark { x: 17; y: 11; width: 18; height: 18 }
                Row {
                    x: 50; y: 16; spacing: 15
                    Rectangle { width: 28; height: 8; radius: 4; color: "#c4aff1" }
                    Repeater { model: 4; Rectangle { width: 5; height: 5; radius: 3; y: 1.5; color: "#a4a2b1" } }
                }
            }
            Text { x: 302; y: 486; text: "18 px mark  ·  transparent vector  ·  follows the accent"; color: "#a4a2b1"; font.pixelSize: 12 }
        }
        Timer {
            interval: 500; running: true
            onTriggered: sheet.grabToImage(function(result) {
                console.log(result.saveToFile(Quickshell.env("VELUNORI_BRAND_PREVIEW_PATH")) ? "BRANDING_PREVIEW_SAVED" : "BRANDING_PREVIEW_FAILED");
                Qt.quit();
            })
        }
    }
}
