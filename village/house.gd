## A single tile/cell ("house") in the village grid.
## Has:
## * occupant = villager who 'lives' there - this is what the player controls,
## 	placing the different villagers where they want them to start for the next round
## * visitors = during the night, if a villager moves to this house,
## 	then they 'visit' it for that single step (and 'meet' the other visitors there)
## * contents = temporary items that get dropped there during the night be a
## visitng villager or commandment or w/e 
class_name House
extends RefCounted

var cell_pos: Vector2i
var arrow: Vector2i # See direction.gd
# var tags: Array[StringName] = []
var resident: BaseVillager # villager that player told to start the round here
var visitors: Array[BaseVillager] = [] # villagers here this step
# var contents: Array[BaseItem] = [] # Temp items

var house_cell_prefab: PackedScene = preload("res://scenes/house_cell.tscn")


# Keeps track of the cell_position for all houses (Vector2i -> House)
static var cell_pos_to_house := {}

func _init(p: Vector2i):
	cell_pos = p
	arrow = Direction.rand()
	cell_pos_to_house[cell_pos] = self

func get_cell() -> HouseCell:
	# Like villager tokens, get the visual 'cell' that is a part of the grid,
	# and is used for drag drop, visual effects, etc
	var hc = house_cell_prefab.instantiate() as HouseCell
	hc.house = self
	hc.get_node("Label").text = "%s" % hc.get_cell_pos()
	return hc

func _to_string() -> String:
	return "House(%s, arrow=%s, tags=[%s], n=%d)" % [
		str(cell_pos), str(arrow), ",".join([]), visitors.size()
	]
	
static func get_at(pos: Vector2i) -> House:
	# Return the house at the desired position
	return cell_pos_to_house.get(pos, null)

static func all() -> Array[House]:
	return cell_pos_to_house.values()
