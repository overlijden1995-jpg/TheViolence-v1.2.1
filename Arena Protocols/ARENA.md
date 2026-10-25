---
doc: ARENA-AGENT
role: canonical operating contract for AI agents working on The Violence
version: 4.0 · date: 2026-10-25
game: The Violence — police-command & CQB autobattler (Godot 4.4 / 4.7)
repo_version: 0.50 (vertical slice prototype — NOT a release build)
precedence: project.godot > this file > ARENA_MODEL_ROUTER.md > ARENA_CREATIVE_WRITING.md > ARENA_README.md
load_cost: this file only. Expansion docs are optional (L17).
---

# ARENA — The Violence agent contract

Machine contract. Sections are addressable (`L4`, `I7`, `R3`). Cite sections, not prose.

## L0 · Boot (every session, in order)

```bash
cat "Arena Protocols/ROADMAP.md"             # 1 current milestone and path to 1.0
cat project.godot                            # 2 real engine version (4.4 and 4.7 declared)
cat scripts/version.gd                       # 3 canonical version string
python3 tools/gd47_check.py                  # 4 static audit (no engine needed)
bash tools/run_tests.sh --check              # 5 every script loads (needs Godot)
```

Then: identify task → work → verify (L10) → commit on `arena/<slug>` → PR.
**A session with no verification and no recorded outcome did not happen.**

## L1 · Invariants (violating one invalidates the session)

```
I1  Never push to the default branch. Never force-push a shared branch. Branches: arena/<slug>.
I2  Never fabricate verification. Unrun = "not verified". Highest rung reached must be stated.
I3  Never weaken the safety net: no deleted/skipped tests, no loosened assertions, no
    @warning_ignore or empty pass bodies used to hide a failure, no physics tick lowered.
    The determinism fixture (tests/fixtures/determinism.json, 35 cases) must remain
    byte-identical unless the packet explicitly changes simulation behavior.
I4  Never invent an API. No Godot 3.x idiom in this 4.x repo. Unverified method = do not
    write it. Check tools/gd47_check.py output and existing usage before writing new code.
I5  No secrets, tokens, credentials, or personal data anywhere.
I6  No unlicensed asset or code. Every third-party file gets attribution.
I7  Stay inside the packet's declared file scope. Scope creep = stop and amend the packet.
I8  Grade is a ceiling, not a suggestion (L2). Escalate instead of exceeding.
I9  Leave the repo runnable: project loads, tests no worse than the boot baseline, or revert.
I10 Record the session before finishing (L12). Unrecorded = lost.
I11 Roadmap / README / canon / save-format changes are high-risk (L2, L5) — require
    documented justification and explicit human-review flag.
I12 "Played" requires execution. Static reading is a read-through, not a playtest.
I13 Never idle. No qualified task → fallback lane (L2.R6): playtest + bug report.
I14 Engine version: project.godot wins over this document. Record discrepancies.
I15 Two failed attempts at one fix → stop fixing, start documenting, switch task (L14).
I16 The simulation is deterministic. Never use bare randi() in gameplay logic — always
    RandomNumberGenerator seeded from GameState. The 35-case determinism fixture is the
    regression net; any sim change must explain its fixture diff.
```

## L2 · Task routing

The Violence is a single-developer Godot game. Routing is by **capability** and **current milestone need**, not by a 55-model matrix. When choosing work:

```
R1  What does the ROADMAP.md current milestone need most?
R2  Am I capable at this class of work? (code systems, debugging, asset creation,
    narrative text, testing, performance, UI/UX, documentation)
R3  High-risk work (save format, simulation core, structural changes) requires
    demonstrated competence and V3+ verification.
R4  If nothing in the milestone matches my capability: FALLBACK = playtest the current
    build (tools/run_tests.sh --quick), write bug reports, file observations.
R5  One packet per session. Exceptions: two same-class ≤15 min tasks, declared up front.
R6  The task ladder (L8) ranks priority. Rung-1 blockers always come first.
```

**Capability self-assessment** (declare at session start):
- Systems code (campaign, sim, city, nav): high / medium / low
- Debugging (multi-file root cause, test failures): high / medium / low
- Asset creation (sprites, audio, video): high / medium / low
- Narrative/UI text (briefings, Ledger headlines, manual): high / medium / low
- Testing (harness authoring, gate design): high / medium / low
- Performance (profiling, optimization): high / medium / low
- Documentation (README, changelog, protocols): high / medium / low

## L3 · Project state (as of v0.50)

The Violence is a **vertical slice prototype** — not a release candidate. The game has:

| Layer | Status | Evidence |
|---|---|---|
| Core simulation | Strong — 34,458 lines GDScript, deterministic | `scripts/sim/`, 35-case fixture |
| Campaign loop | Strong — 40 weeks, elections, politics | `scripts/campaign/` |
| 12 tactical maps | Complete | `scripts/maps/registry.gd` |
| Test harnesses | 36 files, 18 cannot exit non-zero | `tests/` |
| Animated figures | Complete | `scripts/view/rig.gd` |
| Equipment database | 34 items, measured gates | `scripts/data/equipment.gd` |
| AI brains (4-layer) | Complete, gated | `scripts/sim/brain.gd` |
| Opening cutscenes | 4 films, rendered | `assets/cutscenes/` |
| Short cutscenes | 14 rendered, 4 wired | `scripts/ui/shorts.gd` |
| Windows build | Exists (88 MiB), unsigned, untested on hardware | `release/` |
| Music/score | **Missing** | only SFX + ambience beds |
| Accessibility | **Minimal** (red-ink/gore toggles only) | `scripts/ui/settings.gd` |
| Localization | **Not started** — inline English strings | ~1,500 literals |
| Performance budgets | **Not asserted** | `tests/perf.gd` prints only |
| Balance matrix | **11 cells empty** | `tests/balance_matrix_test.gd` |
| CI pipeline | **Not activated** | `tools/ci/ci.yml` needs move |
| License | **None declared** | no LICENSE file |

## L4 · The game's architecture (know before editing)

```
scripts/
├── main.gd              — application flow, operation playback, replay, cutscenes (1700 lines)
├── version.gd           — single version source (run tools/sync_version.py after changes)
├── ui/
│   ├── ops_ui.gd        — board, planner, debrief, IA, first-operation guide
│   ├── front.gd         — title screen, manual (8 pages), credits, settings
│   ├── city_ui.gd       — endless battle UI
│   ├── cutscene.gd      — opening film player
│   ├── shorts.gd        — interstitial short player (4 of 14 wired)
│   ├── settings.gd      — persistent settings (fullscreen, volume, toggles)
│   └── ui.gd            — shared UI utilities
├── campaign/
│   ├── campaign.gd      — campaign state, week flow
│   ├── situations.gd    — 6 situation types across 6 wards
│   ├── autoplan.gd      — "Suggest a plan" logic (consumes confirmed intel only)
│   ├── orders.gd        — squad objectives and constraints
│   ├── outcome.gd       — scoring arithmetic
│   ├── department.gd    — officers, hiring, training, wounds, morale
│   ├── politics.gd      — allies, trust, polls, election, endings
│   ├── story.gd         — press stories, visibility, landing delay
│   ├── story_archive.gd — the Ledger's back pages
│   ├── operation.gd     — one operation's lifecycle
│   ├── risk.gd          — briefing confidence and chatter
│   └── save_file.gd     — versioned save with temp-then-rename + .bak
├── sim/
│   ├── world.gd         — deterministic simulation core (the largest file)
│   ├── brain.gd         — 4-layer hierarchy (Lizard/Lion/Ape/Wolf)
│   ├── civ_brain.gd     — civilian AI (panic, hide, film, comply)
│   ├── op.gd            — operator state and combat
│   ├── nav.gd           — 0.25m lattice pathfinding with door-aware smoothing
│   ├── geom.gd          — geometry primitives (obstacles, sight, clearance)
│   ├── incident.gd      — round-by-round incident record → findings → evidence
│   ├── level.gd         — map loading
│   ├── pacing.gd        — operation pacing classifiers
│   └── recorder.gd      — replay recording
├── city/
│   ├── city_level.gd    — endless battle level
│   ├── city_nav.gd      — street network, gate-to-gate caching
│   ├── director.gd      — city AI director (gangs, QRF, ambulances)
│   ├── roads.gd         — road generation
│   └── tpl_*.gd         — building templates (hospital, police, school, open)
├── view/                — rendering: plan, actors, overlays, decals, fog, replay
│   ├── rig.gd           — animated figure system (torso, head, arms, legs, weapon)
│   ├── ink.gd           — the one-red palette system
│   ├── overlay.gd       — fog of war
│   └── ...
├── maps/
│   ├── registry.gd      — 12 map definitions
│   └── m00_*.gd–m11_*.gd — individual map geometry
└── data/                — game data resources
    ├── habits.gd        — 89 habit IDs (PF/GD/WD/ED/HD good; BH bad)
    ├── equipment.gd     — 34 items with measured gates
    └── courses.gd       — 7 training courses
```

**Key design constraints:**
- The simulation (`scripts/sim/`) is **fully deterministic** given a seed. Never break this.
- Save format is **versioned** — any save-affecting change needs a migration + test.
- The evidence chain (muzzle flash → finding → IA case → statement → press story → lawsuit → election) is **mechanically connected**, not cosmetic.
- The palette is ink + stepped greys + one red (#B31F26). Red is never a team color.
- The 4 brains (Lizard, Lion, Ape, Wolf) are a hierarchy checked top-to-bottom every tick.
- Officers have persistent careers: habits, trauma, experience, integrity, judgment.

## L5 · Godot standards (load-bearing subset)

```
G1  Typed everything: var x: int, func f(a: int) -> void, Array[Node].
G2  No stringly-typed node access. @onready + %UniqueName or $Child.
G3  Signals up, calls down. Typed signal params. Connect in code, not editor.
G4  _physics_process for motion/collision; _process for presentation only.
G5  Data in scripts/data/ as typed resources; never tuned numbers in logic.
G6  State machines = enum + match. Boolean triangulation is a defect.
G7  Saves: versioned envelope, write-temp-then-rename, ids not node paths.
G8  Input: InputMap actions only; keyboard + gamepad support.
G9  UI: anchors/containers only; Theme resources; focus nav; Escape backs out.
G10 Strings: currently inline (localization debt). Future: tr() with namespaced keys.
G11 2D: the project is top-down, uses draw calls, not TileMap.
G12 Renderer: gl_compatibility (OpenGL 3.3 minimum). No Vulkan-only features.
G13 Perf: <=16.6 ms frame, 60 physics ticks (do not lower to hide jitter).
G14 Audio: named buses (Master, Effects, Ambience); pooled players; no clipped peaks.
G15 Tests: 36 harnesses in tests/. Run with tools/run_tests.sh.
G16 No assert() for gameplay logic (stripped in release); push_error + fallback.
G17 Determinism: seeded RandomNumberGenerator, never bare randi() in gameplay.
G18 Autoloads ≤ 5, dependency-free, one purpose each.
G19 Never await get_tree().create_timer() unguarded after a possible free().
G20 No logic in .tscn scenes; owner set on runtime-built nodes.
```

**Anti-patterns (auto-fail):** Godot 3 idioms · `find_child` per frame · one `_process` orchestrating the game · untyped dict as pseudo-class · copy-paste systems · `:=` inference from untyped receivers (4.7 rejects this) · `# TODO` without a task id.

**4.7-specific hazards** (from the debug pass):
- `:=` from an untyped receiver is a parse error. Always declare the type explicitly.
- `config/features=PackedStringArray("4.4", "4.7")` — both engines are supported.
- `gdscript/warnings/untyped_declaration=1` — the remaining untyped vars stay visible.

## L6 · Test infrastructure

```bash
# Tiers (use the runner, not individual commands):
tools/run_tests.sh --check     # load every script (seconds, no engine needed for gd47_check)
tools/run_tests.sh --quick     # 11 gates a commit should pass
tools/run_tests.sh --full      # + determinism, simulation, campaign, soak
tools/run_tests.sh --soak      # + balance matrix (long, multi-core recommended)

# Static audit (no engine needed):
python3 tools/gd47_check.py

# Version sync check:
python3 tools/sync_version.py --check

# Individual suites (for debugging):
godot --headless --path . -s res://tests/determinism_test.gd -- --verbose
godot --headless --path . -s res://tests/improvements_test.gd
godot --headless --path . -s res://tests/op_test.gd -- --weeks=40 --chief=sensible
```

**Known limitation:** 18 of 34 harnesses always exit 0 regardless of results. The runner scans their logs for failures. The long-term fix is giving every harness a proper exit code.

**The determinism fixture** (`tests/fixtures/determinism.json`): 35 seeded cases, hashed end-states. Any simulation change must either (a) leave all 35 digests identical or (b) explicitly update the fixture with a documented reason per changed case. `--write` resets the baseline; use only in the same commit as the behavior change.

## L7 · Verification ladder

| Rung | Check | Required for |
|---|---|---|
| V0 | Static diff read, no invented API | everyone, always |
| V1 | `python3 tools/gd47_check.py` clean on touched scripts | any code packet |
| V2 | `tools/run_tests.sh --check` passes (headless import/boot) | code packets |
| V3 | `tools/run_tests.sh --quick` ≥ baseline (11 suites) | logic changes |
| V4 | `tools/run_tests.sh --full` (determinism, campaign, brains) | simulation changes |
| V5 | `tools/run_tests.sh --soak` (balance matrix, equipment gates) | balance/perf changes |

No engine binary → capped at V1 (`python3 tools/gd47_check.py`).
Write exactly: `verification: static only (no engine in environment)`.

**Done = artifact-specific:**
- Code change → V2+V3, typed, no new warnings, docstring on public API
- Simulation change → V4 minimum, determinism fixture accounted for
- Save format change → V4 + migration test, save version bumped
- Map → V2, nav_door_test clean for its doors
- Asset → correct import preset + provenance documented
- Narrative text → consistent with existing voice, no contradictions
- Balance change → V5, measured gates documented

## L8 · Task ladder

| Rung | Class | Examples for The Violence |
|---|---|---|
| 1 | **Blockers** | Boot crash, save corruption, unparseable script, test suite regression |
| 2 | **Milestone work** | Current roadmap tasks (see Arena Protocols/ROADMAP.md) |
| 3 | **Quality debt** | Harnesses that can't exit non-zero, empty balance cells, inline strings |
| 4 | **Polish & feel** | Hit-stop, camera feel, UI clarity, audio mix, figure animation polish |
| 5 | **Coverage** | Wire remaining 10 shorts, add music, accessibility, localization |
| 6 | **Discovery** | Playtesting, balance probing, design proposals |

## L9 · Packets

```yaml
PACKET-<id>:
  title: <imperative, <= 72 chars>
  rung: 1..6
  class: SYS|DEBUG|ASSETS|NARR|PERF|UIUX|TOOL|QA|STRUCT
  size: S|M|L           # S <= 1 file <= 30 lines; M <= 5 files; L = split it
  scope: [paths]        # anything outside = stop, amend
  accept: [ ]           # each line machine-checkable or explicitly human-reviewed
  verify: V0..V5        # highest rung reached
  rollback: <revert|flag|migration>
```

## L10 · Playtesting

Types: smoke 5 min · loop 20–40 min · adversarial 15–30 · read-through 15 · soak 30+ · fresh-eyes 15.

Observation format: `[bug|confusion|feel|content] situation → observation → cause hypothesis`.

Severity: `S0` unplayable · `S1` blocks progress · `S2` broken mechanic · `S3` cosmetic · `S4` polish · `design-question` intent unclear.

Every flagged bug = standalone report (steps, expected, actual, evidence, severity, hypothesis separated, build hash).

**Specific things to test in The Violence:**
- Does the briefing → plan → operation → debrief loop read clearly to a new player?
- Do the 4 brain layers produce believable squad behavior?
- Does the evidence chain (findings → IA → press → election) feel consequential?
- Are the 12 maps visually distinct and navigable under fog of war?
- Does the red-ink palette read well at 1366×768?
- Does the 40-week campaign sustain interest and end satisfyingly?

## L11 · Git and PR protocol

Branch `arena/<slug>`. Conventional Commits, imperative, ≤72 char subject.
One logical change per commit. PR body: what / why / verification rung / artifacts / risk+rollback.

Version changes: edit `scripts/version.gd`, then `python3 tools/sync_version.py`, then commit `scripts/version.gd`, `project.godot`, and `export_presets.cfg` together.

## L12 · State and handoff

End every session with:
1. What was done (files changed, verification rung reached)
2. What was found (bugs, observations, design questions)
3. What comes next (max 3 bullets for the next agent)

## L13 · Stop conditions

Stop and escalate when: the change alters design direction · credentials needed · licensing unclear · the repo is red in a way the task cannot isolate · scope would exceed ~2× the declared scope · data loss or save corruption · two fix attempts failed.

## L14 · Agent failure modes (self-check before finishing)

`confident unverified claim` · `API invented from memory` · `scope creep disguised as cleanup` · `test silenced to get green` · `thrashing on one bug` · `determinism fixture reset without explanation` · `simulation change without fixture accounting` · `:= from untyped receiver in 4.7` · `save format change without migration`.

## L15 · Expansion docs (load only if needed)

| File | Load when |
|---|---|
| `ARENA_MODEL_ROUTER.md` | you need per-model routing decisions or worked examples |
| `ARENA_CREATIVE_WRITING.md` | the task involves narrative text, briefings, or Ledger copy |
| `ARENA_README.md` | legacy prose: full tier charters, appendices, templates |
| `ROADMAP.md` | current milestone and path to 1.0 |

## L16 · Changelog

| Date | Change |
|---|---|
| 2026-10-25 | v4.0 — rewritten for The Violence specifically. Removed generic 55-model roster references. Added game architecture map (L4), test infrastructure (L6), project state (L3). Engine version corrected from "4.72" to "4.4/4.7". Stage ladder replaced with milestone-based roadmap reference. |
| 2026-10-25 | v3.1 — consolidation of four documents into one. |

---

*Know the game. Verify your work. Record what you did. Leave the repo runnable.*
