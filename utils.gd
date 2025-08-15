class_name Utils

static func to_sn(value) -> StringName:
	# Coerce a String or StringName into a StringName (idempotent).
	# StringNames are designed for fast equality checks - exactly what
	# we are using tags for
	return value if value is StringName else StringName(value)

static func as_list(x) -> Array:
	# Helpful for functions that we want to be able to pass either a single
	# element or a list of elements
	return x if x is Array else [x]

static func as_sn_list(x) -> Array[StringName]:
	var out: Array[StringName] = []
	for e in as_list(x):
		out.append(to_sn(e))
	return out

# Helpers for Control-space coordinate conversion
static func global_to_local_in(node: Control, global_point: Vector2) -> Vector2:
	var inv := node.get_global_transform_with_canvas().affine_inverse()
	return inv * global_point

static func local_to_global_from(node: Control, local_point: Vector2) -> Vector2:
	return node.get_global_transform_with_canvas() * local_point

# Rng
static var rng := RandomNumberGenerator.new()
static func seed_with(s: int) -> void:
	rng.seed = s
	
static func weighted_index(weights: Array[float]) -> int:
	# Returns an index picked proportionally to weights (ignores <=0).
	var sum := 0.0
	for w in weights:
		if w > 0.0:
			sum += w
	if sum <= 0.0:
		return 0
	var roll := randf() * sum
	var acc := 0.0
	for i in weights.size():
		var w = max(weights[i], 0.0)
		acc += w
		if roll <= acc:
			return i
	return weights.size() - 1
