import fs from 'node:fs';
import path from 'node:path';

const bundlePath = process.argv[2]
  ? path.resolve(process.argv[2])
  : path.join('dist', 'project_rain_bundle.lua');
const bundle = fs.readFileSync(bundlePath, 'utf8');
const isUniversalBundle = path.basename(bundlePath) === 'project_rain_universal.lua';
const modulePattern = /^-- BEGIN MODULE: (src\/[^\r\n]+)\r?\nmodule_map\["([^\"]+)"\] = function\(require\)\r?\n/gm;
const seen = new Set();
const failures = [];
let checked = 0;
let match;

while ((match = modulePattern.exec(bundle)) !== null) {
  const [, markerKey, key] = match;
  if (markerKey !== key) {
    failures.push(`${key}: module marker does not match map key`);
    continue;
  }

  const contentStart = modulePattern.lastIndex;
  const moduleEndMarker = `\nend\n-- END MODULE: ${key}`;
  const contentEnd = bundle.indexOf(moduleEndMarker, contentStart);
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

  if (contentEnd < 0) {
    failures.push(`${key}: function module terminator is missing`);
    continue;
  }

  const original = fs.readFileSync(sourcePath, 'utf8');
  const embeddedSource = bundle.slice(contentStart, contentEnd);
  if (embeddedSource !== original) {
    failures.push(`${key}: embedded source differs from ${sourcePath}`);
  }
  checked++;
}

if (!checked) {
  failures.push('no module entries found');
}

const manifestPath = bundlePath.replace(/\.lua$/, '.modules.txt');
if (fs.existsSync(manifestPath)) {
  const manifestEntries = fs.readFileSync(manifestPath, 'utf8')
    .split(/\r?\n/)
    .filter(Boolean);
  const bundledEntries = [...seen].sort();
  if (JSON.stringify(manifestEntries) !== JSON.stringify(bundledEntries)) {
    failures.push('module manifest does not match the bundle');
  }
}

for (const required of [
  'src/init',
  'src/luarmor_init_script',
  'src/globals',
  'src/universal_fallback',
  'src/utility/librarys/ui',
  'src/utility/librarys/managers/SaveManager',
  'src/utility/librarys/managers/ThemeManager',
  'src/features/loader',
  'src/features/auto-parry/auto-parry',
  'src/features/auto-parry/handlers/animator-handler',
]) {
  if (!seen.has(required)) failures.push(`${required}: required runtime module is missing`);
}

if (![...seen].some((key) => key.startsWith('src/features/auto-parry/data/'))) {
  failures.push('auto-parry timing/data dependencies are missing from bundle');
}

const firstModule = bundle.indexOf('-- BEGIN MODULE: ');
if (firstModule < 0) failures.push('no function-based module declarations found');
const loaderSource = bundle.slice(0, firstModule);
if (loaderSource.includes('loadstring') || loaderSource.match(/\blocal chunk\s*=\s*load/)) {
  failures.push('module loader compiles module source dynamically');
}

const finalModule = bundle.lastIndexOf('-- END MODULE: ');
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