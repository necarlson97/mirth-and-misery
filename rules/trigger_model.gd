## Trigger = the "condition" part of a Rule. It decides *if* an effect should run
## when a particular hook fires. Triggers should be pure and side-effect free.
class_name TriggerModel
extends RefCounted

func check(source: VillagerModel, ctx: SimContext) -> bool:
	# Return true if the effect should fire given this context.
	# The context carries data like villager, from_house, to_house, grid, rng, etc.
	push_error("BaseTrigger.check not implemented")
	return false
	
func round_start_refresh():
	# Perorm any state refresh stuff
	pass

func default_hook() -> StringName:
	# Empty by default; subclasses can override to suggest a hook.
	return StringName()

func _to_string() -> String:
	# TODO does this return 'BaseTrigger' (parent class),
	# or the desired subclass name?
	return "Trigger: %s" % get_class()
