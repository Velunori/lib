import fs from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
import assert from 'node:assert/strict';

const context = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('../BarModel.js', import.meta.url),'utf8'),context);
const plain = value => JSON.parse(JSON.stringify(value));
const normalizeEntry = entries => entries.filter(x=>typeof x === 'string'||x?.id).map(x=> typeof x === 'string' ? {id:x} : structuredClone(x));

// Exercise the actual configuration writer rather than a second copy of it.
const source = fs.readFileSync(new URL('../Bar.qml',import.meta.url),'utf8');
function extract(name) {
    let begin=source.indexOf('function '+name+'('), brace=source.indexOf('{',begin), depth=1, end=brace+1;
    for(;depth && end<source.length;end++) { if(source[end]==='{')depth++; if(source[end]==='}')depth--; }
    return source.slice(begin,end);
}
context.Util = {isPlainObject:context.isPlainObject};
context.root = {entryId:context.entryId};
for (const name of ['rawLayoutSection','rawEntryIndex','moveModuleInConfig']) vm.runInContext(extract(name),context);

test('all six host regions survive normalization with detached inline settings',()=>{
    const layout = Object.fromEntries(context.sections.map(region=>[region,[{id:region==='tray'?'custom.hidden':region,setting:{value:3}}]]));
    const result=context.normalizeSections(layout,normalizeEntry);
    assert.deepEqual(Object.keys(result),plain(context.sections));
    result.centerEnd[0].setting.value=9;
    assert.equal(layout.centerEnd[0].setting.value,3);
    assert.equal(result.tray[0].id,'custom.hidden');
});
test('control-center filtering covers the new regions without mutating saved placement',()=>{
    const layout={centerBegin:['omarchy.audio'],centerEnd:['velunori.control-center','omarchy.weather'],tray:['omarchy.tray','custom.hidden'],left:42};
    const result=plain(context.normalizeSections(layout,normalizeEntry));
    assert.deepEqual(result.centerBegin,[]);
    assert.deepEqual(result.centerEnd,[{id:'velunori.control-center'},{id:'omarchy.weather'}]);
    assert.deepEqual(result.tray,[{id:'custom.hidden'}]);
    assert.deepEqual(layout.centerBegin,['omarchy.audio']);
});
test('inline settings detect new-region changes and structural moves',()=>{
    const current=context.normalizeSections({centerEnd:[{id:'weather',unit:'metric'}],tray:[{id:'hidden',value:1}]},normalizeEntry);
    const next=plain(current);next.centerEnd[0].unit='imperial';next.tray[0].value=2;
    assert.deepEqual(plain(context.inlineSettingsDelta(current,next)).map(x=>x.region),['centerEnd','tray']);
    next.centerBegin=next.centerEnd;next.centerEnd=[];
    assert.equal(context.inlineSettingsDelta(current,next),null);
});
test('real drag/drop writer preserves inline settings and unrelated regions, including an empty destination',()=>{
    const config={bar:{layout:{left:[{id:'menu'}],center:[{id:'clock'}],centerEnd:[{id:'weather',unit:'metric'}],tray:[]}}};
    assert.equal(context.moveModuleInConfig(config,'centerEnd','weather','tray',''),true);
    assert.deepEqual(config.bar.layout.tray,[{id:'weather',unit:'metric'}]);
    assert.deepEqual(config.bar.layout.center,[{id:'clock'}]);
    assert.equal(context.moveModuleInConfig(config,'tray','weather','centerBegin',''),true);
    assert.equal(config.bar.layout.centerBegin[0].unit,'metric');
    config.bar.layout.left.push({id:'omarchy.tray'});
    assert.equal(context.moveModuleInConfig(config,'left','omarchy.tray','tray',''),false);
    assert.equal(config.bar.layout.left.length,2);
});
