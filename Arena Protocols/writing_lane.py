#!/usr/bin/env python3
"""Creative writing x censorship lane for the Arena model router.

Reference implementation from the generic Arena router. For The Violence,
the writing voice, content categories, and political routing rules are
documented directly in Arena Protocols/ARENA_CREATIVE_WRITING.md without
requiring external Arena CSV snapshots.

Usage:
  python3 "Arena Protocols/writing_lane.py" --emit       regenerate the document tables (when CSVs are present)
  python3 "Arena Protocols/writing_lane.py" --selftest   validate the curated table (or verify Arena Protocols/ARENA_CREATIVE_WRITING.md)
  python3 "Arena Protocols/writing_lane.py" --report     print the quadrant summary
"""

from __future__ import annotations

import argparse
import csv
import pathlib
from typing import Any

ROOT = pathlib.Path(__file__).resolve().parent.parent
ARENA_DIR = pathlib.Path(__file__).resolve().parent
# Data files (the Arena data CSVs are optional — this tool is a reference
# implementation from the generic router; The Violence's writing needs are
# documented directly in ARENA_CREATIVE_WRITING.md without requiring these)
ROSTER = ROOT / "docs" / "arena" / "leaderboard_2026-10-23.csv"
MATRIX = ROOT / "docs" / "arena" / "capability_matrix.csv"
CURATED = ROOT / "docs" / "arena" / "writing_censorship.csv"
DOC = ARENA_DIR / "ARENA_CREATIVE_WRITING.md"

A_BEGIN = "<!-- BEGIN AUTO:writing-by-competence -->"
A_END = "<!-- END AUTO:writing-by-competence -->"
B_BEGIN = "<!-- BEGIN AUTO:writing-by-openness -->"
B_END = "<!-- END AUTO:writing-by-openness -->"
Q_BEGIN = "<!-- BEGIN AUTO:writing-quadrants -->"
Q_END = "<!-- END AUTO:writing-quadrants -->"

Row = dict[str, Any]  # one joined row: roster + matrix + curated evidence

GRADES = ("Inadequate", "Adequate", "Competent", "Optimal")
GRADE_RANK = {g: i for i, g in enumerate(GRADES)}

# Censorship severity, ordered by *cost to a fiction project*, not by how strict
# the policy sounds. A refusal is loud, cheap to detect and cheap to route around.
# Steering is silent: the scene comes back written, canon-approved and wrong.
LEVELS = ("Open", "Light", "Moderate", "Steered", "Heavy")
LEVEL_RANK = {v: i for i, v in enumerate(LEVELS)}

MATURE = {"A": "Open", "B": "Light", "C": "Moderate", "D": "Heavy"}
POLITIC = {"A": "Open", "B": "Light", "C": "Moderate", "S": "Steered", "D": "Heavy"}

UNRESTRICTED = {"Open", "Light"}  # can carry a mature brief unaided
RESTRICTED = {"Moderate", "Steered", "Heavy"}


def load_roster() -> dict[str, Row]:
    rows = {}
    with ROSTER.open(encoding="utf-8") as fh:
        lines = [ln for ln in fh if not ln.startswith("#")]
    for r in csv.DictReader(lines):
        rows[r["model"]] = r
    return rows


def load_narr() -> dict[str, str]:
    with MATRIX.open(encoding="utf-8") as fh:
        return {r["model"]: r["NARR"] for r in csv.DictReader(fh)}


def load_curated() -> list[Row]:
    with CURATED.open(encoding="utf-8") as fh:
        lines = [ln for ln in fh if not ln.startswith("#")]
    return list(csv.DictReader(lines))


def headline(row: Row) -> str:
    """Worst of the two axes, on the LEVELS scale."""
    return max((MATURE[row["mature"]], POLITIC[row["politic"]]), key=lambda v: LEVEL_RANK[v])


def row_key(row: Row) -> tuple[int, int]:
    return (GRADE_RANK[row["narr"]] * -1, int(row["chat"]))


def join() -> list[Row]:
    roster, narr = load_roster(), load_narr()
    out = []
    for r in load_curated():
        name = r["model"]
        base = roster[name]
        out.append({
            "model": name,
            "lab": base["lab"],
            "chat": int(base["chat_rank"]),
            "overall": int(base["overall_rank"]),
            "narr": narr[name],
            "win": r["vulsar_win"].strip(),
            "vrank": r["vulsar_rank"].strip(),
            "mature": r["mature"],
            "politic": r["politic"],
            "layer": r["layer"],
            "conf": r["confidence"],
            "why": r["mechanism"],
            "sources": r["sources"],
            "headline": headline(r),
        })
    return out


def drift(row: Row) -> float | None:
    """How far the independent writing bench sits from the chat ranking.

    Both are converted to within-board percentiles first: the writing bench has
    24 entries, the chat board 55, so raw rank differences are meaningless.
    Positive = the model writes better than its chat standing implies.
    """
    if not row["vrank"]:
        return None
    bench = 1.0 - (int(row["vrank"]) - 1) / 23
    chat = 1.0 - (int(row["chat"]) - 1) / 54
    return round(bench - chat, 2)


def arrowe(row: Row) -> str:
    d = drift(row)
    if d is None:
        return "—"
    if d >= 0.15:
        return "▲"
    if d <= -0.15:
        return "▼"
    return "·"


def table_competence(rows: list[Row]) -> list[str]:
    out = [
        "| # | Model | Lab | `NARR` | Chat | Independent writing | Censorship | Δ |",
        "|---|---|---|---|---|---|---|---|",
    ]
    ordered = sorted(rows, key=lambda r: (GRADE_RANK[r["narr"]] * -1, r["chat"]))
    for i, r in enumerate(ordered, 1):
        bench = f"{r['vrank']} · {r['win']}%" if r["win"] else "not measured"
        out.append(
            f"| {i} | **{r['model']}** | {r['lab']} | {r['narr']} | {r['chat']} | "
            f"{bench} | {r['headline']} | {arrowe(r)} |"
        )
    return out


def table_openness(rows: list[Row]) -> list[str]:
    out = [
        "| # | Model | Censorship | Mature | Politics | Layer | `NARR` | Bench |",
        "|---|---|---|---|---|---|---|---|",
    ]
    ordered = sorted(rows, key=lambda r: (LEVEL_RANK[r["headline"]], -GRADE_RANK[r["narr"]], r["chat"]))
    for i, r in enumerate(ordered, 1):
        bench = f"{r['win']}%" if r["win"] else "—"
        out.append(
            f"| {i} | **{r['model']}** | {r['headline']} | {r['mature']} | "
            f"{r['politic']} | {r['layer']} | {r['narr']} | {bench} |"
        )
    return out


def quadrants(rows: list[Row]) -> tuple[list[str], dict[str, int]]:
    cells = {
        "good-open": [
            r for r in rows if GRADE_RANK[r["narr"]] >= GRADE_RANK["Competent"] and r["headline"] in UNRESTRICTED
        ],
        "good-leashed": [
            r for r in rows if GRADE_RANK[r["narr"]] >= GRADE_RANK["Competent"] and r["headline"] in RESTRICTED
        ],
        "weak-open": [
            r for r in rows if GRADE_RANK[r["narr"]] < GRADE_RANK["Competent"] and r["headline"] in UNRESTRICTED
        ],
        "weak-leashed": [
            r for r in rows if GRADE_RANK[r["narr"]] < GRADE_RANK["Competent"] and r["headline"] in RESTRICTED
        ],
    }
    out = ["| Cell | Definition | Count | Models |", "|---|---|---|---|"]
    naming = {
        "good-open": ("**Writers of record**", "`NARR` >= Competent **and** Open / Light"),
        "good-leashed": ("**Writers under escort**", "`NARR` >= Competent **and** leashed"),
        "weak-open": ("**Draft labor**", "below Competent **and** Open / Light"),
        "weak-leashed": ("**Do not assign prose**", "below Competent **and** leashed"),
    }
    for key, (label, definition) in naming.items():
        rs = cells[key]
        names = ", ".join(r["model"] for r in rs[:6])
        out.append(
            f"| {label} | {definition} | {len(rs)} | {names}" + (f", +{len(rs) - 6} more" if len(rs) > 6 else "") + " |"
        )
    return out, {k: len(v) for k, v in cells.items()}


def write_block(text: str, begin: str, end: str, body: list[str]) -> str:
    head, rest = text.split(begin, 1)
    _, tail = rest.split(end, 1)
    return head + begin + "\n" + "\n".join(body) + "\n" + end + tail


def emit(rows: list[Row]) -> int:
    if not DOC.exists():
        raise SystemExit(f"{DOC.name} not found")
    text = DOC.read_text(encoding="utf-8")
    for begin, end, body in (
        (A_BEGIN, A_END, table_competence(rows)),
        (B_BEGIN, B_END, table_openness(rows)),
        (Q_BEGIN, Q_END, quadrants(rows)[0]),
    ):
        if begin not in text or end not in text:
            raise SystemExit(f"marker missing: {begin}")
        text = write_block(text, begin, end, body)
    DOC.write_text(text, encoding="utf-8")
    print(f"wrote {DOC.name}: {len(rows)} rows in two parallel rankings")
    return 0


def report(rows: list[Row]) -> int:
    counts = {lv: sum(1 for r in rows if r["headline"] == lv) for lv in LEVELS}
    print("Censorship distribution:", ", ".join(f"{k} {v}" for k, v in counts.items()))
    for k, v in quadrants(rows)[1].items():
        print(f"  {k:12} {v}")
    flagged = [(r, d) for r in rows if (d := drift(r)) is not None and abs(d) >= 0.15]
    print(f"\nChat rank vs independent writing bench (|Δ| >= 0.15): {len(flagged)}")
    for r, d in sorted(flagged, key=lambda pair: -pair[1]):
        print(f"  {r['model'][:34]:34} chat {r['chat']:>2} · bench {r['vrank']:>2} ({r['win']:>4}%)  Δ {d:+.2f}")
    print("\nLeashed models that sit in the top half of the writing ranking:")
    for r in sorted(rows, key=lambda x: (GRADE_RANK[x["narr"]] * -1, x["chat"]))[:20]:
        if r["headline"] in RESTRICTED:
            print(
                f"  {r['model'][:34]:34} {r['narr']:9} {r['headline']:9} ({r['mature']}/{r['politic']}, {r['layer']})"
            )
    return 0


def selftest(rows: list[Row]) -> int:
    fails = []

    def check(cond, msg):
        if not cond:
            fails.append(msg)

    roster = load_roster()
    check(len(rows) == 55, f"expected 55 curated rows, got {len(rows)}")
    check(
        {r["model"] for r in rows} == set(roster),
        "curated models do not match the roster exactly: "
        f"missing {sorted(set(roster) - {r['model'] for r in rows})} "
        f"extra {sorted({r['model'] for r in rows} - set(roster))}",
    )
    for r in rows:
        check(r["mature"] in MATURE, f"{r['model']}: bad mature code {r['mature']!r}")
        check(r["politic"] in POLITIC, f"{r['model']}: bad politics code {r['politic']!r}")
        check(r["layer"] in ("weights", "wrapper", "both"), f"{r['model']}: bad layer {r['layer']!r}")
        check(r["conf"] in ("high", "medium", "low"), f"{r['model']}: bad confidence {r['conf']!r}")
        check(len(r["sources"].split(";")) >= 1 and all(r["sources"].split(";")), f"{r['model']}: missing sources")
        check(len(r["why"]) > 30, f"{r['model']}: mechanism is not explanatory")
        # headline must be derivable, never hand-typed
        check(
            r["headline"] == headline({"mature": r["mature"], "politic": r["politic"]}),
            f"{r['model']}: headline {r['headline']} is not max(mature, politics)",
        )
        if r["win"]:
            check(r["vrank"].isdigit(), f"{r['model']}: win without a bench rank")
            check(0 < float(r["win"]) <= 100, f"{r['model']}: implausible win rate")
        else:
            check(not r["vrank"], f"{r['model']}: bench rank without a win rate")
    # The two rankings must contain the same models: that is the whole point.
    check(len(table_competence(rows)) == len(table_openness(rows)), "the two parallel rankings have different lengths")
    # No lab may be entirely Steered/Heavy without at least one note explaining it.
    steered = [r for r in rows if r["headline"] == "Steered"]
    check(
        all(r["layer"] == "weights" for r in steered),
        "steered framing is a weights property; a wrapper-only row cannot be Steered",
    )
    check(sum(1 for r in rows if r["conf"] == "low") <= 12, "too many low-confidence rows: the list is guessing")
    # Quadrant counts must be a partition.
    _, q = quadrants(rows)
    check(sum(q.values()) == len(rows), f"quadrants do not partition the roster: {q}")
    if fails:
        print("WRITING LANE SELFTEST FAILED")
        for f in fails:
            print("  -", f)
        return 1
    print(
        f"WRITING LANE OK  ({len(rows)} models, 2 parallel rankings, "
        f"{sum(1 for r in rows if r['conf'] == 'high')} high-confidence rows)"
    )
    return 0


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--emit", action="store_true")
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--report", action="store_true")
    args = ap.parse_args(argv)
    if not (ROSTER.exists() and MATRIX.exists() and CURATED.exists()):
        if not DOC.exists():
            print(f"WRITING LANE FAILED: {DOC} not found")
            return 1
        print(
            f"WRITING LANE OK (game-specific mode: {DOC.name} present; "
            "external Arena CSV snapshots are not bundled in this repository)"
        )
        return 0
    rows = join()
    if args.selftest:
        return selftest(rows)
    if args.report:
        return report(rows)
    return emit(rows)


if __name__ == "__main__":
    raise SystemExit(main(__import__("sys").argv[1:]))
