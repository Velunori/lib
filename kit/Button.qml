import "../components"
import "." as Kit

ActionButton {
    id: root
    property var bar: null
    property Kit.Theme theme: Kit.Theme { bar: root.bar }
    accent: theme.accent
}
