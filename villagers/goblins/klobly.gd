class_name Klobly
extends VillagerModel

const T = Tags.T

	## TODO - for now, just an example villager -
	## will add true functionality later

func _init():
	tags = [T.GOBLIN]
	movement = Walks.Orthogonal.new(0.5, 0, 0.5, 0)

	rules = [
		Rules.Sleep.new(self, Triggers.OnMeet.new(T.WARRIOR)),
		Rules.Sleep.new(self, Triggers.OnVisit.new(T.DEVIL)),
		Rules.Sleep.new(self, Triggers.OnExit.new()),

		Rules.Tears.new(self, Triggers.OnMeet.new(T.HUMAN), 1),
		Rules.Laughs.new(self, Triggers.OnVisit.new(T.GOBLIN), 2),
	]

func after_move(house_from, house_to):
	# TODO could put other stuff here - for now, just leaving as example
	# house_from.contents.add(TearPuddle.new())
	pass
