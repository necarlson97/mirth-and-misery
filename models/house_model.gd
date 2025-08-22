## A single tile/cell ("house") in the village grid.
## Has:
## * occupant = villager who 'lives' there - this is what the player controls,
## 	placing the different villagers where they want them to start for the next round
## * visitors = during the night, if a villager moves to this house,
## 	then they 'visit' it for that single step (and 'meet' the other visitors there)
## * contents = temporary items that get dropped there during the night be a
## visitng villager or commandment or w/e 
class_name HouseModel
extends Resource

var cell_pos: Vector2i
var view: HouseView
var arrow: Vector2i # See direction.gd
# var tags: Array[StringName] = []
var resident: VillagerModel # villager that player told to start the round here
var visitors: Array[VillagerModel] = [] # villagers here this step
# var contents: Array[BaseItem] = [] # Temp items

var grid: VillageGridModel

var house_view_prefab: PackedScene = preload("res://views/house_view.tscn")

func _init(village_grid: VillageGridModel, p: Vector2i):
	grid = village_grid
	cell_pos = p
	arrow = Direction.rand()

func get_view() -> HouseView:
	# Like villager views, get the visual 'cell' that is a part of the grid,
	# and is used for drag drop, visual effects, etc
	if view != null: return view
	view = house_view_prefab.instantiate() as HouseView
	view.house = self
	return view

func _to_string() -> String:
	return "House(%s, arrow=%s, tags=[%s], n=%d)" % [
		str(cell_pos), str(arrow), ",".join([]), visitors.size()
	]
