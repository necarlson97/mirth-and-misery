extends Control

@onready var views_overlay: Control = $ViewsOverlay
@export var grid_container: GridContainer;

@export var house_cell_prefab: PackedScene;

@export var grid_size = Vector2i(3, 4)

var grid = VillageGridModel.new(grid_size)
var sim = Sim.new(grid)

func _ready():	
	# Populate the grid with 
	for house in grid.all_houses():
		var hv = house.get_view()
		grid_container.add_child(hv)

	# Spawn one view for demo; in practice iterate your residents
	var test_villagers = [
		Wanda.new(),
		Klobly.new(),
		Baroba.new(),
	]
	
	# Snap to some starting cell (e.g., 1,1)
	var i=0
	for tv in test_villagers:
		views_overlay.add_child(tv.get_view()) # Spawn their view
		tv.resettle(grid.get_at(Vector2i(i, i)))
		i += 1

func start_night():
	var run_shapshot = sim.run_round()
	view_night(run_shapshot)

func view_night(run_shapshot: RoundSnapshot):
	# handle the logic for iterating over a round's snapshot ticks,
	# performing all the animations and whatnot
	
	start_replay()
	
	print("Replaying visuals for night:")
	for tick in run_shapshot.ticks:
		print("Replaying %s"%tick)
		var grid = tick.starting_state
		for villager in grid.all_villagers():
			print("  villager: %s"%villager)
			var pos = grid.get_villager_pos(villager)
			var house = grid.get_at(pos)
			
			villager.walk_to(house)
			await get_tree().create_timer(0.1).timeout
			
	
	end_replay()
	
func start_replay():
	# TODO disable buttons, disable click+drag, set dial and background to nighttime, etc
	pass
	
func end_replay():
	# TODO reenable buttons, disable click+drag, set dial and background to daytime, etc
	await get_tree().create_timer(0.5).timeout
	grid.place_starting_positions()
	pass
	
	
func _on_button_pressed() -> void:
	start_night()
