---
doc: ARENA-AGENT
role: canonical operating contract for AI agents working in this repo
version: 3.1 · date: 2026-10-25
engine: godot 4.72  # reconcile against project.godot at boot; the repo wins (L1.I14)
precedence: project.godot > this file > ARENA_MODEL_ROUTER.md > ARENA_CREATIVE_WRITING.md > ARENA_README.md (legacy prose)
roster: Arena Agent Arena 2026-10-23 · 55 models · 16 classes · 20 stages · 4 grades
load_cost: this file only. Expansion docs are optional (L17).
generated: docs/arena/capability_matrix.csv, docs/arena/model_cards.md, docs/arena/writing_censorship.csv
tools: python3 tools/arena_router.py [--selftest|--emit|--audit|--evidence|--stage N --model M]
        python3 tools/writing_lane.py [--emit|--selftest|--report]
---

# ARENA — one file, agent-first

Machine contract. Sections are addressable (`L4`, `I7`, `R3`, `V2`). Cite sections, not prose.
Blocks marked `AUTO` are generated; never hand-edit, `--emit` regenerates them, `--selftest` fails on drift.

## L0 · Boot (every session, in order)

```bash
cat ARENA_STATE.md                     # 1 current truth: phase, claims, baseline, known red
cat ROADMAP.md                         # 2 current milestone
grep -n "config/features" project.godot # 3 real engine version
python3 tools/arena_router.py --selftest # 4 router integrity (must print OK)
python3 tools/writing_lane.py --selftest # 5 writing-lane integrity (must print OK)
python3 tools/arena_router.py --model "<MY MODEL>" --stage <0.05..1.00>   # 6 my decision
```

Then: claim packet → work → verify (L10) → write `ARENA_STATE.md` (L12) → PR (L13).
**A session with no packet, no verification, and no state update did not happen.**

## L1 · Invariants (violating one invalidates the session)

```
I1  Never push to the default branch. Never force-push a shared branch. Branches: arena/<slug>.
I2  Never fabricate verification. Unrun = "not verified". Highest rung reached must be stated.
I3  Never weaken the safety net: no deleted/skipped tests, no loosened assertions, no
    @warning_ignore or empty pass bodies used to hide a failure, no physics tick lowered.
I4  Never invent an API. No Godot 3.x idiom in a 4.x repo. Unverified method = do not write it.
I5  No secrets, tokens, credentials, or personal data anywhere.
I6  No unlicensed asset or code. Every third-party file gets an ASSET_CREDITS.md row.
I7  Stay inside the packet's declared file scope. Scope creep = stop and amend the packet.
I8  Grade is a ceiling, not a suggestion (L2). Escalate instead of exceeding.
I9  Leave the repo runnable: project loads, tests no worse than the boot baseline, or revert.
I10 Record the session before finishing (L12). Unrecorded = lost.
I11 Roadmap / README / canon / save-format changes are Optimal-at-STRUCT only (L2, L5).
I12 "Played" requires execution. Static reading is a read-through, not a playtest.
I13 Never idle. No qualified task → fallback lane (L2.R6), always productive.
I14 Engine version: project.godot wins over this document. Record the discrepancy; never
    "upgrade" a repo to match a doc.
I15 Two failed attempts at one fix → stop fixing, start documenting, switch packet (L14).
I16 Political, religious or real-world-faction narrative never goes to a Steered model (L7).
```

## L2 · Routing algorithm

Inputs: `MODEL` (exact roster name), `STAGE` (0.05–1.00), `TASK QUEUE`, `ALLOWED CLASSES = stage.order`.

```
R1  grades = model.grades[16] (+ session overrides from ARENA_STATE.md "Grade overrides")
R2  candidates = tasks where cls ∈ stage.order
R3  reject cls if grade < Adequate                  -> "grade X < Adequate"
R4  reject cls if class.risk == high and grade != Optimal -> "high-risk needs Optimal"
R5  pick max (grade, stage.order index of cls, rung); tie-break MUST use stage order,
    never class name (name-sorting mis-routes silently; guarded by --selftest)
R6  if nothing survives: FALLBACK = QA + BUGREP playtest/suggestion session (floored Adequate)
R7  overrides: ARENA_STATE.md wins over the CSV; 2 independent contradicting sessions move a
    grade; one session is an anecdote. Never override STRUCT or MIGR upward without an
    Optimal grader's review.
```

**Grades** = within-class percentile of a weighted composite over 55 models.
`Optimal ≥ .90 · Competent ≥ .65 · Adequate ≥ .25 · Inadequate < .25`.
Grades are **relative**: `Inadequate` = bottom of this field, not unusable.

**Gates** (applied after banding, can only lower a grade):

| Condition | Classes | Effect |
|---|---|---|
| hallucination delta ≤ −5.0 | TOOL DEBUG MIGR SYS ARCH STRUCT | → Inadequate |
| hallucination delta ≤ −2.0 | same | clamp Adequate |
| shell reliability < +1.5 | TOOL DEBUG | clamp Adequate |
| steerability < +0.6 | ARCH STRUCT | clamp Competent |
| cost/task > $5.00 | ASSETS QA | clamp Adequate |
| — | QA BUGREP | floor Adequate (nobody is useless at QA) |

**Fallback pressure** (models with no qualifying task, stages 1–20): `8 15 3 11 8 11 15 11 2 15 5 3 12 11 13 13 15 11 8 8` of 55.
Broad content stages route nearly everyone; narrow gate stages (2, 7, 10, 17) push 15 models to the fallback lane — book playtest capacity there.

## L3 · Stage ladder (20 increments)

`AUTO` · format `Snn,progress,phase,name,classes,gate`

<!-- BEGIN AUTO:arena-stages -->
```text
S,progress,phase,name,classes,gate
S01,0.05,prototype,Bootstrap & repo truth,STRUCT|DOCS|TOOL|QA,"Repo imports clean, ROADMAP.md + ARENA_STATE.md exist and are accurate."
S02,0.10,prototype,Core loop decision,ARCH|STRUCT|NARR,"Core loop written down, one ADR, no code committed that assumes otherwise."
S03,0.15,prototype,Playable skeleton,SYS|ARCH|ASSETS|DEBUG,"Main scene boots; one player verb works end to end."
S04,0.20,prototype,First full loop,SYS|DEBUG|FEEL,"Start -> fail/win without developer intervention."
S05,0.25,prototype,Data-driven foundations,ARCH|SYS|TOOL,"Tunable values live in res://data/ and load through typed resources."
S06,0.30,prototype,Feel pass 1,FEEL|QA|DEBUG,"Movement/camera/input survive a loop playtest without notes about 'lag'."
S07,0.35,slice,Slice scope lock,STRUCT|NARR,"Vertical-slice content list is frozen and packet-ised."
S08,0.40,slice,Slice systems complete,SYS|UIUX|DEBUG,"Every slice system works with placeholder content."
S09,0.45,slice,Slice content pass,ASSETS|ASSETX|NARR,"No beat of the slice is still placeholder-only."
S10,0.50,slice,Vertical slice gate,QA|BUGREP|DOCS|STRUCT,"Fresh-eyes playtest reaches the end unaided; S0/S1 list is empty."
S11,0.55,production,Production pipeline,TOOL|ARCH|ASSETS,"A new asset or system can be added repeatably from documented steps."
S12,0.60,production,Content scale-up,ASSETS|NARR|SYS,"Content count tracks the roadmap's milestone table."
S13,0.65,production,Narrative volume,NARR|DOCS|UIUX,"All shipped content is written, canon-consistent and localisation-ready."
S14,0.70,production,Systems hardening,DEBUG|PERF|MIGR,"No known S1 open; perf within budget; saves round-trip."
S15,0.75,polish,Feature complete,FEEL|UIUX|QA,"Feature freeze declared; tuning signed off by a playtest pass."
S16,0.80,polish,Polish & accessibility,UIUX|FEEL|AUDIO,"Contrast, focus navigation, subtitles and UI scale all verified."
S17,0.85,polish,Bug triage sweep,BUGREP|DEBUG|QA,"Every open report has a severity, a repro and an owner."
S18,0.90,hardening,Performance & memory,PERF|DEBUG,"Frame/memory budgets met over a 30-minute soak."
S19,0.95,hardening,Release hardening,MIGR|DOCS|TOOL|QA|STRUCT,"Save migration tested on old saves; build reproducible from CI."
S20,1.00,release,Ship,MIGR|DOCS|TOOL|QA|STRUCT,"Release checklist complete; final playtest logged; tags cut."
```
<!-- END AUTO:arena-stages -->

Snap rule: `stage_for(p)` = nearest stage at or below `p`. `0.57 → S11`. `0.00 → S01`.

## L4 · Job classes (16)

`AUTO` · weights are the composite inputs (`overall/code/chat/work` = board ranks; `success/praise/steer/bash/hallu` = signal percentiles; `cost/time` = inverted percentiles)

<!-- BEGIN AUTO:arena-classes -->
```text
code,risk,confidence,weights,name
ARCH,high,high,code=0.45;steer=0.30;success=0.15;hallu=0.10,"Architecture, refactor & structural change"
SYS,standard,high,code=0.45;success=0.30;hallu=0.15;steer=0.10,"Gameplay system build or repair"
DEBUG,standard,high,bash=0.35;code=0.30;hallu=0.20;success=0.15,"Root-cause debugging"
MIGR,high,high,success=0.35;steer=0.30;code=0.20;hallu=0.15,"Save-format & data migration"
TOOL,standard,high,bash=0.50;hallu=0.30;code=0.20,"Tooling, CI, import pipeline & shell work"
PERF,standard,high,code=0.40;bash=0.25;success=0.25;overall=0.10,"Performance profiling & optimization"
FEEL,standard,medium,success=0.30;praise=0.25;steer=0.25;overall=0.20,"Gameplay tuning, balance & game feel"
UIUX,standard,medium,code=0.35;steer=0.30;chat=0.20;success=0.15,"UI, HUD, menus & accessibility"
ASSETX,standard,low,code=0.40;steer=0.25;chat=0.20;success=0.15,"Complex asset creation (rigs, tilesets, shaders, kits)"
ASSETS,standard,low,cost=0.35;time=0.25;code=0.25;success=0.15,"Simple asset creation & placeholder replacement"
NARR,standard,medium,chat=0.50;work=0.20;praise=0.20;success=0.10,"Narrative, worldbuilding, dialog & copy"
DOCS,standard,medium,work=0.50;chat=0.20;steer=0.20;success=0.10,"Docs, changelogs & canon upkeep"
STRUCT,high,high,work=0.35;steer=0.30;overall=0.20;success=0.15,"Structural roadmap/README/design change"
QA,standard,medium,cost=0.35;time=0.35;success=0.15;praise=0.15,"Playtesting & first-impression feedback"
BUGREP,standard,high,chat=0.30;work=0.20;success=0.30;code=0.20,"Bug reproduction, triage & suggestions"
AUDIO,standard,low,code=0.35;chat=0.25;steer=0.20;success=0.20,"Audio integration & mixing"
```
<!-- END AUTO:arena-classes -->

Class confidence is load-bearing: `low` = no direct signal on the Agent board (prior only).
`ASSETX ASSETS AUDIO` are low; `FEEL UIUX NARR DOCS QA` medium; rest high.

## L5 · Model index (55)

`AUTO` · grade letter order: `ARCH SYS DEBUG MIGR TOOL PERF FEEL UIUX ASSETX ASSETS NARR DOCS STRUCT QA BUGREP AUDIO`
`O`ptimal `C`ompetent `A`dequate `I`nadequate · `ev:` = grade moved by outside evidence (L6) · `wr:` = writing-lane censorship level (L7)

<!-- BEGIN AUTO:arena-index -->
```text
rank|model|lab|ARCH SYS DEBUG MIGR TOOL PERF FEEL UIUX ASSETX ASSETS NARR DOCS STRUCT QA BUGREP AUDIO|flags
01|Claude Opus 5.5 (Max)|Anthropic|OOOOOOOCOIOOOAOO|ev:UIUX,wr:Light
02|Claude Sonnet 5.5 (Max)|Anthropic|OOOOOOOOOIOOOAOO|wr:Light
03|GPT-6 Astra (Max)|OpenAI|OOOOCOOOOAOOOAOO|wr:Light
04|Claude Fable 5.1 (Max)|Anthropic|OOOOCOOOOAOOOAOO|wr:Light
05|GPT-6.1 Sol (Max)|OpenAI|OOCOCCOOOCOOOAOO|wr:Light
06|Gemini 4 Argon (High)|Google|CCCOACOOOCOOOAOO|wr:Moderate
07|Muse Wonder Full (Max)|Meta|OCCCCOCCCCCCCACC|no-api,wr:Light
08|GPT-6 Sol (Max)|OpenAI|COOCOOCCCCCCCACC|wr:Light
09|Claude Opus 5 (Max)|Anthropic|CCOCOCCCCICCCACC|wr:Light
10|Claude Fable 5 (High)|Anthropic|CCCCOCCCCACCCACC|wr:Light
11|Kimi K3.1 Pro (Max)|Moonshot|OCCCOCCCOACCCACC|thin,prelim,ev:ARCH/TOOL/ASSETX,wr:Steered
12|GPT-5.6 Sol (xHigh)|OpenAI|CCCCOCCCCACCCACC|wr:Light
13|DeepSeek-V4.1-Flash-20261017 (Max)|DeepSeek|CCCCACCCCOCCCCCC|wr:Heavy
14|Claude Sonnet 5 (High)|Anthropic|CACACCCCCAACCAAC|wr:Light
15|Muse Wonder (Max)|Meta|CCCCCCCCCACCCACC|wr:Light
16|MiMo-V2.6-Pro|Xiaomi|AAACACCCCCCCCACC|wr:Steered
17|Gemini 3.8 Flash (High)|Google|AAAACAAAAACAAACA|wr:Moderate
18|Muse Spark 1.3 (Max)|Meta|CCACACCCCCCCCCCC|wr:Light
19|Grok 4.7 (xHigh)|SpaceXAI|ACCCCCCCCICCAACC|wr:Open
20|GPT-6 Luna (Max)|OpenAI|CACACCACCOACCOAC|cheap$0.08,wr:Light
21|DeepSeek-V4.1-Flash-20260910 (Max)|DeepSeek|AAAAAAAAAOAAAOCA|wr:Heavy
22|MiMo-V2.6-Flash|Xiaomi|CCACAACAACAACCAA|cheap$0.06,wr:Steered
23|Hy4 preview|Tencent|AAAAAAAAAACAAAAA|wr:Steered
24|GLM-5.2 (Max)|Z.ai|ACCACAAAAIAAAAAA|wr:Steered
25|Kimi K3 (Max)|Moonshot|AAAAAAAAAIAAAAAA|wr:Steered
26|GLM-5.3 (Max)|Z.ai|AAAAAAAAAIAAAAAA|wr:Steered
27|Claude Haiku 5.5 (High)|Anthropic|CCCCCAAAAOAAAOAA|cheap$0.10,wr:Light
28|Qwen3.8-Max|Alibaba|AAAAAAACAIAAAAAA|ev:UIUX,wr:Steered
29|Grok 4.6 (xHigh)|SpaceXAI|AAAACAAAAIAAAAAA|wr:Open
30|GPT-5.6 Terra (xHigh)|OpenAI|AAAAAAAAACAAACAA|wr:Light
31|DeepSeek-V4-Pro (High 20260813)|DeepSeek|AAAAAAAAAAAAAAAA|wr:Heavy
32|GPT-6 Luna (Medium)|OpenAI|AAAAAAAAAOAAAOAA|cheap$0.02,wr:Light
33|Gemini 3.7 Flash (High)|Google|AAAAIAAAAIAAAAAA|wr:Moderate
34|GLM-5.3-Flash|Z.ai|AAIAIAAAACAAAAAA|wr:Steered
35|Step 5 Preview|StepFun|AAAAIAAAAIAAAAAA|wr:Moderate
36|MiniMax-M3.1-Flash|MiniMax|AAAAAAAAAAAAAAAA|prelim,wr:Moderate
37|Beam 1.0 501B A23B|Reflection|AAIAIAAAAAAAACAA|wr:Light
38|Qwen3.8-Flash-Next|Alibaba|AAIAIAAAAAAAAAAA|wr:Steered
39|Qwen3.8-27B|Alibaba|AAAAIAAAAAIAAAAA|wr:Steered
40|Gemini 3.1 Pro Preview|Google|IIAIAIAIIAAIIAAI|wr:Moderate
41|GPT-6 Luna (Low)|OpenAI|AAAAAAIAAOIAAOAA|cheap$0.01,wr:Light
42|Mistral Large 4|Mistral|IIIIIAAAAIIIIAAA|ev:DOCS/NARR,wr:Open
43|Qwen3.7-Max|Alibaba|IIAIAIIIICIIICAI|wr:Steered
44|Hy3|Tencent|IIIIIIIIICIIIOAI|cheap$0.07,wr:Steered
45|Muse Spark 1.1|Meta|IIAIAIIIIAAIICAI|wr:Light
46|Muse Spark 1.2 (xHigh)|Meta|IIIIAIIIIAIIIAAI|wr:Light
47|Qwen3.7-Plus|Alibaba|IIIIIIIIIAIIICAI|wr:Steered
48|MiMo-V2.5-Pro|Xiaomi|IIIIAIIIIAIIICAI|cheap$0.07,wr:Steered
49|MiniMax-M3|MiniMax|IIIIAIIIICIIICAI|wr:Moderate
50|Mistral Medium 3.5|Mistral|IIIIIIIIIIIIIAAI|wr:Open
51|NVIDIA-Nemotron-3.5-Super-VL-120B-A12B (NVFP4)|Nvidia|IIIIIIIIIIIIIAAI|wr:Light
52|Nemotron 3 Ultra|Nvidia|IIIIIIIIIAIIICAI|cheap$0.10,wr:Light
53|Inkling|Thinking Machines|IIIIAIIIIAIIIAAI|wr:Light
54|Inkling-Small|Thinking Machines|IIIIIIIIIAIIICAI|wr:Light
55|Solar Pro 4|Upstage|IIIIIIIIICIIICAI|cheap$0.05,wr:Light
```
<!-- END AUTO:arena-index -->

## L6 · Evidence layer

Vendor self-assessment and community evidence may move a grade, under rules enforced in code:

- ≥ 2 independent sources; a vendor **ranking** never raises a grade, a vendor **caveat** may.
- Max **one level** of raise. Leaderboard-computed grade is retained in `Model.computed`.
- Every correction carries an `asof` date and is printed by `--evidence`; retire by deleting its row.
- Current corrections (7 cells, 2026-10-25): Opus 5.5 `UIUX` O→C · Kimi K3.1 Pro `ARCH TOOL ASSETX` C→O · Mistral Large 4 `DOCS NARR` A→I · Qwen3.8-Max `UIUX` A→C.
- Not dispatchable: **Muse Wonder Full (Max)** — Muse Code subscription only, no public API. Never write a packet for it.
- Known validity threat: **effort level is not modeled.** Same model at max vs xhigh differs by 5–9 benchmark points. Prefer matched-effort evidence; never compare a max-effort row to an xhigh row.

## L7 · Writing lane (NARR / DOCS / lore)

Two axes, never collapsed: **can it write** (`NARR` grade) × **will it write this** (censorship level).
Levels ordered by cost: `Open < Light < Moderate < Steered < Heavy`. Steered is worse than Heavy: refusal is loud and reroutable, steering is silent and ships as canon.

```
W1  Scene tag every NARR packet: mature | political | neutral.
W2  political -> only Open / Light / Moderate models. Never Steered, never Heavy.
W3  mature    -> route on the mature sub-axis, not the headline level.
W4  Every NARR packet names a second writer from a different posture (Light primary -> Open
    understudy; Open primary -> Light reviewer from a different family).
W5  Refusal probe before the packet (3 prompts: violence / intimacy / politics). Log to
    ARENA_STATE.md "## Refusal probe": model · stage · V: · I: · P: · date.
W6  Retry once before calling a refusal (wrapper filters are stochastic).
W7  P:shifted is a failure even when the prose reads well. Discard, do not commit.
W8  Do not abliterate weights to bypass a refusal: it trades a visible failure for
    invisible confabulation (Qwen3 class: 72% after ablation).
W9  Refusal % is NOT a censorship metric (all roster models: 0.0–1.9% on generic fiction).
    Probe topics, not rates.
```

Cells: **13 writers of record** (NARR ≥ C, Open/Light) · **6 under escort** (NARR ≥ C, leashed: Gemini 4 Argon, Kimi K3.1 Pro, DeepSeek 1017, MiMo-V2.6-Pro, Gemini 3.8 Flash, Hy4) · **17 draft labor** · **19 do not assign prose**. Full list: `ARENA_CREATIVE_WRITING.md`.

## L8 · Packets and the task ladder

```yaml
PACKET-<id>:
  title: <imperative, <= 72 chars>
  rung: 1..6            # L8 table
  class: ARCH|SYS|DEBUG|MIGR|TOOL|PERF|FEEL|UIUX|ASSETX|ASSETS|NARR|DOCS|STRUCT|QA|BUGREP|AUDIO
  stage: 0.05..1.00     # must be the current increment
  model: <exact roster name>   # and its grade
  size: S|M|L           # S <= 1 file <= 30 lines; M <= 5 files; L = split it
  scope: [paths]        # anything outside = stop, amend
  accept: [ ]           # each line machine-checkable or explicitly human-reviewed
  verify: V0..V5        # highest rung you will reach
  rollback: <revert|flag|migration>
```

| Rung | Class | Owner |
|---|---|---|
| 1 | Blockers: does not run, data loss, crash, softlock | any Optimal at the class, always first |
| 2 | Current milestone work | per matrix |
| 3 | Quality debt: known-red, perf cliff, a11y gap | Competent+ |
| 4 | Polish and feel | Competent+ |
| 5 | Coverage: narrative/asset/audio/docs gaps | Adequate+ |
| 6 | Discovery: playtest, spike, proposal | fallback lane |

Rung-6 work may **generate** a rung-1 packet; it may never **become** one. One packet per session (exception: two same-class ≤15 min packets, declared at claim).

## L9 · Godot 4.72 standards (load-bearing subset)

```
G1  Typed everything: var x: int, func f(a: int) -> void, Array[Node], Dictionary[K,V].
G2  No stringly-typed node access. @onready + %UniqueName or $Child. No ../../ paths in hot code.
G3  Signals up, calls down. Typed signal params. Connect in code, not in the editor.
G4  _physics_process for motion/collision; _process for presentation only. Never both per system.
G5  Data in res://data/ as typed Resource/.json; never tuned numbers in scripts.
G6  State machines = enum + match or State nodes. Boolean triangulation is a defect.
G7  Saves: versioned envelope, write-temp-then-rename, ids not node paths, migration + test.
G8  Input: InputMap actions only; read intent once per frame; keyboard+gamepad+rebinding.
G9  UI: anchors/containers only; Theme resources, no hex in scenes; focus nav; Escape backs out.
G10 Strings through tr() with namespaced keys (quest.innkeeper.intro). No sentence concatenation.
G11 2D: TileMapLayer (not TileMap), named layers, documented filter (Nearest|Linear), one stretch mode.
G12 3D: 1 unit = 1 m, verify props against 1.8 m, origin at floor center, forward −Z.
G13 Perf: <=16.6 ms frame (<=8 mobile), 60 physics ticks, monitor-verified not vibed.
G14 Audio: named buses + manager-driven transitions + pooled players; no clipped peaks.
G15 Tests: GUT or gdUnit4 (repo's existing one). Cover save round-trip, formulas, state machines.
G16 No assert() for gameplay logic (stripped in release); push_error + defined fallback.
G17 Determinism: seeded RandomNumberGenerator from GameState, never bare randi().
G18 Autoloads <= 5, dependency-free, one documented purpose each.
G19 Never await get_tree().create_timer() unguarded after a possible free(); check is_instance_valid.
G20 A .tscn diff must be readable; no logic in scenes; owner set on runtime-built nodes.
```

Anti-patterns (auto-fail): Godot 3 idioms · `find_child` per frame · one `_process` orchestrating the game · autoload as global variable dump · untyped dict as pseudo-class · copy-paste systems · committed assets with wrong preset/scale/provenance · hand-merged `.tscn` without reopening · silencing warnings · `# TODO` without a packet id.

## L10 · Verification ladder

| Rung | Check | Required for |
|---|---|---|
| V0 | static diff read, no invented API | everyone, always |
| V1 | `--check-only` parse on touched scripts | any code packet |
| V2 | headless import/boot, no new errors | code packets; always if a binary exists |
| V3 | test suite ≥ baseline (baseline recorded at boot) | logic changes |
| V4 | playtest of the changed path with logs/screenshots | feel/system integration |
| V5 | soak + perf budget + save-migration round trip | releases, save changes, perf |

No engine binary → capped at V1, write exactly: `verification: static only (no engine in environment)`.
Pre-existing red → record it, do not fix outside a packet, compare after: `pre-existing failure in test_x.gd:41, unchanged`.

**Done = artifact-specific:** code → V2+V3, typed, no new warnings · system → code DoD + test + DESIGN.md + follow-up packet · scene → imports, runs from main_scene, no missing resources, no orphan nodes · asset → correct preset/scale + ASSET_CREDITS row + inspected at game scale · narrative → canon-consistent, glossary row, tr(), voice sample matched · bug → steps/expected/actual/evidence/severity/hypothesis-separated · playtest → ≥5 tagged observations + 3 ranked recommendations · STRUCT change → ADR + changelog + `needs-human-review`.

## L11 · Playtesting

Types: smoke 5 min · loop 20–40 · adversarial 15–30 · read-through 15 (labeled as such) · soak 30+ · fresh-eyes 15 (zero context).
Observation format: `[bug|confusion|feel|content] situation → observation → cause hypothesis`.
Severity: `S0` unplayable/data loss · `S1` blocks progress · `S2` broken mechanic · `S3` cosmetic · `S4` polish · `design-question` intent unclear.
Every flagged bug = standalone report (steps, expected, actual, evidence, severity, separated hypothesis, build hash).

## L12 · State and handoff

Rewrite `ARENA_STATE.md` every session (current truth, not history):

```
# ARENA STATE
updated: <ISO> · model: <name> · stage: <0.xx> · phase: <0-5> · baseline: green|red(list)
engine: <godot --version | unavailable> · budget: fps · frame_ms · draw_calls · nodes
## Current milestone / ## Claims / ## Known red
## Session log   (append-only, newest first, keep 20)
- <ISO> · <model> · <class>:<grade> · PACKET-<id> · <change> · verify: V<n> · <PR>
## Session log rules: one line, <=200 chars, link the PR; "did nothing" is also a line.
## Grade overrides  - <model> · <CLASS> · <from>-><to> · <evidence> · <date>
## Refusal probe    - <model> · <stage> · V:full|sanitized|refused · I: · P:full|shifted|refused · <date>
## Proposals / ## Suggestions / ## Decisions (ADR pointers)
```

End with `NEXT:` — max 3 bullets addressed to the next agent.

## L13 · Git and PR

Branch `arena/<slug>`. Conventional Commits, imperative, ≤72 char subject, body states *why* + the verification rung. One logical change per commit. PR body: what / why / model+class+grade / packet id / verification rung / artifacts / risk+rollback. Never force-push a shared branch. `.tscn` conflict → pick one side, reopen the scene, re-apply intent by hand. Binary conflict → take one side, re-import, re-verify. No AI attribution unless CONTRIBUTING asks.

## L14 · Stop conditions

Stop and escalate when: the change alters design direction or audience · credentials/paid services needed · licensing unclear · the repo is red in a way your packet cannot isolate · scope would exceed ~2× the packet · data loss or save corruption (`S0` first) · another active claim owns the file · two fix attempts failed (write what you learned, file the unblocking packet, take a fallback).

## L15 · Agent failure modes (self-check before finishing)

`confident unverified claim` · `API invented from memory` · `scope creep disguised as cleanup` · `test silenced to get green` · `thrashing on one bug` · `packet without acceptance criteria` · `state file not rewritten` · `grade ignored because "I can do it"` · `NARR packet sent to a Steered model` · `hand-edited AUTO block` · `retro-fitting the doc to the repo instead of the reverse`.

## L16 · Tooling contract

```
arena_router.py --selftest   asserts: 55 models, 16 classes, stage table == code, AUTO blocks ==
                             generated, evidence integrity, tie-break, fallback, high-risk gate
                --emit       regenerates capability_matrix.csv, model_cards.md, ROUTER dispatch
                             table, fallback-pressure table, and this file's AUTO blocks
                --audit      prints the factual claims behind ROUTER §8.1 + evidence register
                --evidence   prints the external-evidence register and what it changed
                --stage X --model M [--tasks CLS:name:rung,...] [--override CLS=Grade]
writing_lane.py --selftest   asserts curated set == roster, axes valid, headline derivable,
                             quadrants partition the roster
                --emit | --report
```

Rules: edit the CSV or the curated table, never the generated artifacts. `--emit` then `--selftest` before any commit that touches grades, stages, classes or evidence. If a printed audit line disagrees with prose, fix the prose in the same PR.

## L17 · Expansion docs (load only if the task needs them)

| File | Load when |
|---|---|
| `ARENA_MODEL_ROUTER.md` | you need per-model reasoning, worked examples, the dispatch table, or the source limits |
| `ARENA_CREATIVE_WRITING.md` | the packet is NARR/DOCS/lore, or a scene is mature or political |
| `ARENA_README.md` | legacy prose: tier charters, deployment instructions, appendices/templates |
| `docs/adr/0001-per-model-routing.md` | why tier bands were replaced; reversal cost |
| `docs/arena/writing_censorship.csv` | per-model censorship evidence + citations |
| `docs/arena/leaderboard_2026-10-23.csv` | raw snapshot; do not re-derive grades by hand |

## L18 · Changelog

| Date | Change |
|---|---|
| 2026-10-25 | v3.1 — consolidation. Router (§L2–L5), evidence layer (L6), writing lane (L7), Godot/verification/playtest/state/git (L9–L13) merged from four documents into one. AUTO blocks added for stages, classes and the 55-model index. |
| 2026-10-25 | Router 1.0: per-model routing replaced tier bands (ADR 0001). |
| 2026-10-25 | Creative writing lane: competence × censorship, separate axis. |

---

*Roster decides who. Stage decides what. Scene decides whether. Evidence decides who was right.*
