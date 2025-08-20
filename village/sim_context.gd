## Immutable "frame" context handed to triggers/effects during a hook.
## Keeps all read/write access funneled through known places (e.g., redirect).
class_name SimContext
extends RefCounted

var hook: StringName
var grid
var villager
var from_pos: Vector2i
var to_pos: Vector2i
var from_house
var to_house
var rng

# per-villager visit memory (read-only here)
var has_visited_to_before: bool = false

func _init(_hook, _grid, _villager, _from: Vector2i, _to: Vector2i, _visited: Dictionary = {}):
	hook = _hook
	grid = _grid
	villager = _villager
	from_pos = _from
	to_pos = _to
	from_house = grid.get_at(_from) if grid.is_inside(_from) else null
	to_house = grid.get_at(_to) if grid.is_inside(_to) else null
	has_visited_to_before = _visited.has(_to)

func reverse_last_step() -> void:
	var delta := to_pos - from_pos
	to_pos = from_pos - delta
	if grid.is_inside(to_pos):
		to_house = grid.get_at(to_pos)
	else:
		to_house = null

func _to_string() -> String:
	return "Ctx(%s %s->%s %s)" % [str(hook), str(from_pos), str(to_pos), villager.to_string()]
