// Shared, serializable settings. Unknown fields are intentionally excluded.
function normalize(value) {
    var input = value || {};
    return {
        style: input.style === "orbit" ? "orbit" : "island",
        accent: /^(lavender|mint|pearl)$/.test(input.accent) ? input.accent : "lavender",
        motion: input.motion !== false
    };
}

function accentColor(name) {
    return name === "mint" ? "#a0ddbf" : name === "pearl" ? "#e8dfd1" : "#c4aff1";
}

// Orbit needs space on BOTH sides of its centered capsule.
function fitsOrbit(available, left, center, right, gap) {
    return available >= center + 2 * Math.max(left, right) + 2 * gap;
}
