# ARENA STATE — The Violence

Canonical session state and routing record per `Arena Protocols/ARENA.md` (§L0, §L1.I10, §L12) and `Arena Protocols/ARENA_MODEL_ROUTER.md` (§2.2, §5, §6 Rule 7).

```text
stage:        10 (0.50) · vertical slice gate (M1 Foundation queued next at 0.55)
phase:        slice / prototype — not a release build
version:      0.50 (scripts/version.gd, project.godot, export_presets.cfg in sync)
updated:      2026-10-25
verification: static only (no engine in environment) — V1
```

---

## 1. Model Router Resolution & Session Assignment

```text
MODEL:    Helpful agent on Arena.ai (Arena.ai Agent Mode uses many different models,
          including, but not limited to, Claude, ChatGPT, Gemini, Grok, Qwen, and Kimi;
          no single underlying model identity from the 55-model table in
          ARENA_MODEL_ROUTER.md §8 is disclosed).
ROUTING:  provisional — ARENA_MODEL_ROUTER.md §2.3 Rule 3 ("No basis at all -> fall
          back to the legacy tier bands from ARENA_README.md §1, verify baseline
          capability via ARENA.md §L7, and cap the session at tasks the verification
          rung supports") + ARENA_README.md §0.2 Rule 1 (explicit in-session instruction
          from the human operator takes top precedence).
STAGE:    10 (0.50) · Vertical slice gate · Allowed classes: QA, BUGREP, DOCS, STRUCT
ASSIGNED: PACKET-DOCS-01 (DOCS/STRUCT, human-operator directed, needs-human-review per I11)
          Edit README.md, secondary README files, and Arena Protocols docs so they no
          longer reference any defunct or non-existent files.
```

---

## 2. Explicit Refusals & Environment Constraints (`ARENA.md` & `ARENA_MODEL_ROUTER.md`)

Following `Arena Protocols/ARENA.md` (§L1, §L2, §L7) and `Arena Protocols/ARENA_MODEL_ROUTER.md` (§2, §4.1, §6, §7), the following categories of work **cannot be executed in this environment** and are explicitly refused rather than fabricated:

1. **Refusal of Engine-Gated Code, Simulation, Balance, and Migration Packets (`V2–V5`):**
   - **Boot check result:** `bash tools/run_tests.sh --check` exited with code `2` (`run_tests: no Godot binary named 'godot' on PATH`).
   - **Network constraint:** Outbound access in this sandbox is restricted to `github.com`, `codeload.github.com`, `api.github.com`, `registry.npmjs.org`, `pypi.org`, and `files.pythonhosted.org`. Prebuilt Godot 4.4.1 / 4.7.2 release archives redirect to `release-assets.githubusercontent.com`, which is blocked.
   - **Rule enforcement:** Under `ARENA.md` §L7, having no engine binary caps verification at **V1** (`python3 tools/gd47_check.py` → `verification: static only (no engine in environment)`). Under `ARENA_MODEL_ROUTER.md` §4.1 and `ARENA.md` §L7, every code packet requires at least **V2** (`tools/run_tests.sh --check`), logic changes require **V3** (`--quick`), simulation/determinism (`1.28–1.31`) and save-migration (`5.04`) changes require **V4** (`--full`), and balance-matrix/soak tasks (`1.20–1.27`, `1.34`) require **V5** (`--soak`). Per `I2` (*Never fabricate verification*) and `I8` (*Grade is a ceiling*), unverified GDScript code/simulation/balance changes are refused in this engine-less environment.
2. **Refusal of Live Execution Playtesting (`ARENA_MODEL_ROUTER.md` §7 Fallback Lane) & Windows Hardware Testing (`ROADMAP.md` 1.35, 2.14):**
   - **Rule enforcement:** `ARENA.md` §L1.I12 (*"'Played' requires execution. Static reading is a read-through, not a playtest"*) and `ARENA_README.md` §0 Rule 12 (*"Do not claim to have 'played' unless you executed the game"*) forbid claiming a `smoke`, `loop`, `adversarial`, or `fresh-eyes` playtest without running the game binary. In addition, `release/TheViolence.exe` is git-ignored (not present in `release/`) and this sandbox is a headless Linux container, not a Windows 10/11 desktop.
3. **Refusal of Uninstructed High-Risk `ARCH` / `MIGR` / `STRUCT` Work (`ARENA_MODEL_ROUTER.md` §6 Rules 3 & 8; `ARENA.md` §L2.R4):**
   - **Rule enforcement:** Without an `Optimal` grade row resolved from the 55-model roster and `V4+` runtime verification, high-risk structural, architectural, and save-migration tasks outside the human operator's explicit in-session instruction are refused (`§2.4 Never self-promote`).
4. **Refusal / Block on CI Workflow Activation (`ROADMAP.md` 1.32):**
   - Moving `tools/ci/ci.yml` to `.github/workflows/ci.yml` requires the GitHub `workflows` permission, which is not granted to the sandbox's GitHub App push token.

---

## 3. Boot Baseline & Verification Audit (2026-10-25)

| Check | Command | Result | Rung |
|---|---|---|---|
| Engine declaration | `cat project.godot` | `config/version="0.50"`, `config/features=PackedStringArray("4.4", "4.7")`, `gl_compatibility` | V0 |
| Version sync | `python3 tools/sync_version.py --check` | `version metadata is in sync: 0.50 (Windows 0.50.0)` | V1 |
| GDScript 4.7 static audit | `python3 tools/gd47_check.py` | `118 GDScript files scanned` / `clean` | V1 |
| Writing lane script check | `python3 "Arena Protocols/writing_lane.py" --selftest` | `WRITING LANE OK (game-specific mode)` | V1 |
| Prose linter unit suite | `python3 test_style_lint.py` | `Ran 22 tests in 0.158s — OK` | V1 |
| Headless script load | `bash tools/run_tests.sh --check` | Exit code `2` — no Godot binary in environment | Not run (capped at V1) |

---

## 4. Session Log

### 2026-10-25 — `PACKET-DOCS-01`: Remove defunct file references across READMEs and Arena Protocols

- **Class / Rung / Size:** `DOCS` / `STRUCT` (explicit human-operator instruction per `ARENA_README.md` §0.2 Rule 1; flagged `needs-human-review` per `ARENA.md` §L1.I11) · Rung 2 · Size M.
- **Justification (`I11`):**
  1. `README.md` referenced `.github/workflows/ci.yml` (absent from repo) and listed `Windows build | Exists (88 MiB)` even though `release/TheViolence.exe` is git-ignored (`release/` only contains `release/README.md`).
  2. `README (1).md` and `README (2).md` referenced defunct relative paths (`../05-voice-recipes.md`, `../08-sources-and-glossary.md`, `../data/series.json`, `data/series.json`, `tools/style_lint.py`, `tools/test_style_lint.py`, `tools/samples/chandler-scene.md`, `docs/prose-bible/08-sources-and-glossary.md`) instead of the actual root files (`05-voice-recipes.md`, `08-sources-and-glossary.md`, `series.json`, `style_lint.py`, `test_style_lint.py`, `chandler-scene.md`).
  3. `Arena Protocols/ARENA_MODEL_ROUTER.md` referenced defunct files from the generic Arena router (`docs/arena/leaderboard_2026-10-23.csv`, `docs/arena/capability_matrix.csv`, `docs/arena/leaderboard_YYYY-MM-DD.csv`, `tools/arena_router.py`, `docs/adr/0001-per-model-routing.md`, `PLAYTEST_LOG.md`, `res://data/`) and pre-v4.0 `ARENA_README.md` section numbers (`§0.3`, `§1.4`, `§6`, `§7`, `§8`, `§9`, `§10`, `§13`).
  4. `Arena Protocols/ARENA.md` had stale internal section references (`L17` → `L15`, `verify (L10)` → `verify (L7)`, `L2.R6` → `L2.R5`, `L14` → `L13`), claimed `Windows build | Exists (88 MiB)` for git-ignored `release/TheViolence.exe`, and `Arena Protocols/ARENA_README.md` referenced bare `balance_test.gd` instead of `tests/balance_test.gd`.
  5. `Arena Protocols/ROADMAP.md` referenced non-existent `default_bus_layout.tres` (audio buses are created in `scripts/ui/settings.gd`), `PLAYTEST_LOG.md` (instead of `PLAYTEST_REPORT.md`), and bare `inspect_pck.py` / `inspect_exe.py` (instead of `tools/inspect_pck.py` / `tools/inspect_exe.py`).
  6. `Arena Protocols/writing_lane (1).py` was a defunct duplicate of `Arena Protocols/writing_lane.py`, and `Arena Protocols/writing_lane.py` raised `FileNotFoundError` looking for `docs/arena/leaderboard_2026-10-23.csv`.
- **Files changed:**
  - `README.md`
  - `README (1).md`
  - `README (2).md`
  - `Arena Protocols/ARENA.md`
  - `Arena Protocols/ARENA_README.md`
  - `Arena Protocols/ARENA_MODEL_ROUTER.md`
  - `Arena Protocols/ROADMAP.md`
  - `Arena Protocols/writing_lane.py`
  - `Arena Protocols/writing_lane (1).py` (removed duplicate)
  - `ARENA_STATE.md` (created)
- **Verification:** `verification: static only (no engine in environment)` (Rung **V1**).

### Static Read-Through Observations (`ARENA.md` §L1.I12 — NOT an executed playtest)

- `[content]` Repo root file layout → 35 noir-prose `.md`/`.json`/`.py` files and stray `download` sit alongside Godot project files → Scheduled for relocation/removal in `ROADMAP.md` M2 (2.04–2.10) by an `Optimal`-at-`STRUCT` session (`S3`).
- `[bug]` `tests/` harness exit codes → 18 of 34 runnable `SceneTree` harnesses call `quit()` with no exit code even when they record failures (`_check.gd`, `civ_test.gd`, `equip_test.gd`, `hold_test.gd`, `lethality_test.gd`, `maps_test.gd`, `nav_door_test.gd`, `op_test.gd`, `city_test.gd`, `city_sim.gd`, `fuzz_test.gd`, `perf.gd`, `playtest.gd`, `sim_test.gd`, `stall_test.gd`, `trace.gd`, `duel_probe.gd`, `rig_gallery.gd`) → Tracked in `ROADMAP.md` 1.01–1.18 (`S2`).
- `[content]` `assets/cutscenes/shorts/` → 14 short `.ogv` files exist in `assets/cutscenes/shorts/`, but only 4 (`s06_officer_down`, `s09_case`, `s11_election`, `s12_end_of_watch`) have active gameplay triggers in `scripts/main.gd` and `scripts/ui/ops_ui.gd` → Tracked in `ROADMAP.md` 2.21–2.31 (`S3`).

---

## 5. Handoff (`NEXT`)

```text
NEXT:
(1) Run M1 Foundation TOOL packets 1.01–1.19 (harness non-zero exit codes) in an environment with a Godot 4.4.1 / 4.7.2 binary so V2/V3 (`tools/run_tests.sh --check` and `--quick`) can verify every modified harness.
(2) Activate `.github/workflows/ci.yml` from `tools/ci/ci.yml` (ROADMAP 1.32) using a maintainer account or GitHub integration with `workflows` permission.
(3) Avoid modifying `scripts/sim/`, `tests/fixtures/determinism.json`, or `scripts/campaign/save_file.gd` in any session without a Godot binary capable of running V4 (`tools/run_tests.sh --full`).
```
