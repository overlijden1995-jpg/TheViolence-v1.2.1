# ARENA MODEL ROUTER — task assignment for The Violence

> **Canonical entry point: [`ARENA.md`](ARENA.md).** That file holds the invariants,
> game architecture, test infrastructure, and verification rules specific to The Violence.
> This document covers per-model routing decisions — which models are best suited for
> which classes of work on this specific game.

## 0. How routing works for this game

The Violence is a single-developer Godot project with ~34,000 lines of deterministic
simulation code, 36 test harnesses, and a defined roadmap from v0.50 to v1.0. Routing
is by **task class** and **model capability**, matched against the current milestone's
needs from `ROADMAP.md`.

The routing inputs each session:

```
assignment = route(model_identity, current_milestone_needs, model_capabilities)
```

## 1. Task classes (9, not 16)

Simplified from the generic router. These are the actual work categories for The Violence:

| Class | Risk | Description | Key files |
|---|---|---|---|
| **SYS** | standard | Gameplay system build or repair | `scripts/sim/`, `scripts/campaign/`, `scripts/city/` |
| **DEBUG** | standard | Root-cause debugging, test failures | `tests/`, any script |
| **ARCH** | high | Architecture, refactor, save format changes | `scripts/sim/world.gd`, `scripts/campaign/save_file.gd` |
| **PERF** | standard | Performance profiling and optimization | `tests/perf.gd`, hot paths |
| **UIUX** | standard | UI, menus, accessibility, settings | `scripts/ui/` |
| **ASSETS** | standard | Sprites, audio, video, visual assets | `assets/`, `tools/make_*.py` |
| **NARR** | standard | Briefings, Ledger headlines, manual text, flavor | `scripts/ui/front.gd`, `scripts/campaign/` |
| **TOOL** | standard | CI, test harnesses, build scripts, tooling | `tools/`, `tests/` |
| **QA** | standard | Playtesting, balance verification, bug reports | `tools/run_tests.sh`, game execution |

**High-risk** means: save format changes, simulation core changes (world.gd, brain.gd),
structural roadmap/README changes, determinism-affecting changes. These require
demonstrated competence and V4+ verification.

## 2. The routing algorithm

```
1. Read ROADMAP.md → what milestone is active → what tasks are open
2. Match your model's strengths against the task classes
3. High-risk tasks require models graded Competent or better at that class
4. If no qualifying task exists: FALLBACK = playtest + bug report (always productive)
```

### Grade bands (per class, per model)

| Grade | Meaning | What it licenses |
|---|---|---|
| **Optimal** | Best available for this job | Own the class end-to-end, including high-risk variants |
| **Competent** | Solid, reliable | Own standard packets; may not take high-risk variants alone |
| **Adequate** | Can do it with tight scope | Take narrow, well-specified packets; pair with review |
| **Inadequate** | Do not route this job here | Fallback lane only |

## 3. Model recommendations for The Violence

These recommendations are based on the specific technical requirements of this game:
- Godot 4.4/4.7 GDScript (typed, deterministic)
- Complex simulation with strict determinism requirements
- Large codebase with intricate cross-system dependencies
- Test-driven development with 36 harnesses

### For SYS and ARCH (the hardest work)

The simulation core (`world.gd` at 2000+ lines, the brain hierarchy, the campaign
state machine) requires models with strong multi-file reasoning, Godot 4.x fluency,
and disciplined typing. The determinism constraint makes hallucinated APIs catastrophic.

**Best fit:** Frontier models with strong code arena performance and low hallucination rates.
Models that invent APIs or produce Godot 3.x idioms in a 4.x project are disqualified.

**Red flags:** Models with high tool hallucination rates will invent GDScript methods
that don't exist. The `tools/gd47_check.py` audit catches these at V1, but prevention
is cheaper than detection.

### For DEBUG

The game has 36 test harnesses, 18 of which cannot exit non-zero. Debugging requires
reading large GDScript files, tracing state through the brain hierarchy, and
understanding the evidence chain (incident → finding → IA → politics).

**Best fit:** Models with strong shell reliability and code comprehension.
The ability to run `tools/run_tests.sh` and interpret its output is load-bearing.

### For TOOL

The test infrastructure (`tools/run_tests.sh`, `tools/gd47_check.py`,
`tools/sync_version.py`, `tools/build_windows_exe.sh`) is Python and Bash.
CI activation requires GitHub Actions fluency.

**Best fit:** Models with strong shell reliability and tool-calling accuracy.

### For NARR

The Violence has a specific voice: terse, procedural, police-blotter cadence.
Briefing text reads like an intelligence estimate. The Ledger reads like a
small-city newspaper. The manual reads like a field guide. Models that produce
purple prose, fantasy language, or moral commentary are wrong for this game.

**Key files:** `scripts/ui/front.gd` (the 8-page manual), `scripts/campaign/story.gd`
(press headlines), the 20 noir-prose author files at the repo root (Hammett through
Nesbø) define the voice the game draws from.

**Best fit:** Models that can write in a restrained, procedural register without
embellishment. Political content in the game (the three candidates, the election)
is fictional and satirical — it should read as institutional, not partisan.

### For ASSETS

The game's art is procedurally generated (`tools/make_placeholders.py`,
`tools/make_sounds.py`). The visual style is ink on paper with one red (#B31F26).
New assets must match this palette exactly.

The cinematics pipeline uses Remotion (React-based video composition) → ffmpeg →
Ogg Theora. `cinematics/src/` contains the JSX compositions.

**Best fit:** Models comfortable with procedural art generation and the specific
palette constraint. Visual quality grades are low-confidence (no leaderboard signal).

### For QA

Every model can playtest. The productive fallback lane:
1. Run `tools/run_tests.sh --quick` (or `--full` if time allows)
2. Read the output for failures
3. If an engine is available, run the game and follow the campaign loop
4. Write ≥5 tagged observations and 3 ranked recommendations
5. File every reproducible bug as a separate report

## 4. Routing rules

1. **Grade, not reputation.** An Inadequate grade is a routing fact.
2. **One packet per session.** Exception: two same-class tasks under ~15 min each.
3. **High-risk requires Competent+.** Save format, simulation core, structural changes.
4. **The determinism fixture is sacred.** Any sim change must account for its effect
   on the 35-case fixture. Unexplained fixture changes are process defects.
5. **Stage decides availability.** A task whose class is not in the current milestone
   is not available, however good the model is at it.
6. **Inadequate never means idle.** It means fallback lane: playtest + bug report.
7. **Log the decision.** Every session records model → task → class → verification rung.
8. **Review across families.** When possible, the reviewer of a code change should
   come from a different model family than the implementer.
9. **Test what changed.** Don't re-run the whole soak tier for a one-file fix.
   Run `--quick` always; `--full` for logic changes; `--soak` for balance changes.
10. **Never weaken a test to make it pass.** If a gate fails, fix the game or file
    a design-question. Don't loosen the assertion.

## 5. The fallback lane

When no task in the current milestone rates ≥ Adequate for the model:

1. **Run the test suite** (`tools/run_tests.sh --quick` at minimum)
2. **Static audit** (`python3 tools/gd47_check.py`)
3. **If an engine is available:** play the game for 15–30 minutes
4. **Write ≥5 tagged observations** (bug/confusion/feel/content)
5. **Write 3 ranked recommendations** with why and effort estimate
6. **File every reproducible bug** with steps, expected, actual, severity

This is always productive. The 18 harnesses that can't exit non-zero are a
known gap — a human reading their logs finds defects the automated build misses.

## 6. Dispatch guidance by milestone

| Milestone | Primary classes | Fallback focus |
|---|---|---|
| M1 Foundation (0.50→0.60) | TOOL, SYS, QA | Run soak tier, fill balance cells |
| M2 Production (0.60→0.70) | SYS, UIUX, TOOL, STRUCT | Playtest Windows build, file bugs |
| M3 Experience (0.70→0.80) | ASSETS, UIUX, SYS, QA | Fresh-eyes playtests |
| M4 Depth (0.80→0.90) | SYS, PERF, TOOL, NARR | Extended campaign playtests |
| M5 Release (0.90→1.00) | DOCS, TOOL, STRUCT | Final regression playtests |

## 7. Worked example

```
Session start:
  MODEL: [current model]
  MILESTONE: M1 Foundation (0.50 → 0.60)
  OPEN TASKS: 1.1 (balance matrix), 1.2 (harness exit codes), 1.3 (CI),
              1.4 (determinism cases), 1.5 (chief comparison), 1.6 (Windows test),
              1.7 (Remotion license)

Routing:
  If model is strong at TOOL → Task 1.2 (give harnesses exit codes)
  If model is strong at SYS → Task 1.4 (determinism fixture cases)
  If model is strong at QA → Task 1.1 (run soak, fill balance cells)
  If no match → Fallback: run --soak, report results, file observations
```

## 8. Sources and limits

- Model capabilities assessed from Arena.ai Agent Arena data (October 2026 snapshot)
- Godot-specific competence is not directly measured; the engineering standards in
  ARENA.md §L5 and the verification ladder exist to catch engine-specific errors
- The determinism constraint makes hallucination rates load-bearing: a model that
  invents a GDScript method silently corrupts the fixture
- Visual/audio quality grades are low-confidence priors; treat first deliverables
  as probes, not commitments

---

*The milestone decides what. The model decides who. The test suite decides who was right.*
