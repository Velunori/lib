import fs from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
const model = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('../components/WorkspaceModel.js', import.meta.url), 'utf8'), model);
const plain = value => JSON.parse(JSON.stringify(value));

test('legacy mode ignores a stale block file and retains global IDs', () => {
    assert.deepEqual(plain(model.workspaceIds([{id:9},{id:12},{id:-1}], false, 'DP-2', 1)), [1,2,3,4,5,9]);
    assert.match(model.focusCommand(3,false,'DP-2',1), /hl.dsp.focus/);
});
test('each monitor lists its own IDs and temporary guests, never another connected monitor’s normal slots', () => {
    const rows = [{id:1,monitor:{name:'DP-1'}},{id:18,monitor:{name:'DP-2'}},{id:25,monitor:{name:'DP-2'}},{id:28,monitor:{name:'DP-3'}},{id:-1}];
    assert.deepEqual(plain(model.workspaceIds(rows,true,'DP-2',1)), [11,12,13,14,15,18,25]);
    assert.equal(model.slotOf(18),8);
    assert.match(model.focusCommand(13,true,'DP-2',1), /o.workspaces.focus\(3, "DP-2"\)/);
    assert.match(model.focusCommand(25,true,'DP-2',1), /hl.dsp.focus/);
});
test('block mapping follows physical reconnect records, including block zero and an unassigned startup monitor', () => {
    const blocks = model.readBlocks('0\tDP-1\tLG\n3\tDP-4\tDell\n1\t\tunplugged\nbad\tDP-5\tbad\n');
    assert.deepEqual(plain(blocks), {'DP-1':0,'DP-4':3});
    assert.equal(model.monitorBlock(blocks,'DP-1',32),0);
    assert.equal(model.monitorBlock(blocks,'DP-4',1),3);
    assert.equal(model.monitorBlock(blocks,'NEW',21),2);
    assert.equal(model.monitorBlock(blocks,'NEW',-1),0);
});
test('monitor names survive the shell boundary as one Lua expression', () => {
    const command = model.focusCommand(13,true,"DP'2",1);
    const output = execFileSync('bash',['-c','hyprctl() { printf "%s\\n" "$@"; }; ' + command],{encoding:'utf8'});
    assert.equal(output, 'dispatch\no.workspaces.focus(3, "DP\'2")\n');
});
