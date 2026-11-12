import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';

const model = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('../design/Appearance.js', import.meta.url), 'utf8'), model);
const normalize = value => JSON.parse(JSON.stringify(model.normalize(value)));
const hostModel = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('../BarModel.js', import.meta.url), 'utf8'), hostModel);

test('desktop controls leave the rendered strip without changing saved widget order or settings', () => {
    const saved = [{id: 'omarchy.indicators', items: ['Dnd']}, {id: 'velunori.clock'},
        {id: 'omarchy.indicators', alwaysShow: true}, {id: 'omarchy.weather'}];
    const before = JSON.stringify(saved);
    assert.equal(JSON.stringify(hostModel.withoutDesktopControls(saved)), JSON.stringify([saved[1], saved[3]]));
    assert.equal(JSON.stringify(saved), before);
});

test('invalid and older settings fall back without dropping known values', () => {
    assert.deepEqual(normalize(null), { style: 'island', accent: 'lavender', motion: true });
    assert.deepEqual(normalize({ style: 'unknown', accent: '#bad', motion: 0 }), normalize(null));
    assert.deepEqual(normalize({ style: 'orbit', accent: 'mint', motion: false, injected: true }),
        { style: 'orbit', accent: 'mint', motion: false });
});

test('preview drafts do not mutate persisted settings', () => {
    const saved = { style: 'island', accent: 'pearl', motion: true };
    const draft = model.normalize(saved);
    draft.style = 'orbit';
    assert.equal(saved.style, 'island');
    assert.equal(model.normalize(saved).style, 'island');
});

test('Orbit avoids collisions with asymmetric sections', () => {
    assert.equal(model.fitsOrbit(1000, 120, 150, 350, 20), true);
    assert.equal(model.fitsOrbit(800, 120, 150, 350, 20), false);
    assert.equal(model.fitsOrbit(890, 120, 150, 350, 20), true);
    assert.equal(model.fitsOrbit(890, 350, 150, 120, 20), true);
});

test('composite widgets can suppress the host mark with zero without affecting ordinary widgets', () => {
    assert.equal(hostModel.panelIndicatorExtent(0, 72), 0);
    assert.equal(hostModel.panelIndicatorExtent(32, 72), 32);
    for (const hint of [undefined, null, -1, NaN, Infinity]) assert.equal(hostModel.panelIndicatorExtent(hint, 72), 72);
});
