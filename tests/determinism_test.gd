extends SceneTree
## The determinism regression (ported from the parallel line, v0.7.8).
##
## Runs a fixed set of seeded matches and planned operations, and hashes the terminal
## world state of each. The digests live in tests/fixtures/determinism.json, so a change
## that quietly alters the simulation (a refactor, a new habit hook, a different RNG
## call order) shows up here instead of as a mystery balance swing later.
##
##   godot --headless --path . -s res://tests/determinism_test.gd
##   godot --headless --path . -s res://tests/determinism_test.gd -- --write
##   godot --headless --path . -s res://tests/determinism_test.gd -- --verbose
##
## --write regenerates the fixture. Do it deliberately, in the same commit as the
## behaviour change, and read the diff (each case keeps winner, time, shots and hits
## beside its digest, so a change can be told apart from noise).
##
## Two halves:
##   matches     the test range: [map, n_a, n_b, ech_a, ech_b, posture_a, posture_b] x SEEDS
##   operations  the first week's board of campaign SEEDS, each with its suggested plan
##               (police rules, civilians, doors, kit, orders, less-lethal)

const Maps = preload("res://scripts/maps/registry.gd")
const Nav = preload("res://scripts/sim/nav.gd")
const World = preload("res://scripts/sim/world.gd")
const Teams = preload("res://tests/teams.gd")
const Campaign = preload("res://scripts/campaign/campaign.gd")
const Department = preload("res://scripts/campaign/department.gd")
const Orders = preload("res://scripts/campaign/orders.gd")
const Autoplan = preload("res://scripts/campaign/autoplan.gd")
const Operation = preload("res://scripts/campaign/operation.gd")

const FIXTURE := "res://tests/fixtures/determinism.json"

const CASES := [
	[0, 2, 2, "sof", "untrained", "assault", "hold"],
	[0, 5, 5, "regular", "regular", "assault", "hold"],
	[0, 3, 5, "police", "militia", "assault", "hold"],
	[1, 2, 2, "sof", "militia", "assault", "hold"],
	[1, 4, 4, "regular", "untrained", "assault", "hold"],
	[4, 5, 5, "police", "regular", "assault", "hold"],
	[4, 8, 8, "regular", "militia", "hunt", "hunt"],
	[7, 12, 12, "sof", "regular", "assault", "hold"],
	[10, 6, 6, "police", "militia", "assault", "hold"],
]
const SEEDS := [1001, 2002, 3003]
const CAMPAIGN_SEEDS := [1001, 2002]

var _navs := {}


## A digest of everything the simulation is supposed to decide. Positions to 3
## decimal places: enough to catch divergence, not so much that float noise trips it.
static func digest(w) -> String:
	var parts: Array = []
	parts.append("t=%.4f" % w.t)
	parts.append("sh=%d,h=%d,ff=%d,st=%d,w=%d" % [w.stat["shots"], w.stat["hits"], w.stat["friendly"],
		w.stat["stray"], w.winner])
	var ops: Array = []
	for o in w.ops:
		ops.append("%s|%s|%.3f,%.3f|w%d|p%d|a%d|s%.4f|k%d|c%d|r%d|g%d" % [o.id, o.state, o.pos.x, o.pos.y,
			o.wounds, o.plates, o.alert, o.stress, o.kills, int(o.complying), int(o.arrested), int(o.gone)])
	ops.sort()
	parts.append("ops=" + ";".join(ops))
	parts.append("dead=%d" % w.deaths.size())
	return "|".join(parts).md5_text().substr(0, 16)


func _nav(mi: int, lv):
	if not _navs.has(mi):
		var nv = Nav.new()
		nv.build(lv)
		_navs[mi] = nv
	return _navs[mi]


func _finish(w) -> Dictionary:
	var guard := 0
	while not w.over and guard < 200000:
		w.step()
		w.events.clear()
		guard += 1
	var out := {"t": snappedf(w.t, 0.01), "winner": w.winner, "shots": w.stat["shots"], "hits": w.stat["hits"],
		"digest": digest(w)}
	w.dispose()
	return out


func _match(case: Array, seed_v: int) -> Dictionary:
	var lv = Maps.get_level(case[0])
	var cfgs: Array = Teams.team(lv, 0, {"n": case[1], "ech": case[3]}) + Teams.team(lv, 1, {"n": case[2], "ech": case[4]})
	var w = World.new()
	w.keep_events = false
	w.setup(lv, _nav(case[0], lv), cfgs, [case[5], case[6]], seed_v)
	return _finish(w)


## Every situation on week one's board, run in order with its suggested plan (sharing
## the roster as the campaign does). Returns key -> result.
func _operations(cseed: int) -> Dictionary:
	var out := {}
	Campaign.read_city_file = false   # Q7: a hashed board may not inherit this machine's watched city
	var c = Campaign.new()
	c.start(cseed)
	for s in c.board:
		var lv = Maps.get_level(int(s["map"]))
		var nv = _nav(int(s["map"]), lv)
		var av: Array = c.available_for(s["id"])
		s["plan"] = Autoplan.suggest(s, av, lv, false, Autoplan.share(c.board, s["id"], av.size()))
		if c.plan_members(s).is_empty():
			s["plan"] = {}
			continue
		var b: Dictionary = Operation.build_planned(s, s["plan"], c.dept, lv, nv)
		var w = World.new()
		w.keep_events = false
		w.setup(lv, nv, b["cfgs"], b["postures"], b["seed"], b["alerts"], b["opts"])
		out["op%d_%s_%s_m%02d" % [cseed, s["id"], s["type"], int(s["map"])]] = _finish(w)
		c.record(s["id"], {})
	return out


func _officer_ids(dept, n: int) -> Array:
	var recs: Array = dept.officers.duplicate()
	recs.sort_custom(func(a, b): return Orders.rank_i(a) > Orders.rank_i(b) or (Orders.rank_i(a) == Orders.rank_i(b) and int(a["xp"]) > int(b["xp"])))
	var out: Array = []
	for r in recs.slice(0, n):
		out.append(r["id"])
	return out


## Q1 (1.28): An element holding a quiet, cleared room past RALLY_QUIET (12 s)
## calms at RALLY_DECAY (0.25/s) down to its trauma/morale floor (stress0).
func _q1_rally_reset(seed_v: int) -> Dictionary:
	var dept = Department.new()
	dept.found(seed_v)
	var lv = Maps.get_level(4)
	var nv = _nav(4, lv)
	var sit := {"id": "Q1", "type": "gang", "seed": seed_v, "named": "", "visibility": 2, "intel": [],
		"occupants": [{"role": "suspect", "ech": "untrained", "room": "BED2", "arms": "pistol", "alert": 0, "flight": 0.0}]}
	var od: Dictionary = Orders.empty_orders()
	od["objs"] = [{"kind": "clear", "rooms": []}]
	od["consolidate"] = "HALL"
	var plan := {"squads": [{"members": _officer_ids(dept, 4), "orders": od, "stage": 0}]}
	var b: Dictionary = Operation.build_planned(sit, plan, dept, lv, nv)
	b["opts"]["time_limit"] = 240.0
	var w = World.new()
	w.keep_events = false
	w.setup(lv, nv, b["cfgs"], b["postures"], b["seed"], b["alerts"], b["opts"])
	var primed := false
	var rally_steps := 0
	var guard := 0
	while not w.over and guard < 200000:
		if not primed and w.teams[0]["cleared"].has("HALL"):
			primed = true
			for o in w.ops:
				if o.team == 0 and o.alive():
					o.ech["stress0"] = 0.05
					o.stress = 0.85
					o.last_stress_t = w.t - World.RALLY_QUIET - 0.5
					o.last_enemy_seen_t = w.t - World.RALLY_QUIET - 0.5
		w.step()
		if primed and rally_steps < 60:
			rally_steps += 1
		w.events.clear()
		guard += 1
	var base := digest(w)
	var out := {"t": snappedf(w.t, 0.01), "winner": w.winner, "shots": w.stat["shots"], "hits": w.stat["hits"],
		"digest": ("%s|primed=%d|rs=%d" % [base, int(primed), rally_steps]).md5_text().substr(0, 16)}
	w.dispose()
	return out


## Q6 (1.29): With less-lethal-first ordered, an armed non-attacking suspect inside
## LESS_FIRST_R (4 m) receives 1 challenge and a less-lethal tool instead of a bullet.
func _q6_less_lethal_first(seed_v: int) -> Dictionary:
	var dept = Department.new()
	dept.found(seed_v)
	var lv = Maps.get_level(4)
	var nv = _nav(4, lv)
	var sit := {"id": "Q6", "type": "gang", "seed": seed_v, "named": "", "visibility": 2, "intel": [],
		"occupants": [{"role": "suspect", "ech": "untrained", "room": "BED2", "arms": "rifle", "alert": 0}]}
	var od: Dictionary = Orders.empty_orders()
	od["objs"] = [{"kind": "clear", "rooms": []}]
	od["less"] = true
	var plan := {"squads": [{"members": _officer_ids(dept, 4), "orders": od, "stage": 0}]}
	var b: Dictionary = Operation.build_planned(sit, plan, dept, lv, nv)
	b["opts"]["time_limit"] = 180.0
	var w = World.new()
	w.keep_events = false
	w.setup(lv, nv, b["cfgs"], b["postures"], b["seed"], b["alerts"], b["opts"])
	var guard := 0
	while not w.over and guard < 200000:
		w.step()
		w.events.clear()
		guard += 1
	var less_n: int = w.incident.less_uses.size() if w.incident != null else 0
	var base := digest(w)
	var out := {"t": snappedf(w.t, 0.01), "winner": w.winner, "shots": w.stat["shots"], "hits": w.stat["hits"],
		"digest": ("%s|less=%d" % [base, less_n]).md5_text().substr(0, 16)}
	w.dispose()
	return out


## Q3 (1.30): Post-operation IA case statement integrity vs. bodycam evidence and
## squadmate witness testimony in Department.apply_result().
func _q3_statement_integrity(seed_v: int) -> Dictionary:
	var dept = Department.new()
	dept.found(seed_v)
	dept.bodycams = true
	var ids := _officer_ids(dept, 4)
	var lead: Dictionary = dept.get_officer(ids[0])
	lead["integrity"] = 10
	var mate: Dictionary = dept.get_officer(ids[1])
	mate["integrity"] = 90
	var lv = Maps.get_level(4)
	var nv = _nav(4, lv)
	var sit := {"id": "Q3", "type": "gang", "seed": seed_v, "named": "", "visibility": 2, "intel": [],
		"occupants": [{"role": "suspect", "ech": "untrained", "room": "LIVING", "arms": "pistol", "alert": 0}]}
	var od: Dictionary = Orders.empty_orders()
	od["objs"] = [{"kind": "clear", "rooms": []}]
	var plan := {"squads": [{"members": ids, "orders": od, "stage": 0}]}
	var b: Dictionary = Operation.build_planned(sit, plan, dept, lv, nv)
	b["opts"]["time_limit"] = 180.0
	var w = World.new()
	w.keep_events = false
	w.setup(lv, nv, b["cfgs"], b["postures"], b["seed"], b["alerts"], b["opts"])
	var guard := 0
	while not w.over and guard < 200000:
		w.step()
		w.events.clear()
		guard += 1
	if w.incident != null:
		w.incident.findings.append({"t": snappedf(w.t, 0.1), "kind": "excessive_force", "by": "A1",
			"place": "the living room", "strength": "video",
			"evidence": {"bodycam": ["A1"], "video": [], "witnesses": [], "heard": 0},
			"text": "%s fired on an unarmed suspect in the living room." % lead["name"]})
	dept.apply_result(w, lv.map_name)
	var ia_parts: Array = []
	for c in dept.cases:
		ia_parts.append("%s|%s|%s|%s|%s|%d" % [c.get("id", ""), c.get("kind", ""), c.get("strength", ""),
			c.get("statement", ""), c.get("testimony", ""), int(lead["integrity"])])
	var base := digest(w)
	var out := {"t": snappedf(w.t, 0.01), "winner": w.winner, "shots": w.stat["shots"], "hits": w.stat["hits"],
		"digest": ("%s|ia=%s" % [base, ";".join(ia_parts)]).md5_text().substr(0, 16)}
	w.dispose()
	return out


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var write := "--write" in args
	var verbose := "--verbose" in args
	var have: Dictionary = {}
	if not write:
		var f := FileAccess.open(FIXTURE, FileAccess.READ)
		if f != null:
			var parsed = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed is Dictionary:
				have = parsed
		if have.is_empty():
			print("no fixture at %s: run with --write to create one" % FIXTURE)
	var results := {}
	var t0 := Time.get_ticks_msec()
	for case in CASES:
		for seed_v in SEEDS:
			var key: String = "m%02d_%dv%d_%s_%s_%s_%d" % [case[0], case[1], case[2], case[3], case[4], case[5], seed_v]
			results[key] = _match(case, seed_v)
	for cs in CAMPAIGN_SEEDS:
		var ops := _operations(cs)
		for k in ops:
			results[k] = ops[k]
	results["q1_rally_reset_1001"] = _q1_rally_reset(1001)
	results["q3_statement_integrity_1001"] = _q3_statement_integrity(1001)
	results["q6_less_lethal_first_1001"] = _q6_less_lethal_first(1001)
	var bad := 0
	var keys: Array = results.keys()
	keys.sort()
	for key in keys:
		var r: Dictionary = results[key]
		if have.is_empty():
			if verbose or write:
				print("  %-44s %s  w%d t=%.1f shots=%d" % [key, r["digest"], r["winner"], r["t"], r["shots"]])
			continue
		var old: Dictionary = have.get("cases", {}).get(key, {})
		if old.is_empty():
			bad += 1
			print("  NEW   %-44s %s" % [key, r["digest"]])
		elif str(old.get("digest", "")) != str(r["digest"]):
			bad += 1
			print("  DIFF  %-44s winner %s -> %s, t %.1f -> %.1f, shots %s -> %s, hits %s -> %s" % [key,
				old.get("winner", "?"), r["winner"], float(old.get("t", 0.0)), float(r["t"]),
				old.get("shots", "?"), r["shots"], old.get("hits", "?"), r["hits"]])
		elif verbose:
			print("  ok    %-44s %s" % [key, r["digest"]])
	if write:
		var g := FileAccess.open(FIXTURE, FileAccess.WRITE)
		if g == null:
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FIXTURE.get_base_dir()))
			g = FileAccess.open(FIXTURE, FileAccess.WRITE)
		if g == null:
			print("could not write %s" % FIXTURE)
			quit(1)
			return
		g.store_string(JSON.stringify({"version": ProjectSettings.get_setting("application/config/version", ""),
			"cases": results}, "  ", true))
		g.close()
		print("wrote %d digests to %s (%d ms)" % [results.size(), FIXTURE, Time.get_ticks_msec() - t0])
		quit()
		return
	print("\n%d case(s), %d changed, %d ms" % [results.size(), bad, Time.get_ticks_msec() - t0])
	if have.is_empty():
		quit()
		return
	if bad == 0:
		print("OK: every seeded case is reproducible.")
		quit()
		return
	print("FAIL: %d case(s) changed. If intended, re-run with --write and read the diff." % bad)
	quit(1)
