# The Violence — Roadmap to Release

**Version:** 0.50 (vertical slice prototype)
**Target:** 1.0 (shippable release)
**Date:** 2026-10-25
**Status:** Active planning document — update as milestones close
**Router mapping:** See `ARENA_MODEL_ROUTER.md` §0.5 for stage-to-milestone mapping

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

## M1 — Foundation (0.50 → 0.60): "Make the branch true"

*Goal: Everything claimed in the code is verified. The test infrastructure is trustworthy.*

**Router stage: 10–11 (0.50–0.55) · Primary classes: TOOL → SYS → QA → DEBUG**

### Test Infrastructure

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 1.01 | Give `tests/_check.gd` a proper exit code | TOOL | `tests/_check.gd` | Exits 1 when any script fails to load; currently prints FAILED and exits 0 |
| 1.02 | Give `tests/civ_test.gd` a proper exit code | TOOL | `tests/civ_test.gd` | Exits 1 when gate fails (currently always 0); pool comparison logic preserved |
| 1.03 | Give `tests/equip_test.gd` a proper exit code | TOOL | `tests/equip_test.gd` | Exits 1 when any of 19 paired-run gates fail |
| 1.04 | Give `tests/hold_test.gd` a proper exit code | TOOL | `tests/hold_test.gd` | Exits 1 when hold-mode win rates break bands |
| 1.05 | Give `tests/lethality_test.gd` a proper exit code | TOOL | `tests/lethality_test.gd` | Exits 1 when officer casualty rates exceed thresholds |
| 1.06 | Give `tests/maps_test.gd` a proper exit code | TOOL | `tests/maps_test.gd` | Exits 1 when any of 12 maps fails geometry validation |
| 1.07 | Give `tests/nav_door_test.gd` a proper exit code | TOOL | `tests/nav_door_test.gd` | Exits 1 when any of 175 door crossings clip or false-stop |
| 1.08 | Give `tests/op_test.gd` a proper exit code | TOOL | `tests/op_test.gd` | Exits 1 when campaign outcomes degenerate |
| 1.09 | Give `tests/city_test.gd` a proper exit code | TOOL | `tests/city_test.gd` | Exits 1 when room paths or cross-city paths fail |
| 1.10 | Give `tests/city_sim.gd` a proper exit code | TOOL | `tests/city_sim.gd` | Exits 1 when soak detects errors; accepts `--quiet` for CI |
| 1.11 | Give `tests/fuzz_test.gd` a proper exit code | TOOL | `tests/fuzz_test.gd` | Exits 1 on crash or assertion failure during fuzzing |
| 1.12 | Give `tests/perf.gd` a proper exit code + assert | TOOL | `tests/perf.gd` | Exits 1 when frame time > 16.6ms on largest map; currently prints only |
| 1.13 | Give `tests/playtest.gd` a proper exit code | TOOL | `tests/playtest.gd` | Exits 1 on detected issues |
| 1.14 | Give `tests/sim_test.gd` a proper exit code | TOOL | `tests/sim_test.gd` | Exits 1 when simulation invariants fail |
| 1.15 | Give `tests/stall_test.gd` a proper exit code | TOOL | `tests/stall_test.gd` | Exits 1 when operations stall (time limit without resolution) |
| 1.16 | Give `tests/trace.gd` a proper exit code | TOOL | `tests/trace.gd` | Exits 1 when traced paths deviate |
| 1.17 | Give `tests/duel_probe.gd` a proper exit code | TOOL | `tests/duel_probe.gd` | Exits 1 when duel outcomes break balance bands |
| 1.18 | Give `tests/rig_gallery.gd` a proper exit code | TOOL | `tests/rig_gallery.gd` | Exits 1 when figure rig produces invalid poses |
| 1.19 | Remove log-scanning fallback from `tools/run_tests.sh` | TOOL | `tools/run_tests.sh` | After 1.01–1.18, all harnesses exit properly; the log-scan safety net can be removed; `--quick` and `--full` rely on exit codes only |

### Balance Verification

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 1.20 | Run `balance_test --gate` and record actuals | SYS/QA | `tests/balance_test.gd` | Equal regulars 5v5 on 4 maps: attacker wins 30–50%. Record in CHANGELOG |
| 1.21 | Run `balance_matrix_test` and fill all 11 cells | SYS/QA | `tests/balance_matrix_test.gd` | All 11 cells have measured actuals within declared bands; CSV recorded |
| 1.22 | Run `scale_playtest --gate` to validate matrix CSV | SYS/QA | `tests/scale_playtest.gd` | Pooled non-degeneracy asserts pass for the filled matrix |
| 1.23 | Run `equip_test` (all 19 gates) on engine | SYS/QA | `tests/equip_test.gd` | All 19 paired-run equipment gates pass with recorded values matching CHANGELOG table |
| 1.24 | Run `op_test --chief=manual` and record briefing-value gap | QA | `tests/op_test.gd` | Matched-seeds comparison between `--chief=sensible` and `--chief=manual` run; gap recorded in CHANGELOG |
| 1.25 | Run `stall_test` and confirm no degenerate timeouts | SYS/QA | `tests/stall_test.gd` | No operation hits the 900s time limit unexpectedly |
| 1.26 | Run `fuzz_test` for 1000 iterations | SYS/QA | `tests/fuzz_test.gd` | Zero crashes or assertion failures |
| 1.27 | Run `city_sim --min=10` and confirm clean | SYS/QA | `tests/city_sim.gd` | 10+ minute city simulation with zero error log entries |

### Determinism Coverage

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 1.28 | Add determinism fixture case for rally reset (Q1) | SYS | `scripts/sim/world.gd`, `tests/fixtures/determinism.json` | New case exercises 12s-quiet-then-decay path; fixture updated with `--write`; documented in CHANGELOG |
| 1.29 | Add determinism fixture case for less-lethal-first order (Q6) | SYS | `scripts/sim/world.gd`, `tests/fixtures/determinism.json` | New case exercises pre-attack police rounds at compliant armed suspect; fixture updated; documented |
| 1.30 | Add determinism fixture case for statement integrity (Q3) | SYS | `scripts/campaign/department.gd`, `tests/fixtures/determinism.json` | New case exercises officer statement vs bodycam disagreement path; fixture updated; documented |
| 1.31 | Verify `determinism_test --verbose` passes all cases (existing + new) | SYS | `tests/determinism_test.gd` | 35+ cases, 0 unexpected changes |

### CI & Infrastructure

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 1.32 | Activate CI workflow | TOOL | `tools/ci/ci.yml` → `.github/workflows/ci.yml` | `git mv`; workflow triggers on PR; green on both 4.4.1 and 4.7.2 |
| 1.33 | Make `--quick` tier required on `main` | TOOL | `.github/workflows/ci.yml` | Branch protection rule requires the quick-tier job |
| 1.34 | Run `tests/perf.gd` on largest map and record baseline | PERF | `tests/perf.gd`, `scripts/maps/m11_plaza.gd` | Frame time, draw calls, node count recorded in `ARENA_STATE.md` for future regression comparison |
| 1.35 | Verify Windows build on real hardware | QA | `RELEASE.md`, `tools/build_windows_exe.sh` | Build `release/TheViolence.exe` (git-ignored), then boot, play one week, save, reload, alt-tab, resize, quit — on actual Windows 10/11; results recorded |
| 1.36 | Confirm Remotion license position | STRUCT | `cinematics/package.json` | Document whether rendered .ogv cutscenes are covered; resolve if commercial use requires paid license |

**Exit criteria:** `tools/run_tests.sh --soak` green on a multi-core machine. Balance table complete (11 cells filled). CI green on both engines. One real Windows playtest logged. All 18 harnesses have exit codes. Determinism fixture covers Q1/Q3/Q6 paths.

---

## M2 — Production Readiness (0.60 → 0.70): "Make it shippable"

*Goal: The game can be distributed, launched, and played by someone who is not the developer.*

**Router stage: 12 (0.60) · Primary classes: STRUCT → TOOL → SYS → UIUX**

### Legal & Licensing

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 2.01 | Choose and commit LICENSE file | STRUCT | `LICENSE` (new) | All-rights-reserved, MIT, or source-available — owner decision; committed to root |
| 2.02 | Create THIRD_PARTY_NOTICES | DOCS | `THIRD_PARTY_NOTICES` (new) | Godot (MIT), Remotion (check license), @fontsource fonts (SIL OFL), Ogg Vorbis (BSD) — all attributed |
| 2.03 | Document Remotion license terms for embedded cutscenes | STRUCT | `cinematics/LICENSE_NOTE.md` (new) | Written confirmation that rendered .ogv files can ship under chosen game license |

### Repository Cleanup

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 2.04 | Move noir-prose corpus out of repo root | STRUCT | 20 .md files (`00-preface.md` through `20-nesbo.md`) | Moved to `docs/prose-corpus/` or separate repo; no broken references |
| 2.05 | Move craft reference files out of repo root | STRUCT | `01-the-canon.md` through `09-variants.md` | Moved alongside prose corpus |
| 2.06 | Move scene files out of repo root | STRUCT | `chandler-scene.md`, `leonard-scene.md` | Moved alongside prose corpus |
| 2.07 | Remove duplicate READMEs | STRUCT | `README (1).md`, `README (2).md` | Deleted; single README.md remains |
| 2.08 | Remove stray `download` file | STRUCT | `download` | Deleted |
| 2.09 | Remove or relocate `series.json` | STRUCT | `series.json` | Moved to prose corpus or deleted if unused |
| 2.10 | Remove or relocate `style_lint.py` and `test_style_lint.py` | STRUCT | `style_lint.py`, `test_style_lint.py` | Moved to prose corpus (they lint prose, not game code) |
| 2.11 | Verify `.gitignore` covers all build artifacts | TOOL | `.gitignore` | `release/`, `.build/`, `build/`, `.godot/`, `node_modules/` all excluded |

### Windows Build & Distribution

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 2.12 | Rebuild Windows exe from current source | TOOL | `tools/build_windows_exe.sh`, `release/` | `tools/inspect_pck.py --verify` clean; `tools/inspect_exe.py` clean; under 100MB |
| 2.13 | Verify pack contents match source tree | TOOL | `tools/inspect_pck.py` | All 498+ files MD5-verified; no stale scripts; all 12 maps present |
| 2.14 | Test Windows build on real hardware (full session) | QA | `RELEASE.md`, `tools/build_windows_exe.sh` | 30+ minute playtest of built `release/TheViolence.exe`: boot, new campaign, week 1–3, save/reload, test range, endless battle, settings change, quit |
| 2.15 | Choose code-signing or storefront distribution | STRUCT | documented decision | OV/EV cert acquired, OR itch.io/Steam chosen with account created; SmartScreen strategy documented |
| 2.16 | Add Windows build to `.gitignore` for source repo | TOOL | `.gitignore` | `release/*.exe` excluded; documented in RELEASE.md how to rebuild |

### Crash Logging & Error Handling

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 2.17 | Add crash-log writing to `user://logs/` | SYS | `scripts/main.gd` | Unhandled errors write to `user://logs/godot_<timestamp>.log`; directory created if absent |
| 2.18 | Add bug-report instructions to credits page | UIUX | `scripts/ui/front.gd` | Credits page tells player: "Found a bug? Check `user://logs/` and send the latest file to [contact]" |
| 2.19 | Add graceful degradation for missing video files | SYS | `scripts/ui/cutscene.gd`, `scripts/ui/shorts.gd` | Missing .ogv files log a warning and skip; no crash, no stuck screen |
| 2.20 | Add graceful degradation for read-only `user://` | SYS | `scripts/ui/settings.gd`, `scripts/campaign/save_file.gd` | Settings and saves warn on write failure; game continues with in-memory state |

### Cutscene Decisions

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 2.21 | Wire `S01_Week` to week-start beat | SYS | `scripts/main.gd`, `scripts/ui/shorts.gd` | `play_short("s01_week", {...})` called at week start with correct slot text |
| 2.22 | Wire `S02_Situation` to situation-pick beat | SYS | `scripts/ui/ops_ui.gd` | `play_short("s02_situation", {...})` called when situation selected from board |
| 2.23 | Wire `S03_Plan` to plan-signed beat | SYS | `scripts/ui/ops_ui.gd` | `play_short("s03_plan", {...})` called when RUN pressed, before operation starts |
| 2.24 | Wire `S04_Staging` to operation-start beat | SYS | `scripts/main.gd` | `play_short("s04_staging", {...})` called at operation start |
| 2.25 | Wire `S05_Threshold` to first-door beat | SYS | `scripts/sim/world.gd`, `scripts/main.gd` | `play_short("s05_threshold", {"variant": "clear"/"contact"})` on first door breach |
| 2.26 | Wire `S07_Debrief` to debrief-open beat | SYS | `scripts/ui/ops_ui.gd` | `play_short("s07_debrief", {...})` called when debrief screen opens |
| 2.27 | Wire `S08_Press` to week-end Ledger beat | SYS | `scripts/campaign/story.gd`, `scripts/ui/ops_ui.gd` | `play_short("s08_press", {...})` when Ledger page shows |
| 2.28 | Wire `S10_Ally` to ally-standing-change beat | SYS | `scripts/campaign/politics.gd` | `play_short("s10_ally", {...})` when ally crosses 25 threshold |
| 2.29 | Wire `S13_Allocation` to council-review beat | SYS | `scripts/campaign/politics.gd` | `play_short("s13_allocation", {...})` at 8-week council review |
| 2.30 | Wire `S14_Course` to training-complete beat | SYS | `scripts/campaign/department.gd` | `play_short("s14_course", {...})` when officer finishes a course |
| 2.31 | Add shorts-enabled setting | UIUX | `scripts/ui/settings.gd` | Settings toggle: "Play interstitial cutscenes" (default on); honored by all `play_short` calls |

**Exit criteria:** LICENSE committed. Repo root clean (only game files). Windows exe rebuilt and tested on real hardware. Crash logging in place. All 14 shorts wired or formally excluded with documented reason.

---

## M3 — Player Experience (0.70 → 0.80): "Make it feel finished"

*Goal: A new player's first hour is polished, the game sounds finished, and accessibility basics are met.*

**Router stage: 13–14 (0.65–0.70) · Primary classes: AUDIO → ASSETS → UIUX → SYS → NARR**

### Music & Score

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 3.01 | Compose title theme | ASSETS/AUDIO | `assets/audio/music/title.ogg` (new) | 30–90 second loop; noir/jazz register; matches ink-on-paper aesthetic |
| 3.02 | Compose campaign board ambient bed | ASSETS/AUDIO | `assets/audio/music/board.ogg` (new) | Loopable ambient; plays under the operations board; low enough to not fight SFX |
| 3.03 | Compose operation ambient bed | ASSETS/AUDIO | `assets/audio/music/operation.ogg` (new) | Loopable tension bed; plays during RUN; ducks under radio and gunfire |
| 3.04 | Compose election-night stinger | ASSETS/AUDIO | `assets/audio/music/election.ogg` (new) | 15–30 second piece for the election results screen |
| 3.05 | Compose debrief stinger (success/cost/failure variants) | ASSETS/AUDIO | `assets/audio/music/debrief_*.ogg` (new) | Three short stingers (3–8s) matching the three debrief outcomes |
| 3.06 | Add Music bus to audio layout | SYS | `scripts/ui/settings.gd`, `scripts/view/sound.gd` | Named `Music` bus registered alongside `Effects` and `Ambience`; Settings gains Music volume slider; all music routed through it |
| 3.07 | Integrate music into game flow | SYS | `scripts/main.gd`, `scripts/view/sound.gd` | Title theme on title screen; board ambient on operations board; operation bed during RUN; crossfade on transitions; no overlap |
| 3.08 | Loudness-normalize all music to match SFX levels | AUDIO | `assets/audio/music/` | No 20dB jumps between music and SFX; verified by ear and meter |

### Accessibility

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 3.09 | Add UI scale option (100%/125%/150%) | UIUX | `scripts/ui/settings.gd`, `scripts/ui/ui.gd` | Three scale options; tested on manual, debrief, and board at each step; persisted in settings.cfg |
| 3.10 | Add key rebinding UI | UIUX | `scripts/ui/settings.gd`, `scripts/ui/front.gd` | At minimum: pause, speed up, speed down, zoom in, zoom out, toggle fog rebindable; stored in settings.cfg |
| 3.11 | Add reduced-motion toggle | UIUX | `scripts/ui/settings.gd`, `scripts/view/rig.gd`, `scripts/ui/cutscene.gd` | Disables camera shake, figure animation easing, and cutscene motion (stills with crossfade instead); persisted |
| 3.12 | Add colorblind-safe evidence markers | UIUX | `scripts/view/decals.gd`, `scripts/view/marks.gd` | Evidence markers use shape + number (not color alone); tested with red/green and blue/yellow deficiency simulation |
| 3.13 | Add subtitle/caption support for radio calls | UIUX | `scripts/sim/world.gd`, `scripts/ui/ops_ui.gd` | All radio text is visible in the log; no audio-only information; toggle for caption overlay on operation view |
| 3.14 | Add window-size options alongside fullscreen | UIUX | `scripts/ui/settings.gd`, `project.godot` | At least 1600×900, 1280×720, and windowed-auto; tested at 1366×768 |

### Onboarding & Polish

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 3.15 | Conduct fresh-eyes playtest #1 | QA | `PLAYTEST_REPORT.md` | 3+ people who have never seen the game play for 15 minutes; observations cataloged |
| 3.16 | Conduct fresh-eyes playtest #2 | QA | `PLAYTEST_REPORT.md` | Different 3+ people; different observations; pattern comparison |
| 3.17 | Conduct fresh-eyes playtest #3 | QA | `PLAYTEST_REPORT.md` | Third group; top-5 cross-session confusion points identified |
| 3.18 | Address top-5 onboarding confusion points | SYS/UIUX | varies | Each confusion point from 3.15–3.17 gets a specific fix (UI text, tooltip, guide card, or flow change); documented in CHANGELOG |
| 3.19 | Add rally-reset visibility to debrief | SYS/UIUX | `scripts/campaign/outcome.gd`, `scripts/ui/ops_ui.gd` | Debrief shows "Rally: N seconds of quiet recovered M stress" when applicable; makes Q1 mechanic visible |
| 3.20 | Add statement-integrity visibility to IA screen | SYS/UIUX | `scripts/campaign/department.gd`, `scripts/ui/ops_ui.gd` | IA case shows "Statement: HELD / CONTRADICTED bodycam" when applicable; makes Q3 mechanic visible |
| 3.21 | Add less-lethal-first order visibility to debrief | SYS/UIUX | `scripts/campaign/outcome.gd`, `scripts/ui/ops_ui.gd` | Debrief shows when less-lethal-first was active and how many uses occurred; makes Q6 mechanic visible |
| 3.22 | Polish title screen flow | UIUX | `scripts/ui/front.gd` | Continue shows useful info (week, fit officers, account); New Campaign warns before replacing save; smooth transitions |
| 3.23 | Add loading/transition screens | UIUX | `scripts/ui/front.gd`, `scripts/main.gd` | No blank screens during campaign load or map generation; ink-style loading indicator |
| 3.24 | Audit and fix UI contrast ratios | UIUX | `scripts/view/ink.gd`, `scripts/view/palette.gd` | All text meets 4.5:1 contrast ratio against its background; tested with monochrome (F2) mode |

**Exit criteria:** Three fresh-eyes playtests logged with top-5 confusion points addressed. Score present (title theme + 2 ambient beds + stingers). Settings include font scale, rebinding, reduced motion, and window size. Q1/Q3/Q6 mechanics visible in debrief/IA.

---

## M4 — Depth (0.80 → 0.90): "Make it last"

*Goal: The game's content depth matches its systems depth. Strings are localizable. Performance is budgeted.*

**Router stage: 15–16 (0.75–0.80) · Primary classes: SYS → PERF → TOOL → NARR → QA**

### Localization Infrastructure

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 4.01 | Set up Godot translation CSV | TOOL | `assets/translations/en.csv` (new) | Translation CSV created with all current English strings; Godot auto-translates when locale changes |
| 4.02 | Extract UI strings from `scripts/ui/front.gd` | SYS/NARR | `scripts/ui/front.gd`, `assets/translations/en.csv` | All player-facing strings use `tr("key")`; keys namespaced: `manual.page1.title`, `credits.role.dev`, etc. |
| 4.03 | Extract UI strings from `scripts/ui/ops_ui.gd` | SYS/NARR | `scripts/ui/ops_ui.gd`, `assets/translations/en.csv` | All briefing labels, debrief text, board text through `tr()`; keys: `briefing.confirmed`, `debrief.result.success`, etc. |
| 4.04 | Extract UI strings from `scripts/ui/settings.gd` | SYS/NARR | `scripts/ui/settings.gd`, `assets/translations/en.csv` | All settings labels through `tr()`; keys: `settings.fullscreen`, `settings.volume.master`, etc. |
| 4.05 | Extract campaign text from `scripts/campaign/` | SYS/NARR | `scripts/campaign/*.gd`, `assets/translations/en.csv` | Situation types, ward names, ally names, candidate names, ending text through `tr()` |
| 4.06 | Extract Ledger headlines template | SYS/NARR | `scripts/campaign/story.gd`, `assets/translations/en.csv` | Headline templates through `tr()`; dynamic content (names, numbers) inserted without concatenation |
| 4.07 | Proof one non-English language end-to-end | NARR/TOOL | `assets/translations/fr.csv` (or other) | One complete language (French, Spanish, or German) translated; all keys present; tested in-game |
| 4.08 | Verify no sentence concatenation | SYS | `scripts/` (all) | No `str(a, " ", b, " ", c)` patterns that break in other languages; flagged and refactored |

### Performance & Memory

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 4.09 | Define performance budgets | PERF | `ARENA_STATE.md`, `tests/perf.gd` | Frame time ≤16.6ms, draw calls ≤N, node count ≤N on m11_plaza at 20v20; numbers recorded |
| 4.10 | Add performance assertions to `tests/perf.gd` | PERF/TOOL | `tests/perf.gd` | Exits 1 when any budget exceeded; runs in `--soak` tier |
| 4.11 | Run 30-minute memory soak | PERF | `tests/perf.gd` or manual | `Performance.MEMORY_STATIC` logged every 60s for 30 minutes; no steady growth; results recorded |
| 4.12 | Profile city simulation hot paths | PERF | `scripts/city/city_nav.gd`, `scripts/city/director.gd` | Route-cache timings and AI decision costs measured; bottlenecks identified and filed as packets if needed |
| 4.13 | Profile figure animation at scale | PERF | `scripts/view/rig.gd`, `scripts/view/actor_view.gd` | 30+ animated figures at 60fps on target hardware; off-screen culling verified |

### Extended Testing

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 4.14 | Run 5 full campaigns at different seeds | QA | `tests/op_test.gd --chief=sensible` | 5 × 40-week campaigns; all 3 endings reachable (Kettering, Okonjo-Vale, Pell); outcomes cataloged |
| 4.15 | Verify no degenerate campaign paths | QA | campaign logs from 4.14 | No campaign loses all officers before week 20; no election is a blowout (>70%); budget doesn't go permanently red before week 10 |
| 4.16 | Run endless battle 30-minute soak | QA/SYS | `tests/city_sim.gd --min=30` | 30 minutes continuous; zero error log entries; AI, pathfinding, dormancy, and route-cache all clean |
| 4.17 | Run `civ_test --n=40` at multiple seeds | QA/SYS | `tests/civ_test.gd` | Civilian gate passes at 3+ different seeds; patrol always ≤ police tactical on civilian hits |
| 4.18 | Run `brains_test --n=16` for extended validation | QA/SYS | `tests/brains_test.gd` | All 7 brain parts pass at n=16 (double the default); no regression from n=8 values |
| 4.19 | Run `lethality_test --n=12` for extended validation | QA/SYS | `tests/lethality_test.gd` | Officer casualty rates stable at double sample size; friendly-fire rate near zero |

### Store Assets

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 4.20 | Generate trailer from deterministic recording | ASSETS/TOOL | `tools/make_ads.py`, `tools/mix_soundtrack.py` | At least one 60–90 second trailer cut from a deterministic game recording with soundtrack |
| 4.21 | Capture store screenshots | ASSETS | `screenshots/` (new) | 5+ screenshots: title, briefing, operation under fog, debrief, election night; at 1920×1080 |
| 4.22 | Write store description | DOCS/NARR | `STORE_PAGE.md` (new) | 200–400 word description; honest about vertical slice scope; lists 3 modes, 12 maps, 40-week campaign |
| 4.23 | Document system requirements | DOCS | `STORE_PAGE.md` or `README.md` | Min: Windows 10 64-bit, OpenGL 3.3, 2GB RAM, 200MB disk. Recommended: Windows 11, 4GB RAM |

**Exit criteria:** Strings localizable (one non-English language proofed). Performance and memory budgets asserted and met. Five full campaigns logged with all three endings reachable. Store assets ready.

---

## M5 — Release (0.90 → 1.00): "Ship it"

*Goal: The release checklist is complete. The game is in players' hands.*

**Router stage: 17–20 (0.85–1.00) · Primary classes: DOCS → STRUCT → TOOL → QA → MIGR**

### Release Preparation

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 5.01 | Write player-facing release notes | DOCS | `RELEASE_NOTES.md` (new) | Covers what's in the vertical slice; known limitations honestly stated; controls summary |
| 5.02 | Create bug report template | DOCS | `.github/ISSUE_TEMPLATE/bug_report.md` (new) | Fields: build version, OS, steps to reproduce, expected, actual, log file attachment instructions |
| 5.03 | Create feature request template | DOCS | `.github/ISSUE_TEMPLATE/feature_request.md` (new) | Fields: description, why, which game mode it affects |
| 5.04 | Test save migration from v0.50 to v1.0.0 | MIGR/SYS | `scripts/campaign/save_file.gd`, `tests/save_test.gd` | v0.50 saves load cleanly under v1.0.0; migration code tested; test asserts round-trip |
| 5.05 | Run full regression suite one final time | QA | `tools/run_tests.sh --soak` | All tiers green; balance matrix cells unchanged from M1 values; no new regressions |
| 5.06 | Final Windows build from release-ready source | TOOL | `tools/build_windows_exe.sh` | Rebuilt; `tools/inspect_pck.py --verify` clean; `tools/inspect_exe.py` clean; SHA-256 recorded |
| 5.07 | Final Windows hardware test | QA | `RELEASE.md`, `tools/build_windows_exe.sh` | Full playtest of built Windows binary: boot, campaign weeks 1–3, save/reload, test range, endless, settings, quit |
| 5.08 | Code-sign or confirm storefront distribution | TOOL/STRUCT | documented | Signed binary, OR itch.io/Steam page live with unsigned binary and SmartScreen warning explained |

### Platform Submission

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 5.09 | Create itch.io page (or chosen platform) | STRUCT | platform account | Page live with screenshots, trailer, description, system requirements, and download |
| 5.10 | Attach signed exe to GitHub Release | TOOL | GitHub Release | `release/TheViolence.exe` attached to `v1.0.0` tag; SHA-256 in release notes |
| 5.11 | Write post-release bug path documentation | DOCS | `SUPPORT.md` (new) or `README.md` section | Non-developer can report a bug: where to find logs, where to file (GitHub issue, email, or form) |
| 5.12 | Write known-issues list for launch | DOCS | `KNOWN_ISSUES.md` (new) or release notes section | Every known limitation documented with workaround if one exists |

### Version & Tag

| ID | Task | Class | Scope | Acceptance |
|---|---|---|---|---|
| 5.13 | Bump version to 1.0.0 | TOOL | `scripts/version.gd` | `VALUE := "1.0.0"` |
| 5.14 | Sync version metadata | TOOL | `tools/sync_version.py` | `project.godot`, `export_presets.cfg`, `scripts/version.gd` all say 1.0.0; `--check` passes |
| 5.15 | Tag the release | TOOL | git | `git tag v1.0.0` on the release commit; pushed to origin |
| 5.16 | Update ARENA_STATE.md to stage 20 (1.00) | STRUCT | `ARENA_STATE.md` | `stage: 20 (1.00) · phase: release`; release checklist complete; final playtest logged |

**Exit criteria:** The game is publicly available through at least one channel. Bug reporting path exists. Version reads 1.0.0. Tagged.

---

## Backlog (unrouted — not commitments)

| ID | Task | Class | Notes |
|---|---|---|---|
| B.01 | Multiplayer observation mode | SYS/ARCH | Second player watches as "the press" |
| B.02 | Procedural map generation | SYS/ASSETS | Variants of the 12 hand-built maps for replayability |
| B.03 | Modding support (equipment + habits) | SYS/TOOL | Expose databases for community mods |
| B.04 | Controller-first UI redesign | UIUX | Console-style navigation for gamepad |
| B.05 | Additional languages (past first proof) | NARR/TOOL | Depends on 4.01–4.08 |
| B.06 | Expanded campaign (>40 weeks) | SYS/NARR | Additional candidates, branching endings |
| B.07 | Difficulty settings | SYS/UIUX | Rookie/Veteran/Chief presets affecting officer stats and intel quality |
| B.08 | Replay export to video | TOOL/SYS | `--cam=action` recording path polished into a one-click export |
| B.09 | Steam achievements / stats tracking | SYS/TOOL | Platform integration for campaign completions, endings reached |
| B.10 | Speedrun mode | SYS/UIUX | Deterministic seed + timer + no-pause constraint |

## Explicitly out of scope

- **Real-time direct control of officers** — the game is a command sim, not a shooter. The player plans and watches.
- **Multiplayer competitive** — the design is single-player narrative campaign + sandbox.
- **Mobile port** — gl_compatibility renderer and 1600×900 baseline make this a desktop game.
- **VR** — the top-down paper aesthetic is fundamentally flat.
- **Live service / ongoing content** — the game is a finite single-player experience.

---

## Version history

| Date | Change |
|---|---|
| 2026-10-25 | v2 — Expanded from ~35 to ~100 tasks with file-level specificity. Each task has unique ID, class, scope, and acceptance criteria. Router stage mapping added per milestone. |
| 2026-10-25 | Initial roadmap. Version relabeled from 1.2.1 to 0.50. Five milestones defined. |
