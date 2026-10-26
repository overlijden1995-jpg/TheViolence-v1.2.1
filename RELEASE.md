# The Violence — Release Packaging & Build Guide (`v0.70`)

```
release/TheViolence.exe         Windows x86_64   single-file GUI executable (embedded .pck)
release/TheViolence.x86_64      Linux x86_64     single-file ELF executable (embedded .pck)
release/SHA256SUMS.txt          SHA-256 digests  generated and verified by tools/build_release.sh
```

Both release artefacts are self-contained single-file builds (`binary_format/embed_pck=true`
in `export_presets.cfg`): campaign/story, Test Range, and Endless Battle (`Port Carrick`)
are included inside the executable with no sidecar `.pck`, no installer, and no
external Godot runtime required.

- **Windows (`release/TheViolence.exe`):** x86-64, Windows GUI subsystem, runs on
  Windows 10 and 11 (64-bit) with an OpenGL 3.3 driver (`gl_compatibility`).
  Imports only stock Windows system DLLs (verified by `tools/inspect_exe.py`).
  Branded with `icon.ico`, product name `The Violence`, and 4-part PE version
  `0.70.0.0` via `tools/patch_rc.py`.
- **Linux (`release/TheViolence.x86_64`):** x86-64 ELF binary (`gl_compatibility`).
- **Storefront manifest:** `.itch.toml` at the repository root configures both
  launch targets for itch.io (`butler`).
- **Signing & SmartScreen:** See `docs/SIGNING.md` for Windows Authenticode
  signing (`signtool.exe` / `osslsigncode` / Azure Trusted Signing), SmartScreen
  reputation seeding, and Steam / itch.io depot upload commands.

---

## What Is Packed (`export_presets.cfg`)

`tools/inspect_pck.py <binary> --verify` reads the embedded `GDPC` pack without
Godot and checks every packed file against its stored MD5:

- **124 SVG textures (`*.ctex`)** — verified against `assets/svg/manifest.json` (`python3 tools/make_placeholders.py --verify`)
- **34 synthesised WAV sounds (`*.sample`)** — verified against `assets/sfx/manifest.json` (`python3 tools/make_sounds.py --verify`)
- **8 Ogg Theora cutscenes (`*.ogv`)** — the 4 opening films (`c1..c4`) and the 4 wired campaign shorts (`s06`, `s09`, `s11`, `s12`) encoded at Theora quality 4
- **81 compiled runtime scripts (`*.gdc`)** — all under `scripts/`
- **Excluded from release packs:** `tests/*`, `tools/*`, `build/*`, `cinematics/*`, `docs/*`, `*.md`, `*.py`, `*.sh`, `*.bat`, `.itch.toml`, `assets/*/manifest.json`, and the 10 unwired short cutscenes (`s01–s05`, `s07–s08`, `s10`, `s13–s14`).

---

## Building & Verifying Release Binaries

Because restricted build hosts cannot download pre-built Godot templates from
`github.com/.../releases/download/`, `tools/build_release.sh` compiles the
headless Linux editor and the Windows/Linux release templates directly from the
Godot source tarball (`codeload.github.com`):

```sh
# Build both Windows (release/TheViolence.exe) and Linux (release/TheViolence.x86_64)
# plus release/SHA256SUMS.txt (defaults to GODOT_TAG=4.7.2-stable)
JOBS=8 tools/build_release.sh

# Build Windows only (or run tools/build_windows_exe.sh)
JOBS=8 tools/build_release.sh --target=windows

# Build Linux only
JOBS=8 tools/build_release.sh --target=linux

# Verify or regenerate release/SHA256SUMS.txt
tools/build_release.sh --verify-sums
tools/build_release.sh --write-sums
```

Before compiling, `tools/build_release.sh` automatically runs:

1. `python3 tools/sync_version.py --check` (verifies `0.70` / `0.70.0.0` sync across `scripts/version.gd`, `project.godot`, `export_presets.cfg`, and `tools/patch_rc.py`)
2. `python3 tools/make_placeholders.py --verify` (verifies all 123 SVGs + `icon.svg` + `assets/svg/manifest.json`)
3. `python3 tools/make_sounds.py --verify` (verifies all 34 WAVs + `assets/sfx/manifest.json`)
4. `python3 tools/gd47_check.py` (static GDScript 4.7 audit across all 118 scripts)

---

## Distribution Policy (`2.07`)

`release/*` (except `release/README.md`) is git-ignored so large compiled
executables stay out of Git history. Distribute `release/TheViolence.exe`,
`release/TheViolence.x86_64`, and `release/SHA256SUMS.txt` as GitHub Release
assets and via itch.io (`butler`) / Steam (`SteamPipe`) as documented in
`docs/SIGNING.md`.
