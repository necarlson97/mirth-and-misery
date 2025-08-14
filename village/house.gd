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

var pos: Vector2i
var arrow: Vector2i # See direction.gd
var tags: Array[StringName] = []
var resident: BaseVillager # villager that player told to start the round here
var visitors: Array[BaseVillager] = [] # villagers here this step
# var contents: Array[BaseItem] = [] # Temp items

func _init(p: Vector2i, dir: Vector2i, t: Array = []):
	pos = p
	arrow = dir
	for x in t:
		tags.append(x if x is StringName else StringName(x))

func has_any_tag(want: Array[StringName]) -> bool:
	for t in want:
		if t in tags:
			return true
	return false

func _to_string() -> String:
	return "House(%s, arrow=%s, tags=[%s], n=%d)" % [
		str(pos), str(arrow), ",".join(PackedStringArray(tags)), visitors.size()
	]
