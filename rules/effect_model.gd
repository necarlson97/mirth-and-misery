## Effect = the "action" part of a Rule. It mutates simulation state when run.
class_name EffectModel
extends RefCounted

func apply(ctx: SimContext, rule: RuleModel) -> void:
	# Perform the state change (award points, redirect movement, kill unit, etc.)
	push_error("EffectModel.apply not implemented")

func _to_string() -> String:
	return "<Effect>"
