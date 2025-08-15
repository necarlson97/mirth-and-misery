## Simple orthogonal directions for House arrows.
class_name Direction
const D = {
	N = Vector2i(0, -1),
	E = Vector2i(1, 0),
	S = Vector2i(0, 1),
	W = Vector2i(-1, 0),
}
const ORDER = [D.N, D.E, D.S, D.W]

static func rand() -> Vector2i:
	return ORDER[Utils.rng.randi() % ORDER.size()]
