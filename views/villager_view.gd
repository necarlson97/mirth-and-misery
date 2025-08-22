extends Control
class_name VillagerView

## Draggable visual for a villager during the *day*.
## Parent should be viewsOverlay (a free-layout Control covering the board area).

var villager: VillagerModel

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = CURSOR_DRAG
	
	if villager:
		var path := "res://assets/villagers/%s.png" % villager.to_string()
		var tex = ResourceLoader.load(path, "Texture2D")
		if tex is Texture2D:
			$TextureRect.texture = tex

func _get_drag_data(_at_position: Vector2) -> Variant:
	# Build our payload object and listen for completion to handle rejections
	var drag := ItemDrag.new(self, get_residence().cell_pos)
	set_drag_preview(drag.preview)
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

func get_residence() -> HouseModel:
	return villager.residence
	
func get_house_view() -> HouseView:
	return get_residence().get_view()

func dock_to(dock: Control):
	# Move to dock control position (and parent bc of resizing and whatnot)
	if dock == null:
		print("Skipping dock %s to null" % self)
		return
	reparent(dock)
	position = Vector2.ZERO

func _to_string() -> String:
	return "Villagerview(%s @ %s)" % [villager, get_residence()]

func _process(delta: float) -> void:
	# TODO not sure if this is the best way to do this, just testing
	if not villager: return 
		
	if villager.is_sleeping:
		modulate = Color(0.8, 0.8, 0.8, 1.0)
	else:
		modulate = Color(0.8, 0.8, 0.8, 1.0)
