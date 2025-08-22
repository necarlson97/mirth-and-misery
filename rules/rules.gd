## A small standard library of rules that include common
## hooks/triggers/effects, that an instance will then add it's individual flair to
class_name Rules

const H = Hooks.H
class Sleep extends RuleModel:
	func _init(s: VillagerModel, t : TriggerModel = Triggers.OnExit.new(), h := StringName()):
		super(s, h, t, Effects.SleepSelf.new())

class Tears extends RuleModel:
	func _init(s: VillagerModel, t: TriggerModel, a := 1):
		super(s, H.OnGainPoints, t, Effects.GetTears.new(a))

class Laughs extends RuleModel:
	func _init(s: VillagerModel, t: TriggerModel, a := 1):
		super(s, H.OnGainPoints, t, Effects.GetLaughs.new(a))
