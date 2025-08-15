## Movement profiles compute the *next intended* destination (to_pos) given arrows,
## randomness, and profile parameters. Effects may then redirect that intent.
class_name Walks
extends RefCounted

class BaseWalk:
	func choose_next(from_pos: Vector2i, grid) -> Vector2i:
		# Return the intended next position (may be outside grid; AttemptExit hook will fire).
		push_error("MovementProfile.choose_next not implemented")
		return from_pos

class Orthogonal extends BaseWalk:
	## Choose among N/E/S/W with given weights (0..1).
	## Unnormalized is fine; we normalize.
	var w_n: float
	var w_e: float
	var w_s: float
	var w_w: float

	func _init(n: float, e: float, s: float, w: float):
		w_n = n; w_e = e; w_s = s; w_w = w

	func choose_next(from_pos: Vector2i, grid) -> Vector2i:
		var dirs = [
			Vector2i(0, -1),
			Vector2i(1, 0),
			Vector2i(0, 1),
			Vector2i(-1, 0),
		]
		var weights: Array[float] = [w_n, w_e, w_s, w_w]
		var idx = grid.rng.weighted_index(weights)
		return from_pos + dirs[idx]

	func _to_string() -> String:
		return "Orthogonal(%.2f,%.2f,%.2f,%.2f)" % [w_n, w_e, w_s, w_w]
