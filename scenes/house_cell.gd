extends Control
class_name HouseCell

## UI cell for a house in the grid. Accepts VillagerToken drops.
## Emits resettle_villager so the model updates the resident.

signal resettle_villager(villager, cell_pos: Vector2i)

var house: House
@onready var dock: Control = $Dock

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(96, 96)
	mouse_default_cursor_shape = CURSOR_POINTING_HAND

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

	# Snap the token visually to this cell (center in overlay coords)
	var overlay: Control = token.get_parent()
	var center := get_global_rect().get_center()
	token.position = center - token.size * 0.5

	# Update token's logical cell and tell the game state
	token.villager.resettle(house)

func get_cell_pos() -> Vector2i:
	return house.cell_pos

func _to_string() -> String:
	return "HouseCell(%s)" % [str(get_cell_pos())]
