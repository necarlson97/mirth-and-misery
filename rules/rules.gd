## A small standard library of rules that include common
## hooks/triggers/effects, that an instance will then add it's individual flair to
class_name Rules

class Death extends BaseRule:
	func _init(t: BaseTrigger):
		super("Death", t, Effects.KillSelf.new())

class Tears extends BaseRule:
	func _init(t: BaseTrigger, a := 1):
		super("Points", t, Effects.GetTears.new(a))

class Laughs extends BaseRule:
	func _init(t: BaseTrigger, a := 1):
		super("Points", t, Effects.GetLaughs.new(a))
