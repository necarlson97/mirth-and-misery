## Hook names are the *contract* between the simulator and Rules.
## A hook = a named moment in the night flow where rules may run.
## We use StringName for fast comparisons.
const Hook = {
	NightStart = &"NightStart",
	NightEnd = &"NightEnd",

	# Movement lifecycle (per step)
	BeforeMove = &"BeforeMove", # about to step from A -> B (arrow-chosen)
	AfterMove = &"AfterMove", # finished step to B
	OnVisit = &"OnVisit", # entered a house B (fires after AfterMove)
	OnMeet = &"OnVisit", # happened to be in the same house on the same step as aother villager
	AttemptExit = &"AttemptExit", # movement would leave grid
	Redirected = &"Redirected", # movement got redirected (by an effect)

	# Scoring lifecycle
	OnGainPoints = &"OnGainPoints", # right before currency is added
}
