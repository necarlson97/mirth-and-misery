## The board model. Holds Houses in a 2D array, knows bounds, and offers small queries.
class_name VillageGridModel
extends Resource

@export var size: Vector2i

# (Vector2i -> House)
@export var position_to_house := {}
# TODO need to provide clarity here about the difference between
# 'residency' positions and the in-round temporary 'walking' positions
@export var villager_to_position := {}

func _init(s := Vector2i(2, 2)):
	size = s
	for y in range(size[0]):
		var row := []
		for x in range(size[1]):
			var pos = Vector2i(y, x)
			position_to_house[pos] = HouseModel.new(self, pos)

func all_houses() -> Array[HouseModel]:
	var out: Array[HouseModel] = []
	for h: HouseModel in position_to_house.values():
		out.append(h)
	return out
	
func all_villagers() -> Array[VillagerModel]:
	var out: Array[VillagerModel] = []
	for h: VillagerModel in villager_to_position.keys():
		out.append(h)
	return out

func is_inside(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < size.x and p.y < size.y

func get_at(p: Vector2i) -> HouseModel:
	return position_to_house.get(p)

func get_villager_pos(v: VillagerModel) -> Vector2i:
	return villager_to_position[v]

func any_villager_with_tags_at(p: Vector2i, want: Array[StringName], except = null) -> bool:
	if not is_inside(p):
		return false
	for v in get_at(p).visitors:
		if v == except:
			continue
		if v.has_any_tag(want):
			return true
	return false

func place_villager(v: VillagerModel, p: Vector2i) -> void:
	if is_inside(p):
		var house = get_at(p)
		house.visitors.append(v)
		v.walk_to(house)
	else:
		print("Moving outside: %s to %s"%[v, p])
	villager_to_position[v] = p

func remove_villager(v: VillagerModel, p: Vector2i) -> void:
	if is_inside(p):
		var house = get_at(p)
		house.visitors.erase(v)
		villager_to_position.erase(v)

func move_villager(v: VillagerModel, from_pos: Vector2i, to_pos: Vector2i) -> void:
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
	
func place_starting_positions():
	# Start the villagers in their residences (at the start of a round)
	var starting_villagers = villager_starting_positions()
	for v: VillagerModel in starting_villagers.keys():
		var pos:Vector2i = starting_villagers[v]
		place_villager(v, pos) 

func round_start_refresh():
	place_starting_positions()
	for v in all_villagers():
		v.round_start_refresh()

func _to_string() -> String:
	return "VillageGrid(%dx%d)" % [size.x, size.y]
