## A small standard library of 'parent' rules that include common
## hooks/triggers/effects, that a subclass will then add it's individual flair to
class_name Rules

class DeathRule extends BaseRule:
	func _init(t: BaseTrigger):
		super("Death", t, Effects.KillSelf.new())

class TearsRule extends BaseRule:
	func _init(t: BaseTrigger, a := 1):
		super("Points", t, Effects.GetTears.new(a))

class LaughsRule extends BaseRule:
	func _init(t: BaseTrigger, a := 1):
		super("Points", t, Effects.GetLaughs.new(a))
