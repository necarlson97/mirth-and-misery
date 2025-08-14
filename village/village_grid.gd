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
	for v in get_house(p).visitors:
		if v == except:
			continue
		if v.has_any_tag(want):
			return true
	return false


func place_villager(v: BaseVillager, p: Vector2i) -> void:
	assert(is_inside(p))
	get_house(p).visitors.append(v)

func remove_villager(v: BaseVillager, p: Vector2i) -> void:
	if is_inside(p):
		get_house(p).visitors.erase(v)

func move_villager(v: BaseVillager, from_pos: Vector2i, to_pos: Vector2i) -> void:
	remove_villager(v, from_pos)
	place_villager(v, to_pos)
	
func is_edge(p: Vector2i) -> bool:
	return p.x == 0 or p.y == 0 or p.x == size.x - 1 or p.y == size.y - 1
	
func is_outside(p: Vector2i) -> bool:
	return p.x < 0 or p.y < 0 or p.x > size.x - 1 or p.y > size.y - 1
	
func villagers_and_positions() -> Dictionary:
	# Returns { villager: Vector2i }
	var out := {}
	for y in range(size.y):
		for x in range(size.x):
			var h: House = cells[y][x]
			for v in h.visitors:
				out[v] = h.pos
	return out

func _to_string() -> String:
	return "VillageGrid(%dx%d)" % [size.x, size.y]
