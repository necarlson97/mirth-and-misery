## A small standard library of effects that mutate the simulation state.
## - the outcome of a rule getting triggered
extends RefCounted
class_name Effects

class GetTears extends EffectModel:
	var amount: int

	func _init(a: int):
		amount = a

	func apply(ctx: SimContext, rule: RuleModel) -> void:
		ctx.villager.add_tears(amount, ctx)

class GetLaughs extends EffectModel:
	var amount: int

	func _init(a: int):
		amount = a

	func apply(ctx: SimContext, rule: RuleModel) -> void:
		ctx.villager.add_laughter(amount, ctx)

class SleepSelf extends EffectModel:
	func apply(ctx: SimContext, rule: RuleModel) -> void:
		ctx.villager.mark_sleep("Sleeped by %s" % [rule])

class RedirectReverse extends EffectModel:
	## Redirects movement by reversing last step (i.e., bounce-back).
	func apply(ctx: SimContext, rule: RuleModel) -> void:
		ctx.redirect.reverse_last_step()
		ctx.emit_redirect()
