## Effect = the "action" part of a Rule. It mutates simulation state when run.
class_name BaseEffect
extends RefCounted

func apply(ctx: Object) -> void:
	# Perform the state change (award points, redirect movement, kill unit, etc.)
	push_error("BaseEffect.apply not implemented")

func _to_string() -> String:
	return "<Effect>"
