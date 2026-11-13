import QtQuick
import Quickshell

ShellRoot {
    FloatingWindow {
        visible: true; implicitWidth: 1380; implicitHeight: 850; color: "#19191f"
        Rectangle {
            id: board
            anchors.fill: parent; color: "#19191f"
            Text { x: 44; y: 30; text: "VELUNORI  /  BRAND DIRECTIONS"; color: "#a4a2b1"; font.pixelSize: 11; font.letterSpacing: 2 }
            Text { x: 44; y: 61; text: "Trzy różne znaki. Jeden spokojny pulpit."; color: "#eeedf3"; font.pixelSize: 26; font.weight: Font.Medium }
            Row {
                x: 44; y: 120; spacing: 22
                Repeater {
                    model: [
                        {number:"01",name:"Portal",file:"portal",word:"velunori",family:"Adwaita Sans",weight:Font.DemiBold,tracking:0.6,description:"Spokojny, miękki i architektoniczny.\nŁuk z prześwitem w środku.",detail:"Motyw: własna przestrzeń",tag:"SOFT / ARCHITECTURAL"},
                        {number:"02",name:"Orbita",file:"orbit",word:"VELUNORI",family:"Adwaita Sans",weight:Font.Medium,tracking:3,description:"Otwarty pierścień i odłączony element.\nRuch, lekkość i pływające wyspy.",detail:"Motyw: swoboda i ruch",tag:"FLUID / SPATIAL"},
                        {number:"03",name:"Pryzmat",file:"prism",word:"Velunori",family:"Nimbus Roman",weight:Font.Normal,tracking:0,description:"Trzy osobne płaszczyzny.\nWyrazisty znak i redakcyjna typografia.",detail:"Motyw: modułowość i porządek",tag:"GEOMETRIC / EDITORIAL"}
                    ]
                    Rectangle {
                        id: card
                        required property var modelData
                        width: 416; height: 665; radius: 20; color: "#202026"; border.color: "#3b3943"
                        Text { x: 25; y: 22; text: card.modelData.number + " / " + card.modelData.name; color: "#eeedf3"; font.pixelSize: 17; font.weight: Font.DemiBold }
                        Text { x: 25; y: 54; text: card.modelData.tag; color: "#a4a2b1"; font.pixelSize: 9; font.letterSpacing: 1.5 }
                        Image { x: 148; y: 108; width: 120; height: 120; sourceSize.width: 120; sourceSize.height: 120; source: Qt.resolvedUrl("brand-concepts/" + card.modelData.file + ".svg") }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 263; text: card.modelData.word; color: "#eeedf3"; font.family: card.modelData.family; font.weight: card.modelData.weight; font.pixelSize: card.modelData.file === "orbit" ? 27 : 38; font.letterSpacing: card.modelData.tracking }
                        Text { x: 25; y: 344; width: 366; text: card.modelData.description; color: "#a4a2b1"; font.pixelSize: 13; lineHeight: 1.55 }
                        Rectangle { x: 25; y: 419; width: 366; height: 1; color: "#3b3943" }
                        Text { x: 25; y: 442; text: "IKONA NA PASKU  /  18 PX"; color: "#a4a2b1"; font.pixelSize: 9; font.letterSpacing: 1.2 }
                        Rectangle {
                            x: 25; y: 471; width: 211; height: 40; radius: 20; color: "#202026"; border.color: "#48464f"
                            Image { x: 16; y: 11; width: 18; height: 18; sourceSize.width: 18; sourceSize.height: 18; source: Qt.resolvedUrl("brand-concepts/" + card.modelData.file + ".svg") }
                            Row { x: 49; y: 16; spacing: 15
                                Rectangle { width: 28; height: 8; radius: 4; color: "#c4aff1" }
                                Repeater { model: 4; Rectangle { width: 5; height: 5; radius: 3; y: 1.5; color: "#a4a2b1" } }
                            }
                        }
                        Row { x: 25; y: 548; spacing: 9
                            Repeater { model: ["#c4aff1","#a0ddbf","#e8dfd1","#eeedf3"]
                                Rectangle { required property string modelData; width: 17; height: 17; radius: 8.5; color: modelData }
                            }
                        }
                        Text { x: 25; y: 603; text: card.modelData.detail; color: "#eeedf3"; font.pixelSize: 12 }
                    }
                }
            }
            Text { x: 44; y: 809; text: "Projekty do wyboru · wektory SVG · obecna ikona pozostaje bez zmian"; color: "#a4a2b1"; font.pixelSize: 11 }
        }
        Timer {
            interval: 650; running: true
            onTriggered: board.grabToImage(function(result) {
                console.log(result.saveToFile(Quickshell.env("VELUNORI_CONCEPTS_PATH")) ? "CONCEPTS_SAVED" : "CONCEPTS_FAILED");
                Qt.quit();
            })
        }
    }
}
