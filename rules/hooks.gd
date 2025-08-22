## Hook names are the *contract* between the simulator and Rules.
## A hook = a named moment in the night flow where rules may run.
## We use StringName for fast comparisons.

# TODO but shouldn't we use Enum instead?
class_name Hooks
const H = {
	NightStart = &"NightStart",
	NightEnd = &"NightEnd",

	# Movement lifecycle (per step)
	BeforeMove = &"BeforeMove", # about to step from A -> B (arrow-chosen)
	AfterMove = &"AfterMove", # finished step to B
	OnVisit = &"OnVisit", # entered a house B (fires after AfterMove)
	
	AttemptExit = &"AttemptExit", # movement would leave grid
	Redirected = &"Redirected", # movement got redirected (by an effect)

	# Scoring lifecycle
	OnGainPoints = &"OnGainPoints", # right before currency is added
	
	# Meta
	NightMaxSteps = &"NightMaxSteps", # fired if night ends due to step cap
}
