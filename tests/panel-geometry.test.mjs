import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const geometry = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('../kit/PanelGeometry.js', import.meta.url), 'utf8'), geometry);
test('Orbit anchors to its capsule instead of the off-center icon', () => {
    const viewport = {parent:null,velunoriPanelAnchor:false};
    const capsule = {parent:viewport,velunoriPanelAnchor:true,x:100,width:280};
    const widget = {parent:{parent:capsule},x:240,width:34};
    assert.equal(geometry.islandAnchor(widget),capsule);
    assert.equal(capsule.x+capsule.width/2,240);
});
test('Island anchors to the complete surface when the three sections join', () => {
    const viewport = {parent:null,velunoriPanelAnchor:true};
    const section = {parent:viewport,velunoriPanelAnchor:false};
    const widget = {parent:section};
    assert.equal(geometry.islandAnchor(widget),viewport);
    section.velunoriPanelAnchor=true;
    assert.equal(geometry.islandAnchor(widget),section);
});
test('Other bars retain their icon anchor', () => {
    const widget={parent:{parent:null}};
    assert.equal(geometry.islandAnchor(widget),widget);
    assert.equal(geometry.islandAnchor(null),null);
});
