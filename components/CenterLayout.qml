import QtQuick

// Symmetric room around the actual center box, not around the sum of its
// siblings. A growing weather label must not push the clock off center.
Item {
    property real beforeWidth: 0
    property real centerWidth: 0
    property real afterWidth: 0
    implicitWidth: centerWidth + 2 * Math.max(beforeWidth, afterWidth)
    readonly property real centerX: (width - centerWidth) / 2
    readonly property real beforeX: centerX - beforeWidth
    readonly property real afterX: centerX + centerWidth
}
