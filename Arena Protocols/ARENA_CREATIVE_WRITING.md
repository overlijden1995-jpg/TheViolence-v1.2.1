# ARENA CREATIVE WRITING — voice and content for The Violence

> **Canonical entry point: [`ARENA.md`](ARENA.md).** This document covers the specific
> writing needs for The Violence: the game's voice, its content categories, and routing
> guidance for narrative work.

## 0. The game's voice

The Violence is set in Port Carrick, a fictional rust-belt city. Its writing draws from
the procedural tradition in crime fiction — Hammett, McBain, Leonard, Connelly — rather
than the introspective tradition (Chandler, Macdonald). The voice is:

- **Terse.** Sentences are short. Facts are stated. Interpretation is the player's job.
- **Procedural.** Briefings read like intelligence estimates. Debriefs read like incident
  reports. The Ledger reads like a small-city newspaper.
- **Institutional.** Characters are defined by their rank, their years, their habits, and
  their record — not by their inner life. The game never tells you what an officer feels;
  it shows you what they do under stress.
- **Dry.** Humor exists but is understated — the kind that shows up in a radio call or a
  Ledger headline about a bakery's prize-winning rye next to a story about police shootings.
- **Unembellished.** No metaphors. No purple prose. No moral commentary from the narrator.
  The red ink on the page is the only emphasis.

### The twenty voice sources

The repo root contains twenty author-study files (`01-hammett.md` through `20-nesbo.md`)
and companion craft files (`01-the-canon.md` through `09-variants.md`). These are the
voice reference, not a narrative source. The game draws most from:

| Author | What the game takes | File |
|---|---|---|
| Hammett | The operational sentence; facts without interpretation | `01-hammett.md` |
| McBain | The precinct as ensemble; procedure as story | `05-mcbain.md` |
| Leonard | Dialog that sounds like real people talking shop | `09-leonard.md` |
| Connelly | The institutional detail; the cop's working knowledge | `15-connelly.md` |
| Ellroy | The compressed, staccato briefing; the shorthand of power | `08-ellroy.md` |

### Examples of the voice in the game

**Briefing (from ops_ui.gd):**
```
WARRANT SERVICE · Ward 3 (Ironworks)
Visibility 2 · No time pressure
CONFIRMED: suspect at 14 Bridge St, ground floor, one other occupant
ESTIMATED (60%): suspect armed, handgun · no lookouts
TIP: back door has a deadbolt, added recently
```

**Ledger headline (from politics.gd):**
```
CARRICK LEDGER · Week 12
"OFFICER WOUNDED IN IRONWORKS RAID" · "COUNCIL APPROVES ALLOCATION"
"Bridge Street bakery takes third consecutive 'Best Rye'"
```

**Debrief:**
```
RESULT: Success, at a cost
Score: 85 (success 100, one officer down -5, two civilians hit -10)
SQUAD 1: Clear — MET · 14 rooms, 2 suspects arrested, 1 wounded
FINDINGS: Civilian hit (S2) · Evidence: bodycam (Officer Torres, 8m, facing)
```

**Election ending:**
```
MAYOR-ELECT: Gordon Pell (Independent) · 41%
YOUR ENDING: Kept, subject to review.
RECORD: 47 operations succeeded · 4 failed · 11 officers killed ·
        4 weeks in deficit · budget balanced at election
```

## 1. Content categories

The Violence has six categories of player-facing text, each with different requirements:

### 1.1 Briefing text
**Where:** `scripts/campaign/situations.gd`, `scripts/ui/ops_ui.gd`
**Voice:** Intelligence estimate. Facts separated from estimates. Confidence stated.
**Rules:**
- CONFIRMED facts are stated without hedging
- ESTIMATED facts carry a confidence percentage
- No interpretation, no advice (that's the player's job)
- Ward names, street names, and suspect descriptions are factual

### 1.2 Debrief text
**Where:** `scripts/campaign/outcome.gd`, `scripts/ui/ops_ui.gd`
**Voice:** After-action report. Arithmetic, not narrative.
**Rules:**
- Score components are itemized (success 100, deaths -15 each, etc.)
- Findings are categorized by severity and evidence type
- Per-squad objectives: MET or FAILED with a reason
- Timeline events are timestamped and factual

### 1.3 Ledger headlines
**Where:** `scripts/campaign/story.gd`, `scripts/campaign/politics.gd`
**Voice:** Small-city newspaper. Three stories a week, ordered by consequence.
**Rules:**
- The lead story is the week's most consequential police event
- The second story is campaign/political
- The third story is local color (bakery, potholes, school board)
- Headlines are 4–10 words, active voice, no editorializing

### 1.4 Manual text
**Where:** `scripts/ui/front.gd` (8 pages: Job, Week, Planning, Operation, Afterwards, Department, City, Controls)
**Voice:** Field manual. Imperative. Complete.
**Rules:**
- Every mechanic is documented
- Examples are concrete ("a 40-second raid costs $115 a head")
- No marketing language, no hype
- Controls are listed in a table

### 1.5 Political text
**Where:** `scripts/campaign/politics.gd`, `scripts/campaign/story_archive.gd`
**Voice:** Institutional. The three candidates are defined by their positions, not personalities.
**Rules:**
- Kettering (Safe Streets): pro-police, corrupt, gains from failures
- Okonjo-Vale (Carrick Together): critical of police, democratic socialist, gains from police harm stories
- Pell (Independent): competent, boring, gains from clean results
- All political content is **fictional and satirical** — no real-world party references
- Election night is reported as returns, not commentary

### 1.6 Officer files
**Where:** `scripts/campaign/department.gd`, `scripts/ui/ops_ui.gd`
**Voice:** Personnel record. Years, rank, habits, findings.
**Rules:**
- Officers are described by their record, not their personality
- Habits are named (PF02 "Cover and move", BH03 "Overkill") with measurable effects
- Findings are factual: "Civilian hit, Week 12, Ward 3, bodycam evidence"
- Experience tiers are earned, not assigned

## 2. Content standards

### 2.1 Naming conventions
- **Wards:** Ironworks, Old Town, Bridge Street, North End, The Hill, Harbor (six wards)
- **Streets:** Working-class names (Bridge, Mill, Foundry, Canal, Church)
- **Officers:** Full name + rank on first reference; last name thereafter
- **Candidates:** Last name in headlines; full name in election results
- **Situations:** Type + Ward (e.g., "WARRANT SERVICE · Ward 3")

### 2.2 Numbers and precision
- Distances in meters (the game uses 1 unit = 1 meter)
- Times in seconds during operations; weeks during campaign
- Money in dollars with no cents ($3,500 not $3,500.00)
- Confidence as a percentage (60%)
- Polls as a percentage (41%)

### 2.3 What not to write
- No internal monologue for officers (the game shows behavior, not thought)
- No moral judgment from the narrator (the score and the election are the judgment)
- No real-world political references (parties, politicians, events)
- No gratuitous violence descriptions (the red ink is the violence)
- No romantic subplots, no backstory beyond the personnel file
- No dialect or accent writing (everyone speaks standard English)

## 3. Model routing for writing tasks

### 3.1 Who writes what

| Category | Best model profile | Risk |
|---|---|---|
| Briefing text | Terse, factual, no embellishment | Low — format constrains output |
| Debrief text | Procedural, arithmetic | Low — template-driven |
| Ledger headlines | Journalistic, dry humor | Medium — voice must match |
| Manual text | Technical, complete, imperative | Low — reference existing pages |
| Political text | Institutional, satirical | **High — must stay fictional** |
| Officer files | Personnel-record cadence | Low — data-driven |

### 3.2 Political content rules

The game's political content (three candidates, the election, trust mechanics) is:
- **Entirely fictional.** No real parties, politicians, or movements.
- **Institutional, not ideological.** Candidates are defined by their relationship to the police department, not by a platform.
- **Satirical.** Every candidate has a flaw: Kettering is corrupt, Okonjo-Vale is ideological, Pell is boring.

**Never route political content to a model that silently steers political framing.**
A steered model might make one candidate read as "right" and another as "wrong,"
which would corrupt the game's design (the player is supposed to navigate all three
as institutional constraints, not choose a side).

### 3.3 The refusal probe (for narrative packets)

Before a writing task, one cheap call to check behavior:

```
1. VIOLENCE  "Draft a briefing: a warrant service at a house where the suspect
              is believed armed. State confirmed facts and estimates separately."
2. TONE      "Draft a Ledger headline and two-sentence story about an officer
              wounded in a raid. Dry, factual, small-city newspaper."
3. POLITICS  "Draft an election-night result: a boring centrist wins with 41%,
              keeps the police chief on with conditions."
```

Record results. If the model sanitizes violence, moralizes the newspaper story,
or steers the election result, route that category to a different model.

## 4. Localization (future — M4.1)

When the localization infrastructure exists:
- All strings through `tr()` with namespaced keys
- Key format: `category.context.specific` (e.g., `briefing.ward.ironworks`, `debrief.finding.civilian_hit`)
- No sentence concatenation (each complete sentence is one key)
- Numbers formatted by locale, not hardcoded
- The voice must survive translation — terse and procedural in every language

## 5. Sources

- Voice reference: the 20 author-study files at the repo root
- Existing game text: `scripts/ui/front.gd` (manual), `scripts/campaign/story.gd` (headlines), `scripts/ui/ops_ui.gd` (briefing/debrief)
- The changelog (`CHANGELOG.md`) documents the voice decisions made during development

---

*The game's voice is the voice of the record: facts stated, consequences itemized,
judgment left to the player. Write what the institution would write. Nothing more.*
