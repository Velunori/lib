import QtQuick

// A drawer hosts the same ordinary widget list used on the strip. Keep the
// list mounted when collapsed; rebuild only when its source/host disappears.
Loader {
    id: root
    property Item host: null
    property Item fallbackParent: null
    property Component content: null
    parent: host || fallbackParent
    active: !!host
    sourceComponent: content
}
