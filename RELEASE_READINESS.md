# The Violence — release readiness

**Analysis date:** 2026-10-25 · **Branch:** `arena/113d2ca6-theviolence-v1-2-1` · **Milestone:** `0.70` (M2 Clean Ship complete) · **Version in tree:** `0.70` (`0.70.0.0` Windows metadata)

This document is an assessment, not a changelog entry: what state the game is
actually in, what stands between it and a `1.00` release (`ROADMAP.md`), and the
order to do the remaining work in. Everything asserted here is cited to a file
or was measured on Godot `4.7.2-stable` on this branch.

---

## 0. Status Summary (`v0.70` — M1 Foundation + M2 Clean Ship Complete)

Milestones 1 (`0.50 → 0.60`: **"Make the branch true"**) and 2 (`0.60 → 0.70`: **"Clean the house"**) are complete in-repo:

1. **Zero silent test failures (`1.01–1.19`):** All 34 runnable harnesses in `tests/` exit non-zero (`quit(1)`) on invariant failure or degeneracy, `rig_gallery.gd` has a headless pose-validation mode (`--check` / `DisplayServer.get_name() == "headless"`), and `tools/run_tests.sh` gates on process exit code plus `SCRIPT ERROR` / `Parse Error` log scanning.
2. **Full Godot 4.7.2 verification (`1.20–1.27`, `1.33`):** `run_tests.sh --check` (`1/1`) and `--quick` (`12/12`), `balance_matrix_test.gd -- --gate --min=30` (`16/16` gated cells), `equip_test.gd` (`27/27` items), `civ_test.gd` (`patrol 30 vs police 20`), `orders_test.gd` (`15/15` orders), `lethality_test.gd`, `hold_test.gd`, `maps_test.gd`, `nav_door_test.gd`, `op_test.gd`, `city_test.gd`, `city_sim.gd`, `fuzz_test.gd`, and `stall_test.gd` all pass on Godot `4.7.2-stable`.
3. **Determinism extended to 38 cases (`1.28–1.31`):** Added `q1_rally_reset_1001`, `q3_statement_integrity_1001`, and `q6_less_lethal_first_1001` to `tests/determinism_test.gd` and `tests/fixtures/determinism.json`; all 38 digests reproduce byte-identically across back-to-back runs.
4. **Performance baseline recorded (`1.12`, `1.34`):** `perf.gd -- --map=11 --na=20 --nb=20 --t=60 --gate` runs at **`3.87 ms/tick`** (`8.6x` realtime) and **`42.0 MiB`** static memory (`+1.3 MiB` delta) on Godot `4.7.2-stable`.
5. **Licensing, Packaging & Reproducibility (`1.36`, `2.01–2.15`):**
   - `LICENSE` (MIT), `THIRD_PARTY_NOTICES`, `cinematics/LICENSE_NOTE.md`, `docs/SIGNING.md`, and `.itch.toml` are in place.
   - `scripts/version.gd` (`Version.WINDOWS := "0.70.0.0"`), `project.godot`, `export_presets.cfg`, and `tools/patch_rc.py` are synced in 4-part `X.Y.Z.0` format via `tools/sync_version.py`.
   - `tools/build_release.sh` builds and verifies both Windows (`release/TheViolence.exe`) and Linux (`release/TheViolence.x86_64`) embedded-pack binaries and writes/verifies `release/SHA256SUMS.txt`.
   - `tools/make_placeholders.py --verify` (123 SVGs + `icon.svg` + `assets/svg/manifest.json`) and `tools/make_sounds.py --verify` (34 WAVs + `assets/sfx/manifest.json`) are wired into CI (`tools/ci/ci.yml`).

### Concise Owner Checklist (External to Sandbox)

- [ ] **Activate GitHub Actions CI (`1.32–1.33`):** From a local checkout or token with `workflow` scope, run:
  ```sh
  mkdir -p .github/workflows
  git mv tools/ci/ci.yml .github/workflows/ci.yml
  git commit -m "ci: activate GitHub Actions workflow"
  git push
  ```
- [ ] **Physical Windows 10/11 hardware smoke test (`1.35`):** Build or copy `release/TheViolence.exe`, boot to title screen, play 1 campaign operation + 2 minutes of Endless City (`Port Carrick`), test `Alt+Tab` and fullscreen toggle, and confirm `user://save.json` and `user://settings.cfg` persist cleanly.

---

## 1. Where the game is

### Scope, measured from the tree

| | |
| --- | --- |
| Game code | 34,458 lines of GDScript in `scripts/` (81 files; 118 GDScript files total across `scripts/`, `tests/`, and `tools/`) |
| Test code | 5,069 lines across 36 files in `tests/` (34 runnable harnesses) |
| Tooling | 3,781 lines in `tools/` (static audit, PCK/PE inspectors, asset generators, ad cutter) |
| Maps | 12 (`scripts/maps/registry.gd`) |
| Content | 89 habit IDs, 34 equipment items, 7 courses, 6 echelons, 6 situation types, 6 wards, 4 allies, 3 candidates |
| Rooms per map | 175 doors across the 12 maps (`tests/nav_door_test.gd` reports the count) |
| Campaign | 40 weeks, then an election (`scripts/campaign/politics.gd`) |
| Video | 18 Ogg Theora source files, 31.4 MB: 4 opening films + 14 shorts. The compact candidate ships the 4 openings + 4 wired shorts; 10 unwired shorts are excluded from export. |

### What has shipped and what is sitting on the branch

| Layer | In the 1.2.1 exe | In this tree (`v0.60`) | Verified on an engine? |
| --- | --- | --- | --- |
| Simulation, campaign, UI | yes | yes + Q1–Q10 pass | **yes** — quick tier, determinism (38 cases), civ, brains, habits, equip (27/27), op_test |
| Godot 4.7.2 compatibility fixes | no | yes | **yes** — imported, loaded and ran on 4.7.2 here (`godot472_test` including `_test_nav_without_build()`) |
| Nav/door fixes (`line_ok`, `leaf_in_way`, `door_ahead`) | no | yes | **yes** — `nav_door_test`: 175 doors, 0 problems |
| 14 short cutscenes | no | yes (4 of 14 wired) | headless policy verified (`improvements_test`) |
| Balance matrix + asserted bands | no | yes (`balance_matrix_test.gd`) | **yes** — all 16 gated cells measured & passing on 4.7.2 (`--gate --min=30`) |
| Performance baseline (`perf.gd`) | no | yes (`--gate`) | **yes** — `m11_plaza` 20v20: `3.87 ms/tick`, `42.0 MiB` static mem |
| CI, test runner, non-zero exit codes | no | **yes** (`1.01–1.19`) | all 34 harnesses exit non-zero on failure; `tools/ci/ci.yml` ready to move to `.github/workflows/ci.yml` |
| Licensing (`LICENSE`, `THIRD_PARTY_NOTICES`) | no | **yes** (`1.36`, `2.01–2.03`) | MIT `LICENSE`, `THIRD_PARTY_NOTICES`, `cinematics/LICENSE_NOTE.md` |

### Engine and version skew

- `scripts/version.gd`, `project.godot`, `export_presets.cfg`, and `tools/patch_rc.py` are now synced at `0.70` (`0.70.0.0` for Windows metadata), and `tools/sync_version.py --check` keeps them in lockstep.
- The project now declares **4.4 and 4.7** as its engines (`project.godot: config/features`), and 4.7.2 is called primary. The shipped exe is **4.4.1** and predates every fix listed above.
- The changelog documents a 4.7.2 build **from source** (`tests/godot472_test.gd`, `tools/gd47_check.py`), so 4.7.2 support is real but has never been exercised through the export path.

**Consequence:** a release built from this tree is not a 1.2.1 patch. It is
1.3.0, with a different engine claim, different physics-adjacent code paths
(nav, doors), and a decade of untested features. Present it as such.

---

## 2. What is genuinely strong (don't break it)

1. **Determinism as a product feature.** 35 seeded fights hashed to the decimal in `tests/fixtures/determinism.json`; the city's pressure write explicitly declines to inherit a played machine's city. Very few indie sims can replay a bug.
2. **The evidence chain is real.** Muzzle flash → incident finding → IA case → statement vs bodycam → delayed press story → lawsuit → election is mechanically connected end to end (`scripts/sim/incident.gd`, `campaign/politics.gd`, `ui/ops_ui.gd`). Nothing in it is cosmetic.
3. **Save safety.** Temp file, parse-back check, swap, `.bak` fallback, and a load path hardened against parseable-but-sick data (`campaign/save_file.gd`, `godot472_test.gd`).
4. **Tuning is data, not code.** `data/habits.gd`, `data/equipment.gd`, `data/courses.gd` are single sources of truth, which is why the balance gates can be cheap to run.
5. **Documentation that tells the truth**, including about its own limits (`RELEASE.md` says plainly what was and was not verified). That is rare and it is why this assessment can be specific.

---

## 3. Release blockers

### P0-1 — The branch had never been executed (mostly closed by this pass)

Three feature passes are stacked on top of each other with static checks only.
The concrete, known-stale artifact is `tests/fixtures/determinism.json`: Q1
(stress decay), Q6 (less-lethal order, Weapons-tight cost) and Q4 (what Suggest
a Plan consumes) all change simulation or plan output, so the fixture will fail
on all 35 cases until it is regenerated deliberately. The changelog admits this
and the balance table has 11 cells reading *"pending first run"*.

**This was the first thing to do, and it is one afternoon of work, not a project.**
I did it: the quick tier passes, `determinism_test` reproduces all 35 cases
unchanged (so no fixture reset was needed after all), and the failures it did
find are the ones in §7. What remains unexecuted is the soak tier — the balance
matrix, equipment, stall, fuzz and the manual-chief campaign comparison.

### P0-2 — No CI, no single runner, and half the harnesses cannot fail a build

- **16 of the 34 runnable harnesses can fail a build** (15 with a conditional `quit()`, plus `determinism_test.gd`'s bare `quit(1)` branches). The other **18 always exit 0**, whatever they find: `civ`, `equip`, `hold`, `lethality`, `maps`, `nav_door`, `op`, `city_test`, `city_sim`, `fuzz`, `perf`, `playtest`, `sim`, `stall`, `trace`, `duel_probe`, `rig_gallery`, and the compile check itself. A regression in any of them is invisible to an automated build.
- `tests/_check.gd` — the compile check — prints `FAILED` and then exits **0**.
- There was no runner: the README asked a human to retype nine commands with their arguments, and no workflow ran them.

Fixed in this pass (§6): `tools/run_tests.sh` (`--check/--quick/--full/--soak`,
per-suite logs, log scanning for the harnesses that cannot exit) and
`tools/ci/ci.yml` (4.7.2 + 4.4.1, activate by moving it under `.github/workflows/`). **The right long-term fix is still to
give every harness an exit code** — the log scan is a net, not a fix.

### P0-3 — The Windows binary is unsigned and older than the source

- The original published build was 107 MiB. The current compact candidate is **92,308,944 bytes (88.0 MiB)**, x86-64, GUI subsystem, no installer, no DLLs, no side-car `.pck` (`RELEASE.md`).
- **Unsigned**: SmartScreen may show "Windows protected your PC" on first run. Signing and a genuine Windows 10/11 startup/play test remain release blockers.
- The new candidate is built from this tree with Godot 4.4.1; its embedded pack verifies and boots under the 4.4.1 Linux editor. A Windows-hardware run and export-path verification under the project's primary Godot 4.7.2 version remain outstanding.
- The build path compiles the editor and Windows template from source because the host cannot fetch the official release assets. Zig is pinned to 0.13.0; rebuild with `tools/build_windows_exe.sh`.

### P0-4 — There is no licence and no third-party notice

There is no `LICENSE`, no `THIRD_PARTY_NOTICES`, and no statement of what a buyer
or player may do with the build. In-game credits (`ui/front.gd: show_credits`)
credit Godot (MIT) and claim every sprite and sound is generated in-repo — true,
they come from `tools/make_placeholders.py` and `tools/make_sounds.py` — but:

- **Remotion** (`cinematics/package.json`, 4.0.537) is not MIT; its licence requires a paid company licence for teams above its free threshold. The rendered `.ogv` files ship inside the game. Confirm the licence situation before selling it.
- **@fontsource** fonts (Open Sans, Oswald, Courier Prime) are SIL OFL and used only to render the videos; OFL does not restrict the resulting video, but keep the attribution with the Remotion sources.
- GitHub's `LICENSE` for the game itself is a decision only you can make (all rights reserved, or a source-available licence).

### P0-5 — Player-visible text was corrupted by a merge, and I fixed it

`scripts/ui/front.gd` shipped a manual with **two pages both titled
"Afterwards"**, one of them ending in a paragraph of controls pasted from a
different page, and a "Planning an operation" page whose first paragraph existed
twice in two drafts (`[Briefing] separates…` immediately followed by `Briefing:
what is known…`). This is the same class of damage as the 1.2.1 `ops_ui.gd`
merge, and it is the one screen every new player reads. Fixed on this branch; the
manual is now 8 clean pages and mentions the new Less-lethal-first order.

---

## 4. High-value gaps (P1 — fix before or at release)

| # | Gap | Evidence | Why it matters |
|---|---|---|---|
| 1 | **10 of 14 interstitial videos have no current gameplay trigger** | `play_short`/`play_consequence_short` are called only for `s06`, `s09`, `s11`, `s12` (`main.gd:1001-1014`, `ops_ui.gd:278`). The remaining **8.6 MB** stays in source but is excluded from the compact export presets. | The compact build no longer pays to ship unreachable clips. Wire the remaining beats before adding them back to a release export. |
| 2 | **No music** | `view/sound.gd` has ambience beds and 34 synthesised SFX, no score | A grid of 40 weeks with no score reads as unfinished; even one loop per screen changes the perceived production value. |
| 3 | **Balance is asserted for one matchup only** | `balance_test.gd` gates equal regulars 5v5 on 4 houses; the 11-cell matrix in `balance_matrix_test.gd` has empty actuals | The game ships 12 maps and 6 echelons. Until the matrix runs, "the balance is measured" covers ~⅓ of the surface. |
| 4 | **Onboarding rests on a suggestion button** | `campaign/autoplan.gd` can play a full 40 weeks (`op_test.gd --chief=sensible`); Veteran mode removes it | The player's only expression is planning. The Q4 reservation work narrows what the suggestion knows — prove it with the `--chief=manual` comparison before shipping the claim. |
| 5 | **No accessibility beyond red-ink and gore toggles** | `ui/settings.gd` | No font scaling, no key rebinding, no reduced-motion. Cheap to add, and a demo page usually gets asked. |
| 5b | **The display baseline is 1600×900 and Settings only offers fullscreen** | `project.godot` `[display]`; `ui/settings.gd` | On a 1366×768 laptop panel the UI is scaled down or clipped; test it there before shipping, and consider a window-size choice next to fullscreen. |
| 6 | **English strings are inline in `.gd`** | ~1,500 literals across `scripts/ui`, `campaign`, `data` | Not a launch blocker; a launch *regret*. `tr()` keys are far cheaper to introduce now than after 1.3.0. |
| 7 | **No measured performance budget** | `tests/perf.gd` prints where time goes; nothing asserts | Largest map is 20v20 in the city sim. Capture the numbers at release so 1.4.0 can be held to them. |
| 8 | **Repo hygiene** *(resolved)* | Unrelated noir-prose `.md` files, `series.json`, `style_lint.py`, `test_style_lint.py`, `README (1).md`, `README (2).md`, stray `download`, and `Arena Protocols/` have been removed from the repository root | Only `The Violence` project files remain in the repository root. |

---

## 5. The order to do the work

### Phase 0 — Make the branch true (days, not weeks) — *partly done, §7*

```sh
tools/run_tests.sh --check                 # every script loads
tools/run_tests.sh --quick                 # 11 gates
godot --headless --path . -s res://tests/determinism_test.gd -- --verbose
godot --headless --path . -s res://tests/determinism_test.gd -- --write   # only after reviewing each mismatch
tools/run_tests.sh --full
tools/run_tests.sh --soak                  # fills the 11 balance cells
```

Rules for this phase: fix forward, do not regenerate the fixture to hide a
difference — each changed digest should be explained by Q1/Q6/Q4 and nothing
else. Record the filled balance table in `CHANGELOG.md`, then delete the
"pending first run" language from every file that carries it.

### Phase 1 — Make the branch stay true (one week)

1. Give the 15 diagnostics an exit code (`quit(1 if failures > 0 else 0)`); then delete the log-scanning fallback from the runner.
2. Move `tools/ci/ci.yml` to `.github/workflows/ci.yml` (or reconnect GitHub with workflow scope) and get it green on both engines; make the full tier required on `main`.
3. Bump to **1.3.0** in `scripts/version.gd`, run `python3 tools/sync_version.py`, commit all three files.
4. Add `LICENSE`, `THIRD_PARTY_NOTICES`, and confirm the Remotion position.
5. ~~Move the prose corpus and the duplicate READMEs out of the game root; delete `download`.~~ *(Done — removed from repo root along with `Arena Protocols/`.)*
6. Decide the cutscene question: wire the ten unwired shorts, or exclude `assets/cutscenes/shorts` from the export preset.

### Phase 2 — Make it shippable (two to three weeks)

7. Rebuild the Windows exe from this tree with official templates; verify the pack with `tools/inspect_pck.py --verify` and the PE with `tools/inspect_exe.py`.
8. **Test on real Windows hardware.** This has never been done — `RELEASE.md` is explicit about it. Boot, play a week, save, reload, alt-tab, resize, quit.
9. Code-sign, or publish through a storefront that carries the warning for you, and say on the page what SmartScreen will show.
10. Produce store assets from what already exists: `tools/make_ads.py` cuts deterministic trailers from the game itself with `--soundlog` + `tools/mix_soundtrack.py`; `tools/ad_card.gd` draws title cards in the game's own hand. Screenshot hooks already exist (`--front=manual|settings|credits|pause`, `--shot=`, `--ops`).
11. Decide the price/positioning. The project calls itself a *vertical slice* in `project.godot`; a free or low-cost demo on itch.io is the honest framing for 12 maps and 40 weeks, with 1.4.0 aimed at the paid release.

### Phase 3 — Release mechanics

12. Release notes from `CHANGELOG.md`; publish SHA-256; attach the exe to a GitHub Release (it cannot live in the tree — `release/*` is ignored for exactly this reason).
13. Post-release: a crash/bug path that does not require GitHub literacy (a `user://logs/godot.log` note on the credits page is enough for v1).
14. Keep the soak tier running on `main` weekly so the balance bands cannot rot unnoticed.

---

## 6. What this pass changed

| File | Change |
| --- | --- |
| `scripts/ui/front.gd` | Manual repaired: two duplicate "Afterwards" pages merged into one, the doubled "Planning an operation" paragraph de-duplicated, the order list now names all nine constraints including **Less-lethal first**, and the contact-aware fast-forward note moved to the debrief page where it belongs. 9 pages → 8. |
| `tools/run_tests.sh` | New. Tiered headless runner (`--check/--quick/--full/--soak/--list`), per-suite logs in `build/test-logs/`, timeouts, exit codes, and log scanning for the harnesses that cannot fail a build. |
| `tools/ci/ci.yml` | New. Static audit + version-sync check, quick tier on Godot 4.7.2 **and** 4.4.1, full tier on `main` and on demand, logs uploaded on failure. This working session's GitHub app cannot create files under `.github/workflows/`, so it ships one directory over: `mkdir -p .github/workflows && git mv tools/ci/ci.yml .github/workflows/ci.yml` activates it, and nothing inside refers to the path. |
| `tools/sync_version.py` | New `--check` mode: reports version drift between `scripts/version.gd`, `project.godot` and `export_presets.cfg` and exits 1, without rewriting. Rejects unknown arguments. |
| `README.md` | Headless-checks section now leads with the runner and the tiers; the individual commands stay for debugging. |
| `scripts/campaign/department.gd` | Two boot-path defects found by the first engine run and fixed: `Equipment.normalize()` was handed `null` for a save with `"kit": null`; `payroll()` indexed `status` on records that had lost it. `_fix_record` now fills the identity fields a damaged record can lack. |
| `scripts/campaign/politics.gd` | The end-of-campaign summary no longer doubles its nouns ("7 stories stories"); `share()` reads an unknown candidate id as 0.0 instead of raising. |
| `scripts/campaign/story_archive.gd` | Contact ids mapped to candidate ids: Dana Okonjo-Vale's poll share was 0.0% and logged an engine error on every archive page. |
| `tests/godot472_test.gd` | One inverted assertion corrected: a campaign save with no department block is *refused*, not loaded as an empty department. |

Verification of these changes:

- `python3 tools/gd47_check.py` → `118 GDScript files scanned / clean`.
- `bash -n tools/run_tests.sh` → clean; `--list` and `--help` behave; the failure path was exercised by breaking `project.godot`'s version on purpose (`--check` → exit 1, restored).
- Cross-reference audit (a check no tool in the repo performs): all **89 habit IDs** defined in `data/habits.gd` were matched against every `"XXnn"` literal in `scripts/`, and there is **no reference to a habit that does not exist**. The 7 course IDs and the 18 equipment keys used by `Equipment.default_kit()` likewise resolve.
- Everything engine-backed is reported in §7.

---

## 7. Measured on this branch

### The engine was built for this pass

No Godot binary ships in this sandbox and `release-assets.githubusercontent.com`
is outside its network allow-list, so **Godot 4.7.2-stable was compiled from
source here** (codeload tarball; scons; `x11=no wayland=no alsa=no pulseaudio=no
dbus=no udev=no speechd=no fontconfig=no lto=none -j2`; ~46 minutes on two cores,
158 MB, `4.7.2.stable.custom_build`). That makes the rest of this section
measured rather than argued. The build is in `/tmp`, not in the repo.

A real Godot 4.7.2 binary also means the 4.7.2 compatibility pass is now more
than a static claim: the project imports (158 asset steps, 6 s), every script
loads, and the game's headless harnesses run.

### Results

| Suite | Result | Notes |
| --- | --- | --- |
| `_check.gd` | **PASS** | all 118 scripts load on 4.7.2 |
| `improvements_test` | **PASS** | |
| `city_improvements_test` | **PASS** | 6 s |
| `ops_ui_test` | **PASS** | |
| `dept_test` | **PASS** | |
| `save_test` | **PASS** | |
| `story_test` | **PASS** | |
| `politics_test` | **PASS** | |
| `city_link_test` | **PASS** | |
| `godot472_test` | **FAIL → PASS** | 2 real defects, fixed below |
| `orders_test` | **PASS** | 275 s — the `less` gate (n_min 16) is 90% of the quick tier |
| `determinism_test --verbose` | **PASS** | **35 cases, 0 changed, 118 s** |
| `maps_test` | **PASS** | 12 maps, 0 problems |
| `nav_door_test` | **PASS** | **175 doors across 12 maps, 0 problems** — the doorway claims hold on the engine, not just in the Python port |
| `city_test` | **PASS** | 1,903 room paths, 60 cross-city paths, 0 problems |
| `habits_test --strict` | **PASS** | 0 failures |
| `brains_test --n=8` | **PASS** | 0 failures, 82 s |
| `civ_test --n=40` | **PASS** | gate: civilians hit by police, patrol 30 vs police tactical 20 |
| `lethality_test --n=6` | ran | 0.67 officers down, 0.00 killed per operation; 0 police rounds hit police |
| `op_test --weeks=40 --chief=sensible` | ran | 1,000 s: election held (Pell 35%), kept with exactly 4 deficit weeks, 47 operations succeeded / 4 failed / 56 situations unattended, 11 officers killed |

**Two claims in the changelog are now confirmed, and one is refuted:**

- Confirmed: the doorway pass (`line_ok`, `leaf_in_way`, `door_ahead`) is real — `nav_door_test` reports 175 doors and 0 problems on a genuine engine.
- Confirmed: the 4.7.2 source only needed the static audit's conclusions — the tree imports and boots headless.
- **Refuted:** *"the determinism fixture needs a one-time `--write` before the suite is green again."* It does not. All 35 seeded cases reproduce **byte-identically** under the Q1/Q6/Q4 changes. That is worth knowing on its own: the rally reset and the less-lethal order never fire in the fixture's first-week operations, so the new behaviour is currently untested by the determinism net — which is an argument for adding a fixture case that *does* exercise them, not for resetting anything.

### Four defects the run found (all fixed on this branch)

1. **The boot path still threw on a null kit.** `_fix_record` did
   `Equipment.normalize(r.get("kit", default))`; `get()` returns the *null value*
   when the key exists with null, not the default, so a save with `"kit": null`
   raised `Cannot convert argument 1 from Nil to Dictionary` while the game was
   starting (`department.gd:1121`). The fallback immediately after the call was
   correct but too late. Now the argument is checked before the call.
2. **`payroll()` indexed `r["status"]` on records that had lost it**, raising
   `Invalid access to property or key 'status'` on the same boot path
   (`department.gd:293`). `_fix_record` now fills the identity fields a damaged
   record can be missing — `status`, `name`, `rank`, `ech`, the habit arrays, the
   course queue — and payroll reads `status` with a default.
3. **The end-of-campaign summary printed the noun twice**: *"7 stories stories
   reached the papers; 3 lawsuits lawsuits settled; 0 cases cases leaked."* The
   `_n()` helper already pluralises (`"7 stories"`), and the sentence appended
   `" stories"` again (`politics.gd:619`). Only a full 40-week run reaches that
   line, which is why no unit test had ever seen it. Fixed and verified by
   calling `Politics.ending()` directly.

4. **The story archive printed Dana Okonjo-Vale's poll share as 0.0% and logged
   an engine error every time the page opened.** `story_archive.contact_status()`
   passed the archive's contact id `"dana"` straight to `politics.share()`, whose
   poll keys are the candidate ids (`"okonjo"`); the read raised `Invalid access to
   property or key 'dana'` (`story_test` exits 0, so only the log showed it). The
   ids are now mapped, and `share()` reads with a default so an unknown id is 0.0
   rather than an error.

**One test assertion was inverted.** The last failure of `godot472_test` was
`check(ok2, "campaign loads a save with no department block (no throw)")`.
`Campaign.from_data()` returns false there, because `Department.from_data({})`
hits the version guard and refuses. Returning false is the *right* behaviour —
loading a department-less save as an empty department would let the next save
write over the `.bak` and lose the campaign — so the assertion, not the code, was
wrong. It now asserts refusal, with the reasoning written next to it.

### Soak, Balance Matrix & Performance Baseline (Executed in `v0.60`)

All soak and balance suites were executed on Godot `4.7.2-stable` in the `v0.60` pass:

- **`determinism_test.gd -- --verbose` (`1.28–1.31`):** **38/38 PASS** (`113.3 s`) — all 35 baseline cases plus `q1_rally_reset_1001` (`0b7bde31bd0fc4aa`), `q3_statement_integrity_1001` (`faa1459d4939bb0a`), and `q6_less_lethal_first_1001` (`dbd4d2d09a055f57`).
- **`balance_matrix_test.gd -- --gate --min=30` (`1.20`):** **16/16 gated cells PASS** (`0` failures):
  - Houses (5v5 assault vs hold): `regular` **46.7%** (`14/30`, **37.8%** at `68/180`), `police` **63.3%** (`19/30`, **62.2%** at `112/180`), `sof` **80.0%** (`24/30`, **80.6%** at `145/180`).
  - Commercial: `regular` **26.7%**, `police` **33.3%**, `sof` **50.0%**.
  - Multi-room: `regular` **10.0%**, `police` **53.3%**, `sof` **80.0%**.
  - Plaza: `regular` **16.7%**, `police` **36.7%**, `sof` **63.3%**.
  - Cross-echelon (all 12 maps, `36` games each): `sof` attack `regular` **86.1%**, `regular` attack `sof` **2.8%**, `police` attack `regular` **72.2%**.
  - SOF hold-habit regression (`32` games each on `HOLD_MAPS`): no hold habits **81.2%**, `HD16` only **68.8%** (`+12.5` pts), all hold habits **84.4%** (`-3.1` pts) — **PASS**.
- **`equip_test.gd` (`1.27`):** **27/27 items PASS** (`12` runs each way, `385 s`).
- **`lethality_test.gd` (`1.05`):** killed/op **0.40** (`<= 1.20`), down/op **1.25** (`<= 3.00`), friendly-fire/op **0.10** (`<= 0.50`) — **PASS**.
- **`hold_test.gd` (`1.04`):** all 5 echelon pairs **PASS** (`regular/regular` attacker win drops `42% -> 30%`, exchange `1.20 -> 1.25`; `militia/police` `0%` attacker wins, exchange `5.13`).
- **`perf.gd -- --map=11 --na=20 --nb=20 --t=60 --gate` (`1.12`, `1.34`):** `1,549` ticks, **`3.87 ms/tick`** (`<= 16.6 ms` budget, `8.6x` realtime factor; `think 1.92 ms`, `perceive 0.81 ms`, `integrate 0.45 ms`, `teams 0.26 ms`, `recognize 0.14 ms`), static memory **`42.0 MiB`** (`+1.3 MiB` delta) — **PASS**.
- **`stall_test.gd` (`1.15`), `fuzz_test.gd` (`1.11`), `city_sim.gd` (`1.10`), `rig_gallery.gd` (`1.18`):** all **PASS** with exit code `0`.

### One thing to watch in the gates

`civ_test --n=8` **fails** the civilian gate (patrol 1, police 5) and
`civ_test --n=40` **passes** it (patrol 30, police 20). The gate is a pooled
comparison of small counts and is sample-size sensitive; 8 seeded operations is
noise. The default of 40 is the documented size and the runner uses it, but
nobody should lower it to make CI faster without changing what the gate means.


---

## 8. Open questions for the owner

1. **What is the release?** Free itch.io vertical slice, paid Steam launch, or a portfolio build? The answer changes Phases 2–3 more than it changes the code.
2. **Code signing?** ~$100–400/year for an OV certificate (or an EV one to skip SmartScreen reputation), or accept the warning and explain it.
3. **Is the score a design choice or a gap?** "No music" reads one way in a noir piece and another way in a store page.
4. **Do the ten unwired shorts get wired, or cut?** Both are defensible; shipping neither is not.
5. **How much of the Q4/Q1/Q6 behaviour does a player have to perceive?** Some of it (rally reset, statement integrity) is currently invisible; a debrief line each would double its value.
