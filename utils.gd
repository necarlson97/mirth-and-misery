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
