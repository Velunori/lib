import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const brand = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(root, 'kit/Brand.js'), 'utf8'), brand);
const out = path.join(root, 'assets/brand');
fs.mkdirSync(out, {recursive: true});
const variants = {lavender:'#c4aff1', mint:'#a0ddbf', pearl:'#e8dfd1', white:'#eeedf3', graphite:'#202026'};
for (const [name, color] of Object.entries(variants)) {
    const svg = brand.markSvg(color);
    fs.writeFileSync(path.join(out, `velunori-mark-${name}.svg`), svg + '\n');
}
const symbol = brand.markSvg(variants.lavender).replace(/^.*?<svg[^>]*>/, '').replace('</svg>', '');
const wordmark = '<svg xmlns="http://www.w3.org/2000/svg" width="304" height="48" viewBox="0 0 304 48">'
    + '<g transform="translate(0 0) scale(2)">' + symbol + '</g>'
    + '<text x="68" y="35" fill="#eeedf3" font-family="Nimbus Roman, Liberation Serif, serif" font-size="36" font-weight="400">Velunori</text></svg>\n';
fs.writeFileSync(path.join(out, 'velunori-wordmark.svg'), wordmark);
