extends Control
class_name VillagerToken

## Draggable visual for a villager during the *day*.
## Parent should be TokensOverlay (a free-layout Control covering the board area).

var villager: BaseVillager

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CURSOR_DRAG

func _get_drag_data(_at_position: Vector2) -> Variant:
	# Build a small preview
	# TODO replace with real visual - there has to be a standard way to do this?
	var preview := ColorRect.new()
	preview.color = Color(0.8, 1.0, 0.6, 0.2)
	preview.size = size
	set_drag_preview(preview)

	# Build our payload object and listen for completion to handle rejections
	var drag := ItemDrag.new(self, preview, get_residence().cell_pos)
	drag.drag_completed.connect(_on_drag_completed)

	return drag

func _on_drag_completed(drag: ItemDrag) -> void:
	# If no destination accepted the drop, snap back to the start cell.
	if drag.destination == null:
		# Expect the scene to give us a way to resolve a cell Control from Vector2i.
		# For MVP, we emit a signal or call back into a manager to do the snapping.
		# Here we just emit; your scene script can find the HouseCell and call snap_to_cell.
		print("Dragged to nothing")
	print("Dragged %s " % drag)

func get_residence() -> House:
	return villager.residence
	
func get_house_cell() -> HouseCell:
	return get_residence().get_cell()

func dock_to(dock: Control):
	# Move to dock control position (and parent bc of resizing and whatnot)
	if dock == null:
		print("Skipping dock %s to null" % self)
		return
	print("Before size %s (%s)" % [size, dock.size])
	reparent(dock)
	position = Vector2.ZERO
	print("After size %s" % size)

func _to_string() -> String:
	return "VillagerToken(%s @ %s)" % [villager, get_residence()]
