function readBlocks(text) {
    var blocks = {};
    String(text || "").split("\n").forEach(function(line) {
        var fields = line.split("\t");
        if (fields.length >= 3 && fields[1] && /^\d+$/.test(fields[0]))
            blocks[fields[1]] = Number(fields[0]);
    });
    return blocks;
}

function blockOf(id) { return Math.floor((id - 1) / 10); }
function slotOf(id) { return (id - 1) % 10 + 1; }
function monitorBlock(blocks, name, activeId) {
    return blocks[name] !== undefined ? blocks[name] : activeId > 0 ? blockOf(activeId) : 0;
}

function workspaceIds(values, perMonitor, monitorName, block) {
    var base = perMonitor ? block * 10 : 0;
    var ids = [base + 1, base + 2, base + 3, base + 4, base + 5], guests = [];
    values.forEach(function(workspace) {
        var id = workspace.id;
        if (id <= 0) return;
        if ((!perMonitor && id <= 10) || (perMonitor && blockOf(id) === block)) {
            if (ids.indexOf(id) === -1) ids.push(id);
        } else if (perMonitor && workspace.monitor && workspace.monitor.name === monitorName && guests.indexOf(id) === -1) guests.push(id);
    });
    return ids.sort(function(a,b) { return a-b; }).concat(guests.sort(function(a,b) { return a-b; }));
}

function focusCommand(id, perMonitor, monitorName, block) {
    var expression = perMonitor && monitorName && blockOf(id) === block
        ? "o.workspaces.focus(" + slotOf(id) + ", " + JSON.stringify(monitorName) + ")"
        : "hl.dsp.focus({ workspace = " + JSON.stringify(String(id)) + " })";
    return "hyprctl dispatch '" + expression.replace(/'/g, "'\\''") + "'";
}
