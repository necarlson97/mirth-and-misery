class_name Wanda
extends VillagerModel

const T = Tags.T

func _init():
	tags = [T.HUMAN, T.MAGE]
	movement = Walks.Arrows.new()

	rules = [
		Rules.Sleep.new(self, Triggers.OnExit.new()),
		Rules.Sleep.new(self, Triggers.OnRevisit.new()),
		Rules.Laughs.new(self, Triggers.OnMove.new(), 1),
	]
