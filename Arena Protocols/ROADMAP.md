# The Violence — Roadmap to Release

**Version:** 0.50 (vertical slice prototype)
**Target:** 1.0 (shippable release)
**Date:** 2026-10-25
**Status:** Active planning document — update as milestones close

---

## Why 0.50

The current build is labeled v1.2.1, but that labeling is misleading. By any honest assessment:

- The Windows binary is **unsigned and never tested on real hardware**
- 18 of 34 test harnesses **cannot fail a build** even when they detect regressions
- The balance matrix has **11 empty cells** (measured bands never filled in)
- There is **no music**, minimal accessibility, no localization infrastructure
- There is **no license file**, no third-party notices
- 10 of 14 rendered short cutscenes **have no gameplay trigger** wired
- CI is **not activated** (workflow file sits one directory away from where it belongs)
- The repo root contains **21 unrelated noir-prose files** from a writing project

This is a strong vertical slice — 34,000+ lines of deterministic simulation, 12 maps, a 40-week campaign, animated figures, and an evidence chain from muzzle flash to election. But it is not a 1.0 product. Calling it 0.50 honestly frames what exists and what remains.

---

## What 1.0 Means

Version 1.0 is a build that:
1. **Runs on real Windows hardware** without SmartScreen terror or crashes
2. **Passes all test tiers** including the soak/balance matrix
3. **Has a score** (at minimum a title theme and ambient bed per game mode)
4. **Ships through a defined channel** (itch.io, Steam, or GitHub Release) with a license
5. **Has a clean repo** — no stray files, one README, prose corpus moved out
6. **Can accept a bug report** from a non-developer (a path from crash to fix)

---

## Milestones

### M1 — Foundation (0.50 → 0.60): "Make the branch true"

*Goal: Everything claimed in the code is verified. The test infrastructure is trustworthy.*

| # | Task | Class | Acceptance |
|---|---|---|---|
| 1.1 | Run the soak tier and fill the balance matrix | QA/SYS | `tools/run_tests.sh --soak` passes; all 11 cells in `tests/balance_matrix_test.gd` have measured actuals within declared bands; results recorded in CHANGELOG.md |
| 1.2 | Give all 18 silent harnesses a proper exit code | TOOL | Every file in `tests/` exits non-zero on failure; remove log-scanning fallback from `tools/run_tests.sh` |
| 1.3 | Activate CI | TOOL | Move `tools/ci/ci.yml` → `.github/workflows/ci.yml`; green on both 4.4.1 and 4.7.2; required on `main` |
| 1.4 | Add determinism cases for Q1/Q6 behavior | SYS | Add fixture cases that exercise the rally reset (12 s quiet → 0.25/s decay) and the less-lethal-first order; `determinism_test` covers the new paths |
| 1.5 | Run `op_test --chief=manual` and record the briefing-value gap | QA | The matched-seeds comparison between `--chief=sensible` and `--chief=manual` is run; the gap is the measured value of reading the briefing; results in CHANGELOG |
| 1.6 | Verify the Windows build on real hardware | QA | Boot, play one week, save, reload, alt-tab, resize, quit — on an actual Windows 10/11 machine; results recorded |
| 1.7 | Confirm the Remotion license position | STRUCT | Document whether the rendered .ogv cutscenes are covered by the Remotion license terms; resolve if not |

**Exit criteria:** `tools/run_tests.sh --soak` green on a multi-core machine. Balance table complete. CI green on both engines. One real Windows playtest logged.

---

### M2 — Production Readiness (0.60 → 0.70): "Make it shippable"

*Goal: The game can be distributed, launched, and played by someone who is not the developer.*

| # | Task | Class | Acceptance |
|---|---|---|---|
| 2.1 | Add LICENSE file | STRUCT | Choose and commit a license (all-rights-reserved, MIT, or source-available); add THIRD_PARTY_NOTICES if needed |
| 2.2 | Clean the repo root | STRUCT | Move 21 noir-prose .md files, `series.json`, `style_lint.py`, `test_style_lint.py`, `README (1).md`, `README (2).md`, `chandler-scene.md`, `leonard-scene.md` to a separate directory or repo; delete `download`; one README remains |
| 2.3 | Code-sign or choose a distribution channel | TOOL | OV/EV certificate, or commit to itch.io/Steam which carries the SmartScreen context; document the choice |
| 2.4 | Rebuild Windows exe from current source | TOOL | `tools/build_windows_exe.sh` produces a verified build; `tools/inspect_pck.py --verify` clean; `tools/inspect_exe.py` clean |
| 2.5 | Add a window-size option alongside fullscreen | UIUX | Settings offers at least one windowed resolution; test at 1366×768 |
| 2.6 | Add a crash-log path | SYS | `user://logs/` is written on error; credits page tells the player where to find it |
| 2.7 | Decide and execute the cutscene question | SYS | Either wire the remaining 10 shorts to gameplay triggers (with `play_short()` calls in the appropriate campaign beats), or formally exclude them from the export preset and document why |

**Exit criteria:** A signed (or channel-distributed) Windows build from current source, installed and played on real hardware. Clean repo root. Crash logging in place.

---

### M3 — Player Experience (0.70 → 0.80): "Make it feel finished"

*Goal: A new player's first hour is polished, the game sounds finished, and accessibility basics are met.*

| # | Task | Class | Acceptance |
|---|---|---|---|
| 3.1 | Compose/produce a score | ASSETS | At minimum: one title theme, one board/campaign ambient bed, one operation ambient bed, one election-night stinger. Named buses, mixed through the audio manager. |
| 3.2 | Font scaling in Settings | UIUX | A 100%/125%/150% UI scale option; tested at each step on the manual, the debrief, and the board |
| 3.3 | Key rebinding | UIUX | At minimum: the six most-used actions rebindable; stored in settings.cfg |
| 3.4 | Reduced-motion option | UIUX | A toggle that disables camera shake, figure animation easing, and cutscene motion (stills instead) |
| 3.5 | Onboarding audit | QA | Fresh-eyes playtest by 3+ people who have never seen the game; observations cataloged; top 5 confusion points addressed |
| 3.6 | Q4 claim verification | QA | `op_test --chief=manual` vs `--chief=sensible` on matched seeds demonstrates the briefing's value; the result is surfaced to the player (e.g., a debrief line showing what the plan assumed vs. what was true) |
| 3.7 | Rally reset and statement-integrity visibility | SYS/UIUX | The invisible Q1/Q6/Q3 mechanics get at least one debrief line each so the player can perceive they exist |

**Exit criteria:** Three fresh-eyes playtests logged with observations addressed. Score present. Settings include font scale, rebinding, and reduced motion.

---

### M4 — Depth (0.80 → 0.90): "Make it last"

*Goal: The game's content depth matches its systems depth. Strings are localizable. Performance is budgeted.*

| # | Task | Class | Acceptance |
|---|---|---|---|
| 4.1 | Localization infrastructure | SYS/TOOL | All player-facing strings extracted to a translation source; `tr()` with namespaced keys; at least one non-English language proofed end-to-end |
| 4.2 | Performance budget asserted | PERF | `tests/perf.gd` asserts frame time ≤16.6ms, draw calls ≤project-budget, node count ≤project-budget on the largest map (m11_plaza, 20v20); numbers recorded in state |
| 4.3 | Memory soak | PERF | 30-minute continuous play with no steady memory growth; `Performance.MEMORY_STATIC` logged |
| 4.4 | Extended campaign testing | QA | 5 full 40-week campaigns at different seeds with `--chief=sensible`; outcomes cataloged; no degenerate paths (every ending reachable) |
| 4.5 | Endless Battle parity | SYS | The endless mode's city director, QRF, and ambulance systems pass their own soak test (30 min, no error log entries) |
| 4.6 | Store assets | ASSETS | Screenshots, trailer (from `tools/make_ads.py`), description, system requirements — ready for the chosen platform |

**Exit criteria:** Strings localizable. Performance and memory budgets met and asserted. Five full campaigns logged with all three endings reachable.

---

### M5 — Release (0.90 → 1.00): "Ship it"

*Goal: The release checklist is complete. The game is in players' hands.*

| # | Task | Class | Acceptance |
|---|---|---|---|
| 5.1 | Release notes from CHANGELOG | DOCS | Player-facing release notes covering what's in the vertical slice; known limitations honestly stated |
| 5.2 | Platform submission / publication | STRUCT | itch.io page live, or Steam review submitted, or GitHub Release with signed exe attached |
| 5.3 | Post-release bug path | DOCS | A non-developer can report a bug (email, form, or issue template) and the path from report to fix is documented |
| 5.4 | Save migration path | SYS/MIGR | If 1.0 changes the save format, v0.50 saves load with a migration; tested explicitly |
| 5.5 | Version bump | TOOL | `scripts/version.gd` → "1.0.0"; `tools/sync_version.py`; all three files committed together |
| 5.6 | Tag the release | TOOL | `git tag v1.0.0` on the release commit |

**Exit criteria:** The game is publicly available through at least one channel. Bug reporting path exists. Version reads 1.0.0.

---

## Backlog (unrouted — not commitments)

- **Multiplayer observation mode** — a second player watches the operation as the "press"
- **Procedural map generation** — the 12 hand-built maps are strong; procedural variants for replayability
- **Modding support** — expose the equipment database and habit definitions for community mods
- **Controller-first UI redesign** — the current UI is mouse-primary; a console-style nav pass
- **Additional languages** — after the localization infrastructure exists (M4.1)
- **Expanded campaign** — more than 40 weeks, additional candidates, branching endings

## Explicitly out of scope

- **Real-time direct control of officers** — the game is a command sim, not a shooter. The player plans and watches.
- **Multiplayer competitive** — the design is single-player narrative campaign + sandbox.
- **Mobile port** — gl_compatibility renderer and 1600×900 baseline make this a desktop game.
- **VR** — the top-down paper aesthetic is fundamentally flat.

---

## Version history

| Date | Change |
|---|---|
| 2026-10-25 | Initial roadmap. Version relabeled from 1.2.1 to 0.50. Five milestones defined (Foundation → Production → Experience → Depth → Release). Based on RELEASE_READINESS.md analysis. |
