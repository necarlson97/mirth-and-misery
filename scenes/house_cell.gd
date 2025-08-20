extends Control
class_name HouseCell

## UI cell for a house in the grid. Accepts VillagerToken drops.
## Emits resettle_villager so the model updates the resident.

signal resettle_villager(villager, cell_pos: Vector2i)

var house: House
@onready var dock: Control = $Dock
@onready var arrow: TextureRect = $VBoxContainer/Control/Arrow

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	assert(dock != null)
	
	update_direction()
	
	# Keep pivot centered whenever size changes (cell or icon).
	_center_pivot(arrow)
	resized.connect(func(): _center_pivot(arrow))
	arrow.resized.connect(func(): _center_pivot(arrow))

	update_direction()

func _center_pivot(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	
func update_direction():
	var dir := house.arrow
	# Convert direction vector to radians (0 = right, +π/2 = down, -π/2 = up)
	arrow.rotation = atan2(float(dir.y), float(dir.x))

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# We accept ItemDrag payloads originating from a VillagerToken
	#return data is ItemDrag and data.source is VillagerToken
	# TODO
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var drag := data as ItemDrag
	var token: VillagerToken = drag.source

	# Mark accepted so the token doesn't snap back in its completion handler
	drag.destination = self

	# Update token's logical cell and tell the game state
	token.villager.resettle(house)

func get_cell_pos() -> Vector2i:
	return house.cell_pos

func _to_string() -> String:
	return "HouseCell(%s)" % [str(get_cell_pos())]
