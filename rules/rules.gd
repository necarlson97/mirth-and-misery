## A small standard library of rules that include common
## hooks/triggers/effects, that an instance will then add it's individual flair to
class_name Rules

const H = Hooks.H
class Sleep extends BaseRule:
	func _init(t : BaseTrigger = Triggers.OnExit.new(), h := StringName()):
		super(h, t, Effects.SleepSelf.new())

class Tears extends BaseRule:
	func _init(t: BaseTrigger, a := 1):
		super(H.OnGainPoints, t, Effects.GetTears.new(a))

class Laughs extends BaseRule:
	func _init(t: BaseTrigger, a := 1):
		super(H.OnGainPoints, t, Effects.GetLaughs.new(a))
