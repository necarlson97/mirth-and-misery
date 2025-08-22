## A small standard library of common triggers.
## Triggers *compose* (And/Or/Not) so we can nest logic without new classes each time.
class_name Triggers
const H = Hooks.H

class OnVisit extends TriggerModel:
	var tags: Array[StringName]

	func _init(t):
		tags = Utils.as_sn_list(t)
		
	func check(source: VillagerModel, ctx: SimContext) -> bool:
		# True if the *destination* house is inhabited,
		# and if the villager living there has any of the given tags
		if ctx.to_house == null: return false
		var occ = ctx.to_house.resident
		return occ!= null and occ.has_any_tag(tags)

	func _to_string() -> String:
		return "Visit (%s)" % [",".join(PackedStringArray(tags))]
		
	func default_hook() -> StringName:
		return H.OnVisit
		
class OnMeet extends TriggerModel:
	var tags: Array[StringName]

	func _init(t):
		tags = Utils.as_sn_list(t)

	func check(source: VillagerModel, ctx: SimContext) -> bool:
		# True if *another* villager currently visiting this house has
		# any of the tags
		if ctx.to_house == null: return false
		var other_visitors = ctx.to_house.visitors.filter(func(v): return v != source)
		return other_visitors.any(func(v): return v.has_any_tag(tags))

	func _to_string() -> String:
		return "Meet (%s)" % [",".join(PackedStringArray(tags))]
	
	func default_hook() -> StringName:
		return H.OnVisit

class OnRevisit extends TriggerModel:
	
	# Dictionary of villager -> [list of visited positions]
	var has_visited := {}
	
	func check(source: VillagerModel, ctx: SimContext) -> bool:
		var visit_list = has_visited.get_or_add(source, [])
		if ctx.to_pos in visit_list:
			return true
		visit_list.append(ctx.to_pos)
		return false
	
	func round_start_refresh():
		has_visited = {}
		
	func default_hook() -> StringName:
		return H.BeforeMove
		
class OnTick extends TriggerModel:
	var till_sleep: int
	var ticks_awake: int
	
	func _init(_ticks_awake := 1):
		ticks_awake = _ticks_awake
		till_sleep = ticks_awake
	
	func check(source: VillagerModel, ctx: SimContext) -> bool:
		till_sleep -= 1
		return till_sleep <= 0
	
	func round_start_refresh():
		till_sleep = ticks_awake
		
	func default_hook() -> StringName:
		return H.BeforeMove

class OnExit extends TriggerModel:

	func check(source: VillagerModel, ctx: SimContext) -> bool:
		# True if the attempted destination is outside the grid
		return not ctx.grid.is_inside(ctx.to_pos)
		
	func default_hook() -> StringName:
		return H.BeforeMove

class OnMove extends TriggerModel:

	func check(source: VillagerModel, ctx: SimContext) -> bool:
		return true
		
	func default_hook() -> StringName:
		return H.AfterMove

class Always extends TriggerModel:

	func check(source: VillagerModel, ctx: SimContext) -> bool:
		return true

# Combinators
class AndTrigger extends TriggerModel:
	var triggers: Array[TriggerModel]

	func _init(arr: Array):
		triggers = arr.duplicate()

	func check(source: VillagerModel, ctx: SimContext) -> bool:
		return triggers.all(func(t): return t.check(ctx))

	func _to_string() -> String:
		return "AND(%s)" % [", ".join(triggers.map(func(x): return x.to_string()))]

class OrTrigger extends TriggerModel:
	var triggers: Array[TriggerModel]

	func _init(arr: Array):
		triggers = arr.duplicate()

	func check(source: VillagerModel, ctx: SimContext) -> bool:
		return triggers.any(func(t): return t.check(ctx))

	func _to_string() -> String:
		return "OR(%s)" % [", ".join(triggers.map(func(x): return x.to_string()))]

class NotTrigger extends TriggerModel:
	var inner: TriggerModel

	func _init(t: TriggerModel):
		inner = t

	func check(source: VillagerModel, ctx: SimContext) -> bool:
		return not inner.check(source, ctx)

	func _to_string() -> String:
		return "NOT(%s)" % [inner.to_string()]
