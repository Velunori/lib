// Find the visible Island/Orbit capsule containing the clicked widget.
// Other bars do not carry this marker, so retain their widget anchoring.
function islandAnchor(item) {
    var current = item;
    while (current) {
        if ("velunoriPanelAnchor" in current && current.velunoriPanelAnchor === true) return current;
        current = current.parent;
    }
    return item;
}
