extends Control

@onready var tokens_overlay: Control = $TokensOverlay
@export var grid_container: GridContainer;

@export var house_cell_prefab: PackedScene;

@export var grid_size = Vector2i(3, 4)

var grid = VillageGrid.new(grid_size[1], grid_size[0])
var sim = Sim.new(grid)

func _ready():	
	# Populate the grid with 
	for house in grid.all_houses():
		var hc = house.get_cell()
		grid_container.add_child(hc)

	# Spawn one token for demo; in practice iterate your residents
	var test_villager = Klobly.new()
	var tok = test_villager.get_token()
	tokens_overlay.add_child(tok)
	
	# Snap to some starting cell (e.g., 1,1)
	Utils.defer_once(func(): test_villager.resettle(grid.get_at(Vector2i(1, 1))))
	
	print("Villager name %s" % test_villager)

func start_night():
	print("Starting night")
	var trace = sim.run_night()
	$LogOutput.text = trace.dump()
	
func _on_button_pressed() -> void:
	start_night()
