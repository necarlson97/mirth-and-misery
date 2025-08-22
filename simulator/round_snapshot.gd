class_name RoundSnapshot
extends Resource
## A complete record of one night, contains a TickSnapshot
## of every tick, and some starting/final data

# TODO will need to be careful with RNG, need the starting seed of this night
# (not sure if I also need the seed of the round or just that)
var seed := 0

# ordered list of ticks
var ticks: Array[TickSnapshot] = []

func add_tick(grid: VillageGridModel) -> TickSnapshot:
	var tick = TickSnapshot.new(ticks.size(), grid)
	ticks.append(tick)
	return tick

func _to_string() -> String:
	return "SimTrace(ticks=%d)" % [ticks.size()]

class TickSnapshot extends Resource:
	## One “round” of simultaneous moves, then effects.
	# Deepcopy snapshot of village (as it was when the round started
	# TODO would me nice to make a subclass of 'resource' called 'snapshotable'
	# or w/e that would let us 'snapshot' which returns an immutable duplicate.
	# For now, we'll just have to be good about treading snapshots as read-only
	
	var index := -1
	var starting_state: VillageGridModel
	var rules_performed: Array[PerformedRule] = []  # scoring/sleep/death, etc.
	
	func _init(i := 0, village_grid = null):
		index = i
		if village_grid:
			starting_state = village_grid.duplicate(true) as VillageGridModel
	
	func rule_performed(rule: RuleModel, source, target) -> void:
		rules_performed.append(PerformedRule.new(rule, source, target))

	func _to_string() -> String:
		return "Tick(%d, state=%s, rules=%s)" % [index, starting_state, rules_performed.size()]

class PerformedRule extends Resource:
	# A rule performed, and on whom
	var rule: RuleModel
	var source
	var target
	
	func _init(r: RuleModel, s, t):
		rule = r
		source = s
		target = t
