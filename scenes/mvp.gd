extends Node2D

func _ready() -> void:
	# For now, just place a random villager and watch 'em go
	var rng = Rng.new()
	var vg = VillageGrid.new(3, 3, rng)
	var sim = Sim.new(vg, rng)

	var k = Goblins.Klobly.new()
	vg.place_villager(k, Vector2i(1, 1))

	var trace = sim.run_night(64)
	print(trace.dump())
