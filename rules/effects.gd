## A small standard library of effects that mutate the simulation state.
## - the outcome of a rule getting triggered
extends RefCounted
class_name Effects

class GetTears extends BaseEffect:
	var amount: int

	func _init(a: int):
		amount = a

	func apply(ctx) -> void:
		ctx.villager.add_tears(amount, ctx)

class GetLaughs extends BaseEffect:
	var amount: int

	func _init(a: int):
		amount = a

	func apply(ctx) -> void:
		ctx.villager.add_laughter(amount, ctx)

class SleepSelf extends BaseEffect:
	func apply(ctx) -> void:
		ctx.villager.mark_sleep("Sleeped by %s at %s" % [ctx.rule, ctx.hook])

class RedirectReverse extends BaseEffect:
	## Redirects movement by reversing last step (i.e., bounce-back).
	func apply(ctx) -> void:
		ctx.redirect.reverse_last_step()
		ctx.emit_redirect()
