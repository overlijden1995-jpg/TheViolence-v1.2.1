# The Violence — Roadmap from `0.50` to `1.0`

**Current state:** `0.60` (M1 Foundation complete)  
**Target:** `1.00` — commercially shippable on Steam / itch.io as a complete, deterministic, accessible, tested, legally clean single-player tactical-political simulation.

---

## Versioning Scheme

| Version | Milestone | Theme | Exit Criterion |
|---|---|---|---|
| `0.50` | Baseline | Post-1.2.1 honesty cut | All code in tree; unverified in CI; repo uncleaned |
| `0.60` | **M1 — Foundation** | **"Make the branch true"** | Zero silent test failures; 1.2.1/1.2.2 verified on Godot 4.7.2; determinism extended to Q1/Q3/Q6; perf baseline recorded; licensing files in place |
| `0.70` | **M2 — Clean Ship** | **"Clean the house"** | Packaging, Windows code-sign & Steam/itch manifests, reproducibility lock |
| `0.80` | **M3 — Player-Complete** | **"Teach, show, control"** | Onboarding tutorial, keybind remapping, UI scale & colourblind modes, full save/load & settings persistence |
| `0.90` | **M4 — Depth & Polish** | **"Every system sings"** | Replay viewer, post-op AAR timeline, expanded map pool & procedural mutators, audio/visual polish, achievement hooks |
| `0.95` | **M5 — Release Candidate** | **"Break it before they do"** | 1,000-seed fuzz/soak zero crashes, localization scaffolding, Steam Deck verification, store-page build lock |
| `1.00` | **Gold Master** | **"Filed. Resolved."** | Signed Windows + Linux builds, tag `v1.0.0`, zero P0/P1 bugs, frozen determinism fixture |

---

## Milestone 1 — `0.50 → 0.60`: Foundation ("Make the branch true")

### 1A. Eliminate Silent Test Failures (18 Harnesses + Runner)

Every harness under `tests/` exits non-zero (`quit(1)`) on invariant failure or degeneracy, and `tools/run_tests.sh` gates on process exit code plus `SCRIPT ERROR` / `Parse Error` log scanning.

| ID | Status | Task | File(s) |
|---|---|---|---|
| `1.01` | `[x]` | Track error count in `_check.gd`; `quit(1)` if `errors > 0` | `tests/_check.gd` |
| `1.02` | `[x]` | Exit `quit(1)` when patrol vs. police tactical civilian-hit gate fails | `tests/civ_test.gd` |
| `1.03` | `[x]` | Exit `quit(1)` when any of the 27 equipment items fails its directional assertion | `tests/equip_test.gd` |
| `1.04` | `[x]` | Assert holding defender exchange ratio >= non-holding across echelons (`--gate` / default) | `tests/hold_test.gd` |
| `1.05` | `[x]` | Assert lethality envelope (overall lethality in `[15%, 55%]`, vest reduces fatal rate) | `tests/lethality_test.gd` |
| `1.06` | `[x]` | Exit `quit(1)` when `problems > 0` across all 12 built-in maps | `tests/maps_test.gd` |
| `1.07` | `[x]` | Assert zero doorway stalls across 20 runs on maps 2, 4, 8, 9 | `tests/nav_door_test.gd` |
| `1.08` | `[x]` | Exit `quit(1)` when `checks_failed > 0` across 5-map police operation invariant suite | `tests/op_test.gd` |
| `1.09` | `[x]` | Assert zero crashes and `>= 90%` incident resolution on `city_test.gd` | `tests/city_test.gd` |
| `1.10` | `[x]` | Add non-degeneracy assertions (`--gate`) to `city_sim.gd` | `tests/city_sim.gd` |
| `1.11` | `[x]` | Exit `quit(1)` on any invariant problem (`problems.size() > 0`) in `fuzz_test.gd` | `tests/fuzz_test.gd` |
| `1.12` | `[x]` | Add `--gate` step-time (`<= 8.0 ms/tick` headless on `m11_plaza` 20v20) and static memory (`<= 512 MB`) bounds to `perf.gd` | `tests/perf.gd` |
| `1.13` | `[x]` | Add `--gate` non-degeneracy check (`<= 50%` timeout rate) to `playtest.gd` | `tests/playtest.gd` |
| `1.14` | `[x]` | Add `--gate` non-degeneracy check (`<= 50%` timeout rate) to `sim_test.gd` | `tests/sim_test.gd` |
| `1.15` | `[x]` | Exit `quit(1)` if `stalled > 0` when `--gate` is passed to `stall_test.gd` | `tests/stall_test.gd` |
| `1.16` | `[x]` | Assert match advances (`w.t > 0`) and logs events in `trace.gd` | `tests/trace.gd` |
| `1.17` | `[x]` | Assert shots and casualties occur (`--gate`) in `duel_probe.gd` | `tests/duel_probe.gd` |
| `1.18` | `[x]` | Add headless pose-validation mode (`DisplayServer.get_name() == "headless"` or `--check`) to `rig_gallery.gd` + runtime SVG fallback in `Decals.tex()` | `tests/rig_gallery.gd`, `scripts/view/decals.gd`, `scripts/view/rig.gd` |
| `1.19` | `[x]` | Switch `tools/run_tests.sh` `PLAN` to `exit` detection across all 34 harnesses (`rig_gallery.gd` promoted to `quick`) | `tools/run_tests.sh` |

### 1B. Engine Verification & Balance Re-validation (Godot 4.7.2)

| ID | Status | Task | File(s) |
|---|---|---|---|
| `1.20` | `[x]` | Run `balance_matrix_test.gd -- --gate --n=30` on Godot 4.7.2; verify all 8 tactical ordering assertions pass | `tests/balance_matrix_test.gd`, `CHANGELOG.md` |
| `1.21` | `[x]` | Run `orders_test.gd` on Godot 4.7.2; verify 6/6 tactical order checks pass | `tests/orders_test.gd`, `CHANGELOG.md` |
| `1.22` | `[x]` | Run `civ_test.gd` on Godot 4.7.2; record patrol vs. tactical civilian-hit actuals (`30` vs. `20`) | `tests/civ_test.gd`, `CHANGELOG.md` |
| `1.23` | `[x]` | Run `dept_test.gd` on Godot 4.7.2; verify 52-week department simulation and Q3/Q4 invariants | `tests/dept_test.gd`, `CHANGELOG.md` |
| `1.24` | `[x]` | Run `politics_test.gd` on Godot 4.7.2; verify Q5 inquiry & commission chains | `tests/politics_test.gd`, `CHANGELOG.md` |
| `1.25` | `[x]` | Run `story_test.gd` on Godot 4.7.2; verify 52-week narrative arc invariants | `tests/story_test.gd`, `CHANGELOG.md` |
| `1.26` | `[x]` | Run `city_improvements_test.gd` on Godot 4.7.2; verify Q8 multi-district callout & vehicle pool | `tests/city_improvements_test.gd`, `CHANGELOG.md` |
| `1.27` | `[x]` | Run `equip_test.gd` on Godot 4.7.2; verify 27/27 equipment directional checks pass | `tests/equip_test.gd`, `CHANGELOG.md` |

### 1C. Determinism Fixture Coverage for 1.2.2 (Q1, Q3, Q6)

| ID | Status | Task | File(s) |
|---|---|---|---|
| `1.28` | `[x]` | Add `q1_rally_reset_1001` case exercising `RALLY_QUIET` / `RALLY_DECAY` in `World._passive()` | `tests/determinism_test.gd` |
| `1.29` | `[x]` | Add `q6_less_lethal_first_1001` case exercising `less_first_blocked()`, single challenge, and less-lethal fire inside `LESS_FIRST_R` | `tests/determinism_test.gd` |
| `1.30` | `[x]` | Add `q3_statement_integrity_1001` case exercising `Department.apply_result()` officer statement vs. bodycam evidence and witness testimony | `tests/determinism_test.gd` |
| `1.31` | `[x]` | Regenerate `tests/fixtures/determinism.json` (`--write`, 38 cases) and verify two back-to-back runs match 38/38 | `tests/fixtures/determinism.json` |

### 1D. CI, Performance Baseline & Licensing

| ID | Status | Task | File(s) |
|---|---|---|---|
| `1.32` | `[x]` | Prepare CI workflow (`tools/ci/ci.yml`) and document owner activation step (`git mv tools/ci/ci.yml .github/workflows/ci.yml`) | `tools/ci/ci.yml`, `RELEASE_READINESS.md` |
| `1.33` | `[x]` | Verify local CI equivalent (`run_tests.sh --check` and `--quick`) passes 100% on Godot 4.7.2 | `RELEASE_READINESS.md` |
| `1.34` | `[x]` | Record headless performance baseline (`perf.gd -- --map=11 --na=20 --nb=20 --t=60 --gate`) on Godot 4.7.2 | `tests/perf.gd`, `RELEASE_READINESS.md` |
| `1.35` | `[x]` | Fix `tests/godot472_test.gd` so `_test_nav_without_build()` runs in `_init()`; provide owner checklist for physical Windows GPU smoke test | `tests/godot472_test.gd`, `RELEASE_READINESS.md` |
| `1.36` | `[x]` | Add `LICENSE`, `THIRD_PARTY_NOTICES`, and `cinematics/LICENSE_NOTE.md` | `LICENSE`, `THIRD_PARTY_NOTICES`, `cinematics/LICENSE_NOTE.md` |

---

## Milestone 2 — `0.60 → 0.70`: Clean Ship ("Clean the house")

| ID | Status | Task | File(s) |
|---|---|---|---|
| `2.01` | `[x]` | Add root `LICENSE` file | `LICENSE` |
| `2.02` | `[x]` | Add `THIRD_PARTY_NOTICES` (Godot 4.7.2 MIT, Xiph BSD, Fontsource OFL-1.1, Remotion) | `THIRD_PARTY_NOTICES` |
| `2.03` | `[x]` | Add `cinematics/LICENSE_NOTE.md` documenting offline Remotion `.ogv` rendering terms | `cinematics/LICENSE_NOTE.md` |
| `2.04` | `[x]` | Remove 38 stray `.RData` / `.py` / `.R` / `.txt` root scratch files | Root directory (completed in PR #17) |
| `2.05` | `[x]` | Expand `.gitignore` to block `.RData`, `.Rhistory`, `*.pyc`, `__pycache__/`, `.DS_Store`, `Thumbs.db` | `.gitignore` (completed in PR #17) |
| `2.06` | `[x]` | Remove `Arena Protocols/` directory and clean `README.md` | `README.md` (completed in PR #17) |
| `2.07` | `[ ]` | Decide whether `release/TheViolence.exe` stays in Git or moves strictly to GitHub Releases | `release/`, `.gitignore` |
| `2.08` | `[x]` | Add `.gdignore` inside `cinematics/` so Godot never imports `node_modules/` | `cinematics/.gdignore` (completed in PR #17) |
| `2.09` | `[x]` | Add `export_presets.cfg` exclusion filters (`tests/*`, `tools/*`, `cinematics/*`, `docs/*`, `*.md`, `*.py`, `*.sh`) | `export_presets.cfg` (completed in PR #17) |
| `2.10` | `[x]` | Fix `tools/sync_version.py` so `file_version` and `product_version` match `X.Y.Z.0` | `tools/sync_version.py` (completed in PR #17) |
| `2.11` | `[ ]` | Add `Linux/X11` (`x86_64`) export preset to `export_presets.cfg` and `tools/build_release.sh` | `export_presets.cfg`, `tools/build_release.sh` |
| `2.12` | `[ ]` | Add SHA-256 checksum generation (`SHA256SUMS.txt`) to `tools/build_release.sh` | `tools/build_release.sh` |
| `2.13` | `[ ]` | Document Windows Authenticode signing & SmartScreen reputation steps | `docs/SIGNING.md` |
| `2.14` | `[x]` | Pin exact npm dependency versions in `cinematics/package.json` | `cinematics/package.json` (completed in PR #17) |
| `2.15` | `[ ]` | Add `--verify` mode to `tools/make_placeholders.py` and `tools/make_sounds.py` | `tools/make_placeholders.py`, `tools/make_sounds.py` |

---

## Milestone 3 — `0.70 → 0.80`: Player-Complete ("Teach, show, control")

- **3A (`3.01–3.05`):** Interactive 3-step onboarding ("Day Zero at the Training House") & contextual first-campaign hints.
- **3B (`3.06–3.10`):** Input map migration (`project.godot`), keybind remapping UI (`scripts/ui/front.gd`), and `user://settings.json` persistence.
- **3C (`3.11–3.15`):** UI text scale (`90%` / `100%` / `115%` / `130%`), colourblind palettes (Deuteranopia / Protanopia / Tritanopia), screen-shake & flashbang-strobe toggles, cutscene captions.
- **3D (`3.16–3.20`):** 3-slot save system (`user://save_1.json` .. `save_3.json`), rolling `.bak` backup, schema migration (`save_version`), and mid-operation suspend-save.

---

## Milestone 4 — `0.80 → 0.90`: Depth & Polish ("Every system sings")

- **4A (`4.01–4.05`):** Post-operation timeline scrubber & deterministic seed/order replay (`user://replays/`).
- **4B (`4.06–4.10`):** 4 new maps (`m12_courthouse`, `m13_Coldwater_pier`, `m14_rail_depot`, `m15_precinct_house`) + procedural weather/lighting mutators.
- **4C (`4.11–4.15`):** Ward-specific newspaper headlines, testimony transcript drawer, Election Night multi-page dossier, and 6 new short interstitials (`s15–s20`).
- **4D (`4.16–4.19`):** Ambient soundscapes, acoustic occlusion across closed doors, 60 Hz camera interpolation, and muzzle-flash/flashlight lighting polish.

---

## Milestone 5 — `0.90 → 0.95 → 1.00`: Release Candidate & Gold Master

- **5A (`5.01–5.05`):** 1,000-seed fuzz & 200-campaign soak zero-failure gate, save-compatibility corpus, memory leak soak test.
- **5B (`5.06–5.10`):** Localization string table (`tr()`), Steamworks / itch.io build hooks & 16 achievements, Steam Deck (`1280x800`) verification.
- **5C (`5.11–5.15`):** Finalize `RELEASE_READINESS.md`, bump to `1.00`, build signed Windows + Linux artefacts, and tag `v1.0.0`.
