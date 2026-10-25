extends SceneTree
## Profile: where the time goes in a big fight.
##   godot --headless --path . -s res://tests/perf.gd -- --map=10 --na=20 --nb=20 --t=60 --pa=hunt --pb=hunt
const Maps = preload("res://scripts/maps/registry.gd")
const Nav = preload("res://scripts/sim/nav.gd")
const World = preload("res://scripts/sim/world.gd")
const Teams = preload("res://tests/teams.gd")


func _init() -> void:
	var opt := {"map": "10", "na": "20", "nb": "20", "t": "60", "pa": "assault", "pb": "hold", "a": "sof", "b": "militia", "seed": "77"}
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=")
		if kv.size() == 2:
			opt[kv[0]] = kv[1]
	var lv = Maps.get_level(Maps.index_of(opt["map"]))
	var nav = Nav.new()
	nav.build(lv)
	var w = World.new()
	w.keep_events = false
	w.profiling = true
	var cfgs: Array = Teams.team(lv, 0, {"n": int(opt["na"]), "ech": opt["a"]}) + Teams.team(lv, 1, {"n": int(opt["nb"]), "ech": opt["b"]})
	w.setup(lv, nav, cfgs, [opt["pa"], opt["pb"]], int(opt["seed"]))
	if opt.has("fine"):
		w.brain.fine = true
	var mem0 := Performance.get_monitor(Performance.MEMORY_STATIC)
	var t0 := Time.get_ticks_usec()
	var ticks := 0
	var sc0: int = w.geom.sight_calls
	var pc0: int = nav.path_calls
	while not w.over and w.t < float(opt["t"]):
		w.step()
		ticks += 1
	var us := Time.get_ticks_usec() - t0
	var mem1 := Performance.get_monitor(Performance.MEMORY_STATIC)
	var ms_per_tick := us / 1000.0 / maxf(1.0, float(ticks))
	var mem_mb := mem1 / (1024.0 * 1024.0)
	var mem_delta_mb := (mem1 - mem0) / (1024.0 * 1024.0)
	print("%d ticks, %.2f ms/tick, sim %.1f s, realtime factor %.1fx, static mem %.1f MiB (delta %+.1f MiB)" % [
		ticks, ms_per_tick, w.t, w.t / maxf(0.0001, us / 1e6), mem_mb, mem_delta_mb])
	for k in w.prof:
		print("  %-10s %6.2f ms/tick" % [k, w.prof[k] / 1000.0 / maxf(1.0, float(ticks))])
	print("  sight checks/tick %.0f, path calls/tick %.2f (%.2f ms/tick)" % [
		float(w.geom.sight_calls - sc0) / maxf(1.0, float(ticks)),
		float(nav.path_calls - pc0) / maxf(1.0, float(ticks)),
		nav.path_us / 1000.0 / maxf(1.0, float(ticks))])
	var alive := [0, 0]
	for o in w.ops:
		if o.alive():
			alive[o.team] += 1
	print("  alive %d/%d at %.1f s" % [alive[0], alive[1], w.t])
	w.dispose()
	var max_ms := float(opt.get("max_ms", "16.6"))
	var ok: bool = ticks > 0 and ms_per_tick <= max_ms and mem_delta_mb < 128.0
	print("GATE perf: %.2f ms/tick (<=%.1f ms), mem delta %+.1f MiB (<128.0 MiB) -> %s" % [
		ms_per_tick, max_ms, mem_delta_mb, "PASS" if ok else "FAIL"])
	quit(0 if ok else 1)
