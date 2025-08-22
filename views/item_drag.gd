extends RefCounted
class_name ItemDrag

## Simple data object carried through the drag & drop lifecycle.
## We use the preview's `tree_exiting` to know the drag finished (accepted or rejected).
signal drag_completed(data: ItemDrag)

# Can be Villagerview, later commandments, whatever else
var source: Control
var destination: Control = null
var preview: Control
var start_cell: Vector2i

func _init(_source: Control, _start_cell: Vector2i):
	source = _source
	start_cell = _start_cell
	
	# Duplicate the node (shallow is enough for visuals)
	preview = Control.new()
	var ghost = source.duplicate() as Control
	preview.add_child(ghost)
	ghost.size = source.size
	ghost.position = -0.5 * ghost.size
	preview.modulate = Color(0.5, 0.5, 0.5, 0.5)
	
	ghost.set_anchors_preset(Control.PRESET_TOP_LEFT)
	
	preview.tree_exiting.connect(_on_preview_tree_exiting)

func _on_preview_tree_exiting() -> void:
	drag_completed.emit(self)

func _to_string() -> String:
	return "ItemDrag(src=%s, dst=%s, start=%s)" % [str(source), str(destination), str(start_cell)]
