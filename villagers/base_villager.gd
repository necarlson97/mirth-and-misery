## base_villager.gd
## Villager = the actor: tags + movement + rules + currency + life state.
## This is a pure data/logic object; the UI will later mirror it with a Node.
class_name BaseVillager
extends RefCounted

var id: StringName
var name: String = ""
var tags: Array[StringName] = []
var movement: Walks.BaseWalk
var rules: Array[BaseRule] = []
var is_sleeping: bool = false
var residence: House

var villager_token_prefab: PackedScene = preload("res://scenes/villager_token.tscn")
var token: VillagerToken

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
	return want.any(func(t): return t in tags)

func on_hook(hook: StringName, ctx) -> void:
	# Dispatch all rules bound to this hook.
	for r in rules:
		r.try_apply(hook, ctx)

func add_tears(n: int, ctx) -> void:
	# Hook allows global modifiers to step in later if we introduce them.
	tears += n

func add_laughter(n: int, ctx) -> void:
	laughter += n

func mark_sleep(reason: String = "") -> void:
	is_sleeping = true
	# For now we only flag; the simulator decides how to remove from board.

func get_token() -> VillagerToken:
	# Return (and create if needed) a villager token to represent this
	# villager on the board (handles frontend stuff like drag/drop and whatnot)
	if token != null:
		return token
	
	token = villager_token_prefab.instantiate() as VillagerToken
	token.villager = self
	if residence:
		token.reparent(residence.get_cell().dock)
	return token

func resettle(new_house: House):
	# Set this villager to a new residence,
	# updating their token and whatnot as needed
	if residence != null:
		assert(residence.resident == self, "My link to previous residence is broken")
		residence.resident = null
	
	assert(new_house.resident == null, "Someone already lives at next house")
	new_house.resident = self
	
	residence = new_house
	if token:
		token.reparent(new_house.get_cell().dock)

func _to_string() -> String:
	return "Villager(%s, tags=[%s], %s)" % [
		str(id),
		",".join(PackedStringArray(tags)),
		movement.to_string() if movement else "no-move"
	]
