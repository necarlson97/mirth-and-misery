## The board. Holds Houses in a 2D array, knows bounds, and offers small queries.
class_name VillageGrid
extends RefCounted

var size: Vector2i
var cells: Array # 2D [y][x] storing House
var rng # Injected RNG (see rng.gd)

func _init(w: int, h: int, _rng):
	size = Vector2i(w, h)
	rng = _rng
	cells = []
	for y in range(h):
		var row := []
		for x in range(w):
			# Default arrow: east; tags empty for MVP
			row.append(House.new(Vector2i(x, y), Vector2i(1, 0)))
		cells.append(row)

func is_inside(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < size.x and p.y < size.y

func get_house(p: Vector2i) -> House:
	return cells[p.y][p.x]

func arrow_of(p: Vector2i) -> Vector2i:
	return get_house(p).arrow

func any_villager_with_tags_at(p: Vector2i, want: Array[StringName], except = null) -> bool:
	if not is_inside(p):
		return false
	for v in get_house(p).contents:
		if v == except:
			continue
		if v.has_any_tag(want):
			return true
	return false

func move_villager(v: BaseVillager, from_pos: Vector2i, to_pos: Vector2i) -> void:
	# Remove from current house and place into next (no animations here).
	var from_house := get_house(from_pos)
	var to_house := get_house(to_pos)
	from_house.visitors.erase(v)
	to_house.visitors.append(v)

func _to_string() -> String:
	return "VillageGrid(%dx%d)" % [size.x, size.y]
