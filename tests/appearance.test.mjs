import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';

const model = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('../design/Appearance.js', import.meta.url), 'utf8'), model);
const normalize = value => JSON.parse(JSON.stringify(model.normalize(value)));
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

