extends Node2D

func _ready() -> void:
	# For now, just place a random villager and watch 'em go
	var rng = Rng.new()
	var vg = VillageGrid.new(3, 3, rng)
	var sim = Sim.new(vg, rng)
	
	var klobly = Goblins.Klobly.new()
	print("Starting mvp run with: %s" % klobly)
	var trace = sim.run_single_walker(klobly, Vector2i(1, 1))
	print(trace.dump())
