extends SceneTree
## Compile check: loads every script so parse errors surface.
## Exits 1 when any script fails to load (ROADMAP 1.01). The runner could already
## catch this by scanning the log for "FAILED"; it now has the exit code too, so
## a build can fail on this suite without the scan safety net.
func _init() -> void:
	var dirs: Array[String] = ["res://scripts/sim", "res://scripts/data", "res://scripts/maps", "res://scripts/view", "res://scripts/ui", "res://scripts", "res://scripts/city", "res://scripts/campaign"]
	var loaded := 0
	var failed := 0
	for d in dirs:
		var da: DirAccess = DirAccess.open(d)
		if da == null:
			continue
		for f in da.get_files():
			if f.ends_with(".gd"):
				var s: Resource = load(d + "/" + f)
				if s == null:
					print("FAILED ", d, "/", f)
					failed += 1
				else:
					loaded += 1
	print("check done: %d loaded, %d failed" % [loaded, failed])
	quit(1 if failed > 0 else 0)
