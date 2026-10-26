extends SceneTree
## Compile check: loads every script so parse errors surface.
func _init() -> void:
	var dirs := ["res://scripts/sim", "res://scripts/data", "res://scripts/maps", "res://scripts/view", "res://scripts/ui", "res://scripts", "res://scripts/city", "res://scripts/campaign"]
	var failures := 0
	for d in dirs:
		var da := DirAccess.open(d)
		if da == null:
			continue
		for f in da.get_files():
			if f.ends_with(".gd"):
				var s = load(d + "/" + f)
				if s == null:
					failures += 1
					print("FAILED ", d, "/", f)
	print("check done" if failures == 0 else "check done (%d failed)" % failures)
	quit(1 if failures > 0 else 0)
