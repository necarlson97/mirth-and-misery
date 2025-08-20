## The board. Holds Houses in a 2D array, knows bounds, and offers small queries.
class_name VillageGrid
extends RefCounted

var size: Vector2i
var cells: Array # 2D [y][x] storing House
# TODO should we instead store as: (Vector2i -> House)?
# var cell_pos_to_house := {}

# Easy backref to get villager position
var villager_to_position := {}

func _init(w: int, h: int):
	size = Vector2i(w, h)
	cells = []
	for y in range(h):
		var row := []
		for x in range(w):
			# Default arrow: east; tags empty for MVP
			row.append(House.new(self, Vector2i(y, x)))
		cells.append(row)

func all_houses() -> Array[House]:
	var out: Array[House] = []
	for row in cells:
		out.append_array(row)
	return out

func is_inside(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < size.x and p.y < size.y

func get_at(p: Vector2i) -> House:
	return cells[p.y][p.x]

func get_villager_pos(v: BaseVillager) -> Vector2i:
	return villager_to_position[v]

func arrow_of(p: Vector2i) -> Vector2i:
	return get_at(p).arrow

func any_villager_with_tags_at(p: Vector2i, want: Array[StringName], except = null) -> bool:
	if not is_inside(p):
		return false
	for v in get_at(p).visitors:
		if v == except:
			continue
		if v.has_any_tag(want):
			return true
	return false

func place_villager(v: BaseVillager, p: Vector2i) -> void:
	assert(is_inside(p))
	get_at(p).visitors.append(v)
	villager_to_position[v] = p

func remove_villager(v: BaseVillager, p: Vector2i) -> void:
	if is_inside(p):
		get_at(p).visitors.erase(v)
		villager_to_position.erase(v)

func move_villager(v: BaseVillager, from_pos: Vector2i, to_pos: Vector2i) -> void:
	remove_villager(v, from_pos)
	place_villager(v, to_pos)
	
func is_edge(p: Vector2i) -> bool:
	return p.x == 0 or p.y == 0 or p.x == size.x - 1 or p.y == size.y - 1
	
func is_outside(p: Vector2i) -> bool:
	return p.x < 0 or p.y < 0 or p.x > size.x - 1 or p.y > size.y - 1
	
func villager_starting_positions() -> Dictionary:
	# Returns { villager: Vector2i }
	var out := {}
	for h in all_houses().filter(func(h): return h.resident != null):
		out[h.resident] = h.cell_pos
	return out

func _to_string() -> String:
	return "VillageGrid(%dx%d)" % [size.x, size.y]
