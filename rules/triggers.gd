## A small standard library of common triggers.
## Triggers *compose* (And/Or/Not) so we can nest logic without new classes each time.
class_name Triggers
const H = Hooks.H

class OnVisit extends BaseTrigger:
	var tags: Array[StringName]

	func _init(t):
		tags = Utils.as_sn_list(t)
		
	func check(ctx) -> bool:
		# True if the *destination* house is inhabited,
		# and if the villager living there has any of the given tags
		var occ = ctx.to_house.occupant
		return occ!= null and occ.has_any_tag(tags)

	func _to_string() -> String:
		return "Visit (%s)" % [",".join(PackedStringArray(tags))]
		
	func default_hook() -> StringName:
		return H.OnVisit
		
class OnMeet extends BaseTrigger:
	var tags: Array[StringName]

	func _init(t):
		tags = Utils.as_sn_list(t)

	func check(ctx) -> bool:
		# True if *another* villager currently visiting this house has
		# any of the tags
		var other_visitors = ctx.to_house.visitors.filter(func(v): return v != ctx.villager)
		return other_visitors.any(func(v): return v.has_any_tag(tags))

	func _to_string() -> String:
		return "Meet (%s)" % [",".join(PackedStringArray(tags))]
	
	func default_hook() -> StringName:
		return H.OnVisit

class OnExit extends BaseTrigger:

	func check(ctx) -> bool:
		# True if the attempted destination is outside the grid
		return not ctx.grid.is_inside(ctx.to_pos)
		
	func default_hook() -> StringName:
		return H.BeforeMove

class Always extends BaseTrigger:

	func check(ctx) -> bool:
		return true

# Combinators
class AndTrigger extends BaseTrigger:
	var triggers: Array[BaseTrigger]

	func _init(arr: Array):
		triggers = arr.duplicate()

	func check(ctx) -> bool:
		return triggers.all(func(t): return t.check(ctx))

	func _to_string() -> String:
		return "AND(%s)" % [", ".join(triggers.map(func(x): return x.to_string()))]

class OrTrigger extends BaseTrigger:
	var triggers: Array[BaseTrigger]

	func _init(arr: Array):
		triggers = arr.duplicate()

	func check(ctx) -> bool:
		return triggers.any(func(t): return t.check(ctx))

	func _to_string() -> String:
		return "OR(%s)" % [", ".join(triggers.map(func(x): return x.to_string()))]

class NotTrigger extends BaseTrigger:
	var inner: BaseTrigger

	func _init(t: BaseTrigger):
		inner = t

	func check(ctx) -> bool:
		return not inner.check(ctx)

	func _to_string() -> String:
		return "NOT(%s)" % [inner.to_string()]
