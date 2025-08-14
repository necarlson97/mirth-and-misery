class_name Goblins
const T = Tags.T

class Klobly extends BaseVillager:
	## TODO - for now, just an example villager -
	## will add true functionality later

	func _init():
		tags = [T.GOBLIN]
		movement = MovementProfile.Orthogonal.new(0.5, 0, 0.5, 0)

		rules = [
			Rules.Death.new(Triggers.OnMeet.new(T.WARRIOR)),
			Rules.Death.new(Triggers.OnVisit.new(T.DEVIL)),
			Rules.Death.new(Triggers.OnExit.new()),

			Rules.Tears.new(Triggers.OnMeet.new(T.HUMAN), 1),
			Rules.Laughs.new(Triggers.OnVisit.new(T.GOBLIN), 2),
		]

	func after_move(house_from, house_to):
		# TODO could put other stuff here - for now, just leaving as example
		# house_from.contents.add(TearPuddle.new())
		pass
