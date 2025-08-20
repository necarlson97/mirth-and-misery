class SimTrace extends RefCounted:
	## A complete record of one night, ready to replay by the UI.
	## Minimal: just IDs, positions, and effect payloads. No node refs.

	const VERSION := 1

	var seed := 0                       # RNG seed used for this night
	var grid_size := Vector2i.ZERO
	var villager_ids: Array[StringName] = []      # stable ids in a consistent order
	var start_positions: Dictionary = {}          # id -> Vector2i (resident start)
	var ticks: Array[TraceTick] = []              # ordered list of ticks
	var summary := {}                             # optional: totals, deaths, etc.

	func add_tick(tick: TraceTick) -> void:
		ticks.append(tick)

	func _to_string() -> String:
		return "SimTrace(v=%s, ticks=%d)" % [VERSION, ticks.size()]

class TraceTick extends RefCounted:
	## One “round” of simultaneous moves, then effects.
	var index := 0
	var moves: Array[MoveEvent] = []      # all moves committed this tick
	var effects: Array[EffectEvent] = []  # scoring/sleep/death, etc.

	func _to_string() -> String:
		return "Tick(%d, moves=%d, effects=%d)" % [index, moves.size(), effects.size()]

class MoveEvent extends RefCounted:
	## id: villager id, from→to: logical grid coordinates
	var id: StringName
	var from: Vector2i
	var to: Vector2i

	func _init(_id: StringName, _from: Vector2i, _to: Vector2i):
		id = _id
		from = _from
		to = _to

	func _to_string() -> String:
		return "Move(%s: %s -> %s)" % [String(id), str(from), str(to)]

class EffectEvent extends RefCounted:
	## Generic effect payload. type drives UI, payload is small dict.
	var type: StringName               # e.g., &"gain", &"sleep", &"death", &"redirect", &"flag"
	var id: StringName                 # villager id primarily affected (optional for global)
	var at: Vector2i = Vector2i(-1, -1)# where it occurred (if spatial)
	var data := {}                     # small dict: {tears:=1, laughs:=0, reason:=&"Edge"}

	func _init(t: StringName, v_id: StringName, p := Vector2i(-1, -1), d := {}):
		type = t
		id = v_id
		at = p
		data = d

	func _to_string() -> String:
		return "Effect(%s, %s, %s, %s)" % [String(type), String(id), str(at), str(data)]
