# ARENA README — legacy reference for The Violence

> **Canonical entry point: [`ARENA.md`](ARENA.md).** That file holds the game-specific
> contract: architecture, test infrastructure, verification rules, and invariants for
> The Violence.
>
> **This document is legacy context.** It preserves the full tier charter system and
> operational templates. Load it only when `ARENA.md` §L15 says to — specifically when
> you need the tier permission matrix, the packet templates, or the playtest protocol
> in full detail.

| Field | Value |
|---|---|
| Engine target | Godot 4.4 and 4.7 (declared in `project.godot` as `config/features`) |
| Game | The Violence — police-command & CQB autobattler |
| Version | 0.50 (vertical slice prototype — see `Arena Protocols/ROADMAP.md`) |
| Per-model routing | [`ARENA_MODEL_ROUTER.md`](ARENA_MODEL_ROUTER.md) |
| Writing lane | [`ARENA_CREATIVE_WRITING.md`](ARENA_CREATIVE_WRITING.md) |

---

## 0. The twelve hard rules (non-negotiable)

These are restated from `ARENA.md` §L1 for standalone reference:

1. Never push to the default branch. Never force-push a shared branch.
2. Never fabricate verification. Unrun = "not verified".
3. Never weaken the safety net — no deleting tests, loosening assertions, or silencing errors.
4. Never invent an API. No Godot 3.x calls in a 4.x project.
5. No secrets, keys, tokens, credentials, or personal data anywhere.
6. No unlicensed third-party assets or code.
7. Do not touch files outside your work packet's declared scope.
8. Do not exceed your capability grade's permissions.
9. Leave the repo runnable — project loads, tests no worse than baseline.
10. Record the session before finishing.
11. Do not restructure roadmap, README, design canon, or save format without documented justification.
12. Do not claim to have "played" unless you executed the game.

---

## 1. Capability tiers

Tiers are a coarse routing prior. The per-model router in `ARENA_MODEL_ROUTER.md`
refines this with per-class grades. Tiers survive as the fallback for unidentified
models and as the permission ceiling description.

| Tier | Band | Charter |
|---|---|---|
| **1** | Top models | Architecture, whole-game playtest/debug, gameplay overhauls, complex assets, structural roadmap edits |
| **2** | Strong models | One system end-to-end, complex assets, hard debugging, writing when no better task exists |
| **3** | Mid-field models | Narrative design first; contained fixes; simple assets; bug flagging with repro |
| **4** | Lower-ranked models | Playtesting, impressions, suggestions, bug reports — read-only on code |

### Tier permission matrix (tier × work class)

| Work class | T1 | T2 | T3 | T4 |
|---|---|---|---|---|
| Architecture / major refactor | OWN | — | — | — |
| Save format migration | OWN | — | — | — |
| Whole-game playtest & debug | OWN | OWN | OWN | OWN |
| Gameplay system build | OWN | OWN | — | — |
| Complex asset creation | OWN | OWN | — | — |
| Hard debugging | OWN | OWN | — | — |
| Creative writing / worldbuilding | OWN | OWN | OWN | — |
| Simple asset creation | OWN | OWN | OWN | — |
| Contained bugfix | OWN | OWN | OWN | — |
| Bug flagging (no fix) | OWN | OWN | OWN | OWN |
| Playtest impressions | OWN | OWN | OWN | OWN |
| Suggestions & recommendations | ADVISE | ADVISE | ADVISE | ADVISE |
| CI/tooling | OWN | OWN | — | — |
| Performance profiling | OWN | OWN | — | — |
| Structural roadmap/README change | OWN | — | — | — |

`OWN` = may claim and complete. `ADVISE` = recommendations only. `—` = do not route.

---

## 2. Boot sequence

Budget 5 minutes. Do not skip.

| # | Step |
|---|---|
| 1 | Read `ARENA.md` (this game's contract) |
| 2 | Read `Arena Protocols/ROADMAP.md` (current milestone) |
| 3 | Read `project.godot` for engine version |
| 4 | Establish baseline: `python3 tools/gd47_check.py`, `tools/run_tests.sh --check` |
| 5 | Resolve your capability tier and strongest task classes |
| 6 | Build candidate task list from the current milestone's open items |
| 7 | Claim one packet, announce it, execute with incremental verification |
| 8 | Hand off: state, session log, PR, next-best suggestions |

---

## 3. Work packet template

```markdown
### PACKET-<id> — <title>
rung: <1-6>            size: <S|M|L>
class: SYS|DEBUG|ARCH|PERF|UIUX|ASSETS|NARR|TOOL|QA
scope: <file/dir globs>
depends_on: <packet ids or "none">
acceptance:
  - [ ] <observable, testable statement>
  - [ ] <observable, testable statement>
verify: V0..V5
rollback: <revert|flag|migration>
notes: <gotchas, prior attempts>
```

### Acceptance criteria that actually gate

- ❌ "Improve the balance."
- ✅ "Equal regulars 5v5 on map m04: attacker wins 30–50% over 80 fights. Gate in `balance_test.gd`."

- ❌ "Write briefing text."
- ✅ "Briefing for warrant service, Ward 3: confirmed facts listed separately from estimates with confidence; no interpretation; all street names consistent with existing ward."

---

## 4. The task ladder

| Rung | Class | The Violence examples |
|---|---|---|
| 1 | Blockers | Boot crash, save corruption, test regression, unparseable script |
| 2 | Milestone | Current roadmap tasks |
| 3 | Quality debt | Silent harnesses, empty balance cells, inline strings |
| 4 | Polish | Figure animation, camera feel, audio mix |
| 5 | Coverage | Unwired shorts, music, accessibility, localization |
| 6 | Discovery | Playtesting, balance probes, design proposals |

---

## 5. Verification ladder

| Rung | Check | Command |
|---|---|---|
| V0 | Static read | read the diff |
| V1 | Parse check | `python3 tools/gd47_check.py` |
| V2 | Import/boot | `tools/run_tests.sh --check` |
| V3 | Quick tier | `tools/run_tests.sh --quick` (11 suites) |
| V4 | Full tier | `tools/run_tests.sh --full` (+determinism, campaign, brains) |
| V5 | Soak tier | `tools/run_tests.sh --soak` (+balance matrix) |

No engine binary → capped at V1. Write: `verification: static only (no engine in environment)`.

---

## 6. Playtesting protocol

### Session types

| Type | Duration | What you do |
|---|---|---|
| Smoke | 5 min | Launch, reach gameplay, quit, reload |
| Loop | 20–40 min | Play the core loop to completion |
| Adversarial | 15–30 min | Try to break it: pause-spam, save-load mid-action, resize |
| Read-through | 15 min | Read manual/UI text for voice and clarity |
| Soak | 30+ min | Extended play, watch for memory/perf issues |
| Fresh-eyes | 15 min | Zero context — what do you think this game is? |

### Observation format

```
[bug]       situation → observation → hypothesis
[confusion] situation → observation → hypothesis
[feel]      situation → observation → hypothesis
[content]   situation → observation → hypothesis
```

### Severity

| Sev | Definition |
|---|---|
| S0 | Cannot play: crash, hang, corrupt save |
| S1 | Blocks progress: softlock, broken gate |
| S2 | Major: broken mechanic, severe unfairness |
| S3 | Minor: cosmetic, typo, confusing feedback |
| S4 | Polish suggestion |
| design-question | Cannot tell intent from bug |

---

## 7. Git protocol

- **Branches:** `arena/<slug>`. Never commit to default branch.
- **Commits:** Conventional Commits, imperative, ≤72 chars.
- **Version changes:** Edit `scripts/version.gd`, run `python3 tools/sync_version.py`, commit all three files.
- **Never force-push** shared branches.
- **`.tscn` conflicts:** pick one side, reopen in editor, re-apply intent by hand.

---

## 8. Handoff template

```
NEXT:
(1) <specific task that needs attention>
(2) <unblocked packet or reduced scope>
(3) <file or area to avoid until X lands>
```

---

## 9. The game at a glance

For agents who need context fast:

- **What:** Police-command and CQB autobattler. You plan; officers execute.
- **Where:** Port Carrick, fictional rust-belt city, six wards.
- **How long:** 40-week campaign ending in a mayoral election.
- **Modes:** Campaign (persistent department), Test Range (sandbox), Endless Battle (city sim).
- **Engine:** Godot 4.4/4.7, compatibility renderer, top-down 2D.
- **Art:** Ink on paper, one red (#B31F26). Never a team color.
- **Sound:** 34 synthesized SFX + ambience beds. No music yet.
- **Key code:** `scripts/sim/world.gd` (sim core), `scripts/main.gd` (flow), `scripts/campaign/` (the campaign).
- **Tests:** 36 harnesses in `tests/`, run via `tools/run_tests.sh`.
- **Save:** Versioned, temp-then-rename, .bak fallback. One ironman slot.
- **Determinism:** 35 seeded cases, hashed. Any sim change must account for the fixture.

---

## 10. Changelog

| Date | Change |
|---|---|
| 2026-10-25 | v4.0 — Streamlined for The Violence. Game-specific context added. Version relabeled 0.50. Pointers to new game-specific documents. |
| 2026-10-25 | v1.0 — Original universal Arena agent instruction document. |

---

*Deployed by Arena.ai. The contract is ARENA.md; the plan is ROADMAP.md; the test suite is the truth.*
