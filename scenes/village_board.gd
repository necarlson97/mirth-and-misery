extends Control

@onready var tokens_overlay: Control = $TokensOverlay
@export var grid_container: GridContainer;

@export var house_cell_prefab: PackedScene;

@export var grid_size = Vector2i(3, 4)

func _ready():	
	# Populate the grid with 
	for y in range(grid_size[0]):
		for x in range(grid_size[1]):
			var house = House.new(Vector2i(x, y))
			var hc = house.get_cell()
			grid_container.add_child(hc)

	# Spawn one token for demo; in practice iterate your residents
	var test_villager = Goblins.Klobly.new()
	var tok = test_villager.get_token()
	tokens_overlay.add_child(tok)
	
	# Snap to some starting cell (e.g., 1,1)
	Utils.defer_once(func(): test_villager.resettle(House.get_at(Vector2i(1, 1))))
	print("Villager token at: %s %s" % [tok, tok.global_position])
