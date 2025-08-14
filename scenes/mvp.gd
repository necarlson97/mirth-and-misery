extends Node2D

## MVP scene bootstrap:
## - builds a 3x3 VillageGrid (logic)
## - spawns a single Goblin token
## - allows click+drag to place the villager as the house *resident*
## - keeps model (house.resident) in sync with token drop
## Night play is not started here; we’re just proving the day-phase UX.
var rng: Rng
var grid: VillageGrid

@onready var board_view: BoardView = $BoardView
@onready var tokens_root: Node2D = $Tokens

# residency map (day): villager -> cell
var resident_pos_by_villager := {}

func _ready():
	# Grid setup
	rng = Rng.new()
	grid = VillageGrid.new(3, 3, rng)
	board_view.grid_size = grid.size

	# Create a villager (Klobly)
	var k = Goblins.Klobly.new()
	# Place as *resident* at center for now
	var start := Vector2i(1, 1)
	_set_resident(k, start)

	# Spawn token
	var tok := VillagerToken.new()
	tokens_root.add_child(tok)
	tok.board_view = board_view
	tok.villager = k
	tok.set_to_cell(start)
	tok.icon_color = Color(0.8, 1.0, 0.6)
	tok.connect("dropped_on", _on_token_dropped)

func _on_token_dropped(cell: Vector2i, token: VillagerToken) -> void:
	# When a token is dropped on a cell during the day, we update the model's *occupant*
	_set_resident(token.villager, cell)

func _set_resident(v, cell: Vector2i) -> void:
	# Clear previous resident link if any
	if resident_pos_by_villager.has(v):
		var prev = resident_pos_by_villager[v]
		var prev_house = grid.get_house(prev)
		if prev_house.resident == v:
			prev_house.resident = null

	# Set new resident
	resident_pos_by_villager[v] = cell
	var h = grid.get_house(cell)
	h.resident = v

	# Optional: reflect something in visuals later (icons on houses, etc.)
