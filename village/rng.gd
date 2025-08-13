## Thin wrapper so the core can be seeded and deterministic.
class_name Rng
extends RefCounted

var _rng := RandomNumberGenerator.new()

func seed_with(s: int) -> void:
	_rng.seed = s

func randf() -> float:
	return _rng.randf()

func randi_range(a: int, b: int) -> int:
	return _rng.randi_range(a, b)

func weighted_index(weights: Array[float]) -> int:
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
