## Immutable "frame" context handed to triggers/effects during a hook.
## Keeps all read/write access funneled through known places (e.g., redirect).
class_name SimContext
extends RefCounted

var hook: StringName
var grid: VillageGrid
var villager: BaseVillager
var from_pos: Vector2i
var to_pos: Vector2i
var from_house: House
var to_house: House
var rng: Rng
var _redirect_delta: Vector2i = Vector2i.ZERO

func _init(_hook: StringName, _grid, _villager, _from: Vector2i, _to: Vector2i, _rng):
	hook = _hook
	grid = _grid
	villager = _villager
	from_pos = _from
	to_pos = _to
	from_house = grid.get_house(_from) if grid.is_inside(_from) else null
	to_house = grid.get_house(_to) if grid.is_inside(_to) else null
	rng = _rng

func redirect() -> SimContext:
	# Returns a tiny helper with methods effects can call (e.g., reverse_last_step).
	return self

func reverse_last_step() -> void:
	# Reverse the intent vector: to_pos = from_pos - (to_pos - from_pos)
	var delta := to_pos - from_pos
	_redirect_delta = -delta
	to_pos = from_pos + _redirect_delta
	to_house = grid.get_house(to_pos) if grid.is_inside(to_pos) else null

func emit_redirect() -> void:
	# Placeholder: in future we can record into trace here if needed.
	pass

func _to_string() -> String:
	return "Ctx(%s %s->%s %s)" % [str(hook), str(from_pos), str(to_pos), villager.to_string()]
