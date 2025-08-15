extends Node2D
class_name VillagerToken

## VillagerToken is the draggable icon for a villager during the *day*.
## It mirrors: which villager it represents, and which *resident* cell it’s snapped to.
## It does not run the sim; it emits a signal when dropped onto a house.

signal dropped_on(cell_pos: Vector2i, token: VillagerToken)

var villager                        # BaseVillager (logic object)
var board_view: BoardView           # set by caller
var icon_color := Color(0.6, 0.9, 1.0)
var radius := 20.0

var _dragging := false
var _drag_offset := Vector2.ZERO
var _current_cell := Vector2i(-1, -1)

func _ready():
	set_process_input(true)

func set_to_cell(c: Vector2i):
	_current_cell = c
	global_position = board_view.cell_to_world(c) + board_view.cell_size * 0.5

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _hit_mouse():
				_dragging = true
				_drag_offset = global_position - get_global_mouse_position()
				get_viewport().set_input_as_handled()
			elif not event.pressed and _dragging:
				_dragging = false
				# Snap to nearest in-bounds cell and emit dropped_on
				var cell := board_view.world_to_cell(get_global_mouse_position())
				if board_view.in_bounds(cell):
					set_to_cell(cell)
					emit_signal("dropped_on", cell, self)
				else:
					# snap back to previous cell
					set_to_cell(_current_cell)
	if event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() + _drag_offset

func _hit_mouse() -> bool:
	var mouse := get_global_mouse_position()
	return mouse.distance_to(global_position) <= radius

func _draw():
	# simple circle token
	draw_circle(Vector2.ZERO, radius, icon_color)
	# small mark to see orientation
	draw_line(Vector2(-radius*0.5, 0), Vector2(radius*0.5, 0), Color(0,0,0), 2)

func _to_string() -> String:
	return "VillagerToken(%s at %s)" % [villager.to_string(), str(_current_cell)]
