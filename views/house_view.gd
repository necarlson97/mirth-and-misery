class_name HouseView
extends Control

## UI cell for a house in the grid. Accepts Villagerview drops.
## Emits resettle_villager so the model updates the resident.

signal resettle_villager(villager, cell_pos: Vector2i)

var house: HouseModel
@onready var dock: Control = $Dock
@onready var arrow: TextureRect = $Arrow

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	assert(dock != null)
	
	# Keep pivot centered whenever size changes (cell or icon).
	_center_pivot(arrow)
	resized.connect(func(): _center_pivot(arrow))
	arrow.resized.connect(func(): _center_pivot(arrow))

	update_direction()
	
	$Label.text = "%s %s" % [get_cell_pos(), house.arrow]

func _center_pivot(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	
func update_direction():
	var dir := house.arrow
	# Convert direction vector to radians (0 = right, +π/2 = down, -π/2 = up)
	arrow.rotation = atan2(float(-dir.y), float(dir.x))

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# We accept ItemDrag payloads originating from a Villagerview
	#return data is ItemDrag and data.source is Villagerview
	# TODO
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var drag := data as ItemDrag
	var view: VillagerView = drag.source

	# Mark accepted so the view doesn't snap back in its completion handler
	drag.destination = self

	# Update view's logical cell and tell the game state
	view.villager.resettle(house)

func get_cell_pos() -> Vector2i:
	return house.cell_pos

func _to_string() -> String:
	return "HouseCell(%s)" % [str(get_cell_pos())]
