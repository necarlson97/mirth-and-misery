class_name Baroba
extends VillagerModel

const T = Tags.T

func _init():
	tags = [T.HUMAN, T.MAGE]
	movement = Walks.Stationary.new()

	rules = [
		Rules.Sleep.new(self, Triggers.OnTick.new(10)),
	]
