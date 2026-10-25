# The Violence — compact Windows prototype

```
release/TheViolence.exe      92,308,944 bytes      88.0 MiB      one file
```

This is a self-contained Windows build of the full prototype: campaign/story,
Test Range, and Endless Battle are included. The engine and embedded game pack
are in the executable; there is no sidecar `.pck`, installer, Godot install, or
DLL bundle. It is **7,691,056 bytes below GitHub's 100,000,000-byte per-file
limit**.

- **Machine:** x86-64, Windows GUI subsystem
- **Runs on:** Windows 10 and 11 (64-bit). The renderer is `gl_compatibility`,
  so the machine needs an OpenGL 3.3 driver — Intel HD 4000 and newer, any
  AMD/NVIDIA card from the last decade.
- **Imports:** 33 libraries, every one a stock Windows DLL. `tools/inspect_exe.py`
  prints the list.
- **Unsigned and not yet exercised on Windows hardware.** SmartScreen may warn
  on first run; the Linux build host cannot verify Windows startup behavior.

## What is in it

`tools/inspect_pck.py release/TheViolence.exe --verify` reads the embedded pack
without Godot and checks every file against its stored MD5:

| | |
| --- | --- |
| files | 498 |
| payload | 23.9 MiB |
| verified | all files match |
| textures (`*.ctex`) | 124 |
| sounds (`*.sample`) | 34 |
| cutscenes (`*.ogv`) | 8 |
| compiled scripts (`*.gdc`) | 81 |

The pack is embedded in the PE's `pck` section. The four opening films and the
four shorts currently wired into campaign play (`s06`, `s09`, `s11`, `s12`) are
included. The other ten shorts remain in the source tree but are excluded from
both release presets: they do not currently have gameplay triggers. Gameplay,
all three modes, and campaign outcomes are unchanged.

The eight included Ogg Theora videos were re-encoded at quality 4 while keeping
their 1280×720 frame size, frame rate, duration, and Vorbis audio. The cinematic
source scripts now use the same quality setting for future renders. The ten
excluded shorts were left untouched in the source.

`tests/`, `tools/`, markdown sources, and the Remotion sources under
`cinematics/` are not in the pack.

## Build and repeat

The build host cannot use the official GitHub-hosted Godot release templates,
so `tools/build_windows_exe.sh` builds the Godot editor and Windows template
from Godot 4.4.1 source. The template is branded with the game's icon/version,
then exported with `binary_format/embed_pck=true`.

```sh
JOBS=2 tools/build_windows_exe.sh
```

The script pins SCons 4.8.1 and Zig 0.13.0, verifies the embedded pack, and
fails if the finished executable is 100,000,000 bytes or larger. Requires
Python 3, `curl`, `tar`, and a C/C++ toolchain for the Linux editor; build
artifacts and downloaded toolchains stay in ignored `.build/`.

The checked-in Oggs are already the compact release encodes. To regenerate
cinematics from the Remotion MP4 masters, use `cinematics/scripts/to_game.sh`
and `cinematics/scripts/to_game-shorts.sh`; both now default to Theora quality
4.

## Verification performed

- `tools/inspect_exe.py release/TheViolence.exe` — x86-64 GUI PE, embedded pack,
  icon/version resources, and only stock Windows imports.
- `tools/inspect_pck.py release/TheViolence.exe --verify` — 498 files, every
  MD5 matches; all ten unwired shorts are absent and all eight retained videos
  are present.
- Extracted the embedded pack and ran it with the Godot 4.4.1 Linux editor
  (`--headless --main-pack ... --quit-after 600`) with no script errors.
- Headless project boot — 600 frames, no script errors.
- `tools/run_tests.sh --quick` on Godot 4.4.1 — **11/11 suites passed**.

An actual run on Windows hardware is still needed before calling this a tested
Windows release. This is a playable prototype build, not a signed release.

## Where the file lives

`release/TheViolence.exe` is generated locally and remains git-ignored to keep
binary builds out of source history. It is below GitHub's ordinary 100 MB file
limit, but a GitHub Release asset is still the cleaner distribution channel.
Rebuild it with `tools/build_windows_exe.sh`.

## Checksum

```
92,308,944 bytes
SHA-256  2001da5e0bc20f18c99ad63bfb28f9b4f6bd90ca105b963657e2b16f58c51bb2
```
