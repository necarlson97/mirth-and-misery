## base_villager.gd
## Villager = the actor: tags + movement + rules + currency + life state.
## This is a pure data/logic object; the UI will later mirror it with a Node.
class_name VillagerModel
extends Resource

var tags: Array[StringName] = []

var movement: Walks.BaseWalk
var rules: Array[RuleModel] = []

var residence: HouseModel

var villager_view_prefab: PackedScene = preload("res://views/villager_view.tscn")
var view: VillagerView

var is_sleeping: bool = false
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

func round_start_refresh():
	is_sleeping = false
	tears = 0
	laughter = 0
	
	for r in rules:
		r.trigger.round_start_refresh()
	# TODO when do we remove dead?

func has_any_tag(want: Array[StringName]) -> bool:
	return want.any(func(t): return t in tags)

func on_hook(ctx) -> void:
	# Dispatch all rules bound to this hook.
	for r in rules:
		r.try_apply(ctx)

func add_tears(n: int, ctx) -> void:
	# Hook allows global modifiers to step in later if we introduce them.
	tears += n

func add_laughter(n: int, ctx) -> void:
	laughter += n

func mark_sleep(reason: String = "") -> void:
	is_sleeping = true
	print("Sleeping %s: '%s'"%[self, reason])
	
func mark_dead(reason: String = "") -> void:
	is_dead = true
	print("Killing %s: '%s'"%[self, reason])

func is_inactive() -> bool:
	return is_sleeping or is_dead

func get_view() -> VillagerView:
	# Return (and create if needed) a villager view to represent this
	# villager on the board (handles frontend stuff like drag/drop and whatnot)
	if view != null:
		return view
	
	view = villager_view_prefab.instantiate() as VillagerView
	view.villager = self
	if residence:
		view.dock_to(residence.get_cell().dock)
	return view

func resettle(new_house: HouseModel):
	# Set this villager to a new residence,
	# updating their view and whatnot as needed
	if residence != null:
		assert(residence.resident == self, "My link to previous residence is broken")
		residence.resident = null
	
	assert(new_house.resident == null, "Someone already lives at next house")
	new_house.resident = self
	
	residence = new_house
	if view:
		view.dock_to(new_house.get_view().dock)

func walk_to(new_house: HouseModel):
	# TODO lerp to
	if view and new_house and new_house.view:
		view.dock_to(new_house.get_view().dock)

func _to_string() -> String:
	var s = get_script()
	if s:
		# If globally registered, this will be the class_name.
		var g = s.get_global_name()
		if g != "": return g
		# Otherwise, fall back to the script file name.
		if s.resource_path != "":
			return s.resource_path.get_file().get_basename()
	return get_class()
