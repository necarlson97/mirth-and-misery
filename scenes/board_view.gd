extends Node2D
class_name BoardView

## BoardView draws the grid and handles mouse→cell hit-testing.
## It does *not* change the model; it just tells others which house the cursor is over.

signal hover_cell_changed(cell_pos: Vector2i)

var cell_size := Vector2(64, 64) # TODO: expose in inspector if desired
var grid_origin := Vector2.ZERO  # where (0,0) draws
var grid_size := Vector2i(3, 3)  # will be set by mvp.gd at runtime

var _hover_cell := Vector2i(-1, -1)

func _ready():
	set_process(true)

func _process(_dt):
	var mouse := get_global_mouse_position()
	var cell := world_to_cell(mouse)
	if cell != _hover_cell:
		_hover_cell = cell
		emit_signal("hover_cell_changed", _hover_cell)

func cell_to_world(cell: Vector2i) -> Vector2:
	# Top-left anchor of the cell for token placement/snapping
	return grid_origin + Vector2(cell.x * cell_size.x, cell.y * cell_size.y)

func world_to_cell(pos: Vector2) -> Vector2i:
	var local := pos - grid_origin
	var cx := int(floor(local.x / cell_size.x))
	var cy := int(floor(local.y / cell_size.y))
	return Vector2i(cx, cy)

func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y

func _draw():
	# draw grid
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var tl := cell_to_world(Vector2i(x, y))
			var rect := Rect2(tl, cell_size)
			draw_rect(rect, Color(0.1, 0.1, 0.1, 0.0), false, 1.0)
	# draw hover highlight
	if in_bounds(_hover_cell):
		var tl2 := cell_to_world(_hover_cell)
		draw_rect(Rect2(tl2, cell_size), Color(1, 1, 1, 0.1), true)
