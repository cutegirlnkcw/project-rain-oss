import fs from 'node:fs';
import path from 'node:path';

const bundlePath = path.join('dist', 'project_rain_bundle.lua');
const bundle = fs.readFileSync(bundlePath, 'utf8');
const modulePattern = /module_map\["([^"]+)"\] = \[(=*)\[/g;
const seen = new Set();
const failures = [];
let checked = 0;
let match;

while ((match = modulePattern.exec(bundle)) !== null) {
  const [, key, equals] = match;
  const contentStart = modulePattern.lastIndex;
  const closingDelimiter = `]${equals}]`;
  const contentEnd = bundle.indexOf(closingDelimiter, contentStart);
  const sourcePath = path.join('src', `${key.slice('src/'.length)}.lua`);

  if (seen.has(key)) {
    failures.push(`${key}: duplicate module entry`);
    continue;
  }
  seen.add(key);

  if (!fs.existsSync(sourcePath)) {
    failures.push(`${key}: source file not found (${sourcePath})`);
    continue;
  }

  if (contentEnd < 0 || bundle[contentEnd + closingDelimiter.length] !== ';') {
    failures.push(`${key}: long-string delimiter is missing or overlaps its module source`);
    continue;
  }

  const original = fs.readFileSync(sourcePath, 'utf8');
  const embedded = bundle.slice(contentStart, contentEnd);
  const decoded = embedded.startsWith('\r\n')
    ? embedded.slice(2)
    : embedded.startsWith('\n')
      ? embedded.slice(1)
      : embedded;
  if (decoded !== original) {
    failures.push(`${key}: embedded source differs from ${sourcePath}`);
  }
  checked++;
}

if (!checked) {
  failures.push('no module entries found');
}

if (!seen.has('src/features/loader')) {
  failures.push('feature loader is missing from bundle');
}

if (!seen.has('src/features/auto-parry/auto-parry')) {
  failures.push('auto-parry feature modules are missing from bundle');
}

if (!seen.has('src/features/auto-parry/handlers/animator-handler')) {
  failures.push('animator handler dependency is missing from bundle');
}

if (![...seen].some((key) => key.startsWith('src/features/auto-parry/data/'))) {
  failures.push('auto-parry data dependencies are missing from bundle');
}

const finalModule = bundle.lastIndexOf('module_map[');
const bootstrap = bundle.indexOf('local bootstrap_ok');
if (bootstrap < 0 || bootstrap < finalModule) {
  failures.push('bootstrap does not appear after all module definitions');
}

console.log(`Module entries checked: ${checked}`);
console.log(`Integrity failures: ${failures.length}`);
for (const failure of failures) {
  console.error(failure);
}

if (failures.length) {
  process.exitCode = 1;
}