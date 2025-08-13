## base_villager.gd
## Villager = the actor: tags + movement + rules + currency + life state.
## This is a pure data/logic object; the UI will later mirror it with a Node.
class_name BaseVillager
extends RefCounted

var id: StringName
var name: String = ""
var tags: Array[StringName] = []
var movement: MovementProfile
var rules: Array[BaseRule] = []
var is_dead: bool = false

# TODO how exactly do we want to handle tears/laughter?
# Perhaps:
# * During night, individual villagers 'collect' them here -
#	mostly as a feedback thing - players can see which villagers are responsible
#	for winning them points
# * They are summed for the 'round totals' - which is what actually 
# 	counts for passing the round (two progress bars on the side,
#	modulo by the round-goal, with extra fills granting the player
# 	'crystal tears' or 'crystal laughs' - which become the currency for
# 	buying new villagers from the caravan or pirates cover or w/e?
var tears: int = 0
var laughter: int = 0

func _init(_id: StringName):
	id = _id

func has_any_tag(want: Array[StringName]) -> bool:
	# TODO likely more readable as functional 'any'
	for t in want:
		if t in tags:
			return true
	return false

func on_hook(hook: StringName, ctx) -> void:
	# Dispatch all rules bound to this hook.
	for r in rules:
		r.try_apply(hook, ctx)

func add_tears(n: int, ctx) -> void:
	# Hook allows global modifiers to step in later if we introduce them.
	tears += n

func add_laughter(n: int, ctx) -> void:
	laughter += n

func mark_dead(reason: String = "") -> void:
	is_dead = true
	# For now we only flag; the simulator decides how to remove from board.

func _to_string() -> String:
	return "Villager(%s, tags=[%s], %s)" % [
		str(id),
		",".join(PackedStringArray(tags)),
		movement.to_string() if movement else "no-move"
	]
