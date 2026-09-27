# Project Rain OSS Recreation

This repository contains a partial Project Rain source handoff, locally reconstructed compatibility shims, a single-file bundler, and a minimal universal fallback UI. It is not an official complete release, and a successful bundle build does not prove the Deepwoken runtime works.
I fixed most of the missing shit and remade a bundler if you have any questions dm 5928349213 on discord feel free to use this for anything it's not my script afterall

## Contents

- `src/init.lua` is the runtime entry point. It initializes compatibility helpers and shared globals, then routes supported place IDs into the Deepwoken path or other places into the fallback UI.
- `src/universal_fallback.lua` creates a window with the project's own UI library. It has a Settings tab and a Universal tab with two inert placeholder toggles. It does not load Deepwoken gameplay modules.
- `src/features/` contains feature code and the locally restored feature registry/base class.
- `src/utility/` contains shared runtime, UI, and game utilities.
- `src/ui/` contains the main game's UI setup and tabs.
- `assets/` contains data and project assets.
- `bundle_project_rain.mjs` builds the single-file bundle.
- `dist/project_rain_bundle.lua` is the generated bundle.
- `test_bundle_integrity.mjs` checks embedded source text, long-string delimiters, duplicate module entries, and bootstrap ordering.

## Build

Requirements: Node.js with ES module support. The bundler uses only Node's built-in modules; there is no npm install step.

From the repository root, run:

```powershell
node bundle_project_rain.mjs
node test_bundle_integrity.mjs
```

The first command writes `dist/project_rain_bundle.lua`. The second compares each bundled module with its source file and checks the generated delimiter boundaries. It is a packaging integrity test, not a Luau syntax check or Roblox runtime test.

The bundler deliberately excludes `src/features/auto-parry/**` and `src/features/loader.lua`. These exclusions mean the generated bundle should not be treated as a complete Deepwoken build without further review. The output logs module load successes and failures during startup.

## Runtime Routing

`src/init.lua` contains the supported-place allowlist. For a place outside that list, startup initializes the bundled universal fallback and returns before the Deepwoken-specific runtime. The fallback uses the bundled Project Rain UI library, offers the library's keybind and UI-scale controls, and attempts to include its existing config and theme controls. Those managers depend on executor filesystem APIs; they report a warning if setup fails. The two Universal-tab toggles are placeholders and intentionally have no game effect.

A supported place proceeds into the Deepwoken runtime, which depends on Roblox game internals and executor-provided APIs. A normal Roblox client is not sufficient. Only use this code in an environment and context where you are authorized to run it, and follow the game's and platform's rules.

## Current Limitations

- This was an intentionally incomplete source release. Some source files and original startup behavior were omitted.
- `src/luarmor_init_script.lua`, `src/features/loader.lua`, `src/features/generic_feature.lua`, and several compatibility files in this checkout are local reconstructions or compatibility implementations, not verified original source.
- The bundler's successful exit and the integrity test confirm packaging consistency only. This repository does not currently include an automated Luau parser or a Roblox runtime test harness.
- The universal fallback does not provide universal gameplay features. It is a small UI-only path for non-allowlisted places.
- The committed `dist/project_rain_bundle.lua` is generated output. Edit source and rerun the bundler rather than editing the generated bundle by hand.

## Repository Layout

```text
assets/       Project data and assets
src/          Luau source
  automation/ Automation modules
  features/   Feature implementations and registry
  ui/         Main UI setup and tabs
  utility/    Shared utilities and bundled UI library
dist/         Generated single-file bundle
```

`.luaurc` defines the Luau aliases used by editor tooling.

## Acknowledgments

Thanks to uni for making such an awesome script and community <3 
Extra thanks to the people uni acknowledged in the discord annc
credits to TempedOut, Soggy, Hon, Mint, Juan, Joseph, Q/2qrys & me if you release a fork that is paid or rebrand the script (or use significant parts of the script).

    Huge thanks to:
        Blastbrean (for the Lycoris-Rewrite aspects reused & introducing me to the concept of bundling & early inspirations & PascalCase helping me figure out some aspects of AP + more), & the rest of the team.
        Basil (co-owner, ex-staff manager & manager who oversees for the product & big motivator).
        Hon (did all the timings before rewrite & alot of timings for rewrite & helps with resellers).
        TempedOut, Soggy, Hon, Mint, Juan, Joseph, Q/2qrys for various work on the dev team.
        Early on testers, (& kendu), + the staff team
        V15/'VermillionIts15' (only reason the product is public, made 'Vermillion Hub', which got passed to citam & advertised + helped in very early stages of V1 & 'mist hub')
        Ken/Winter (worked with me on 'Wave Hub', which was a rewrite of PR for the executor under the same names hub circa 2025)
        ILikeBananas69 (Early on inspiration to start development, helped with styling some early code & a old bedwars script)
        2qrys (early on help, now works on rogueblox, <3 even if you hate me now & we had our past mistakes)
        Wowzers (contributed heavily to the script & was a great friend)
        Citam (helped heavily back in the day)
        yv5 (slight help in certain aspects)


