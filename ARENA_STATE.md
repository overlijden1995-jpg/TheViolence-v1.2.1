# ARENA STATE — The Violence

The session record and the routing state. `Arena Protocols/ARENA.md` is the contract;
this file is what a session reads first and writes last (ARENA.md L0, L12; the router's
flowchart step "Read ARENA_STATE: stage, claims, known red").

```
stage:      10 (0.50) · vertical-slice gate · M1 Foundation work open
phase:      prototype — not a release build
updated:    2026-10-25
contract:   Arena Protocols/ARENA.md v4.0
version:    0.50 (scripts/version.gd; tools/sync_version.py --check green)
```

## 1. Routing

```
MODEL:    Arena.ai Agent Mode session (Arena-hosted coding agent)
          Identity: no entry in the 55-model roster of ARENA_MODEL_ROUTER.md §8 matches
          this session's agent (§2.3 case 3: no basis). Routed provisionally on the
          legacy tier bands of ARENA_README.md §1, and capped at the classes it has
          actually completed:
          TOOL · QA · DOCS · contained fixes.  No grade row is published because none
          has been measured — an invented row would be worse than a provisional one.
ASSIGNED: TOOL (provisional) — ROADMAP M1 test infrastructure, 1.01 · 1.02 · 1.03 ·
          1.06 · 1.07 (give silent harnesses an exit code)
NOT ROUTED, this session or any session without a measured grade:
          SYS (simulation core) · MIGR (save format) · STRUCT (canon/roadmap structure)
          · PERF budgets · balance cells
```

## 2. Verified state of the repo (static audit, 2026-10-25)

Every number below was measured in this tree with `grep`/`python3`, not copied from a
document. Where a document disagreed, the measured number is recorded here and the
document was corrected in the same commit.

| Claim in README / ARENA.md | Measured | Verdict |
|---|---|---|
| 34,458 lines of GDScript in `scripts/` | 34,492 lines in 81 `.gd` files | ✅ |
| 12 tactical maps | `m00`–`m11` in `scripts/maps/` | ✅ |
| 34 equipment items | `WEAPONS` 10 · `OPTICS` 3 · `ARMOUR` 3 · `HEAD` 3 · `GEAR` 15 = 34 | ✅ |
| 89 habit ids | 89 distinct `PF/GD/WD/ED/HD/BH` ids in `scripts/data/habits.gd` | ✅ |
| 36 test harnesses in `tests/` | 36 `.gd` files | ✅ |
| "18 of 34 harnesses cannot exit non-zero" | **20 of 36** before this pass; 15 of 36 after | ❌ → corrected |
| 14 shorts rendered | 14 `.ogv` + manifest entries 1:1 | ✅ |
| "4 of 14 shorts wired" | **5** keys reachable (`s01_week`, `s06_officer_down`, `s09_case`, `s11_election`, `s12_end_of_watch`) | ❌ → corrected |
| Autoloads ≤ 5 (G18) | 0 (no `[autoload]` section) | ✅ |

Files that the Arena documents refer to but that do not exist in the tree:

| Referenced by | Path | Status |
|---|---|---|
| ARENA.md L0/L12, router §2.2 | `ARENA_STATE.md` | **created 2026-10-25** (this file) |
| router header, §10 | `tools/arena_router.py` | missing — the router has a spec but no implementation in the tree |
| router header, §8 | `docs/arena/leaderboard_2026-10-23.csv` | missing — the 55-model roster has no data file |
| ROADMAP 2.01 | `LICENSE` | missing (owner decision, M2) |
| ROADMAP 2.02 | `THIRD_PARTY_NOTICES` | missing (M2) |

## 3. Known red (state a new session must not re-discover)

1. **CI cannot be activated from an agent session.** `tools/ci/ci.yml` is correct and
   valid YAML, and both engine URLs it pins exist
   (`Godot_v4.4.1-stable_linux.x86_64.zip`, `Godot_v4.7.2-stable_linux.x86_64.zip`).
   Moving it to `.github/workflows/ci.yml` fails at push:

   ```
   ! [remote rejected] ... (refusing to allow a GitHub App to create or update
     workflow `.github/workflows/ci.yml` without `workflows` permission)
   ```

   ROADMAP 1.32 therefore needs either a GitHub reconnect that grants the `workflows`
   permission or a workflow created in the GitHub UI. It is not a code problem, and no
   agent session can close it. Until then **no tier runs automatically**, so every
   verification claim in this repo is manual and must say which rung it reached.
2. **No engine binary in the session environment.** `godotengine/*` release downloads
   redirect to `release-assets.githubusercontent.com`, which is outside the network
   allow-list; `tools/run_tests.sh` exits 2 (no binary). Work is capped at **V1**
   (`python3 tools/gd47_check.py`) unless the engine is compiled from source
   (`codeload.github.com` is reachable; a 2-core box needs ~3–4 h).

## 4. Session log

### 2026-10-25 — M1: five silent harnesses now fail a build

**Packet.** ROADMAP 1.01 (`tests/_check.gd`), 1.02 (`civ_test`), 1.03 (`equip_test`),
1.06 (`maps_test`), 1.07 (`nav_door_test`). Class TOOL, rung 2, size M (5 files).

**Change.** Each harness already computed its own pass/fail — a load failure, a
`problems` count, a `passed`/`tests.size()` pair, the patrol-vs-tactical civilian gate —
and then called `quit()` with no argument, which exits 0. The result now becomes the
exit code. No assertion was moved, loosened, or skipped; the log lines are unchanged.
`_check.gd` additionally counts what it loaded and prints `check done: N loaded, M failed`.

`tools/run_tests.sh` detects these suites by scanning their logs as well as by exit
code (`scan` column). That scanning stays: removing it is ROADMAP 1.19, which depends
on all of 1.01–1.18 being done.

**Files.** `tests/_check.gd`, `tests/civ_test.gd`, `tests/equip_test.gd`,
`tests/maps_test.gd`, `tests/nav_door_test.gd`, plus the doc corrections in §2
(`README.md`, `Arena Protocols/ARENA.md` L3, `Arena Protocols/ROADMAP.md`,
`CHANGELOG.md`).

**Verification: static only (no engine in environment).** Reached **V1**:
`python3 tools/gd47_check.py` → 118 files scanned, clean. `tools/run_tests.sh --check`
(V2) could not run: no `godot` on PATH, downloads blocked. The five harnesses were
**not executed**; their new exit paths are unproven until an engine runs them. Nothing
in the changes touches `scripts/`, so the determinism fixture
(`tests/fixtures/determinism.json`, 35 cases) is unaffected.

**Found, not fixed.** The two documentation errors in §2 (harness count, wired-short
count) were corrected where they were stated. ROADMAP 1.32 is blocked per §3.1.

## 5. What comes next

1. **Unblock the gate (human).** Reconnect GitHub with `workflows` permission (or create
   `.github/workflows/ci.yml` in the UI by pasting `tools/ci/ci.yml`). Then ROADMAP 1.32
   closes and 1.33 (require the quick tier on `main`) becomes possible.
2. **Finish the exit-code packet** if an engine is available: 1.04 (`hold`), 1.05
   (`lethality`), 1.08 (`op`), 1.09 (`city_test`), 1.10 (`city_sim`), 1.11 (`fuzz`),
   1.12 (`perf`), 1.13 (`playtest`), 1.14 (`sim_test`), 1.15 (`stall`), 1.16 (`trace`),
   1.17 (`duel_probe`), 1.18 (`rig_gallery`) — same shape as this packet, one file each.
   `tests/gallery.gd` and `tests/teams.gd` are not gates; they need no exit code, and
   the "20 harnesses" count should be read as 20 files, 2 of them tools.
3. **Do not touch** `tests/fixtures/determinism.json`, `scripts/sim/`, or
   `scripts/campaign/save_file.gd` without an engine to run V4.
