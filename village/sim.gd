## Simulator - the engine that advances one 'night'. For MVP, it will:
## - Walk a single villager via its movement profile
## - Fire hooks in order (BeforeMove -> AttemptExit? -> AfterMove -> OnVisit)
## - Apply villager rules at each hook
## - Stop on death, edge exit (unless redirected), or revisit loop
class_name Sim
extends RefCounted

var grid: VillageGrid
var trace: SimTrace

const H = Hooks.H

func _init(_grid):
	grid = _grid
	trace = SimTrace.new()

func run_night(max_steps := 256) -> SimTrace:
	trace.log("NightStart")
	
	# Snapshot starting positions (villagers were placed during the day)
	
	# TODO track durning trace? Maybe as like a 'final positions'
	# thing that, as we are building the trace out, is a convient place to
	# store the positions that matter for that tick?
	# Or we could array it and store positions for every tick...
	var pos_by_villager: Dictionary = grid.villager_starting_positions()
	print(pos_by_villager)

	for tick in range(max_steps):
		trace.log("Tick %d" % (tick + 1))

		for v in pos_by_villager.keys():
			trace.log("Villager %s..." % v)
			if v.is_sleeping:
				continue
			_move_villager(trace, v)

			# couldn've died/exited from movement
			if v.is_sleeping:
				continue

			var ctx_visit := SimContext.new(H.OnVisit, grid, v, to_pos, to_pos)
			v.on_hook(H.OnVisit, ctx_visit)

		# — Phase 5: book-keeping, deaths, visited sets —
		var all_sleeping := true
		for v in pos_by_villager.keys():
			if v.is_sleeping:
				continue
			all_sleeping = false
			# record visit AFTER OnVisit (so OnVisit sees has_visited_to_before correctly)
			visited_by_v[v][pos_by_villager[v]] = true

		if all_sleeping:
			trace.log("NightEnd: all villagers sleeping")
			return trace

	# If we get here, we hit the step cap
	trace.log("NightMaxSteps")
	# Let content decide what bonuses happen at cap:
	for v in pos_by_villager.keys():
		if v.is_sleeping: continue
		var p: Vector2i = pos_by_villager[v]
		var ctx_cap := SimContext.new(H.NightMaxSteps, grid, v, p, p, visited_by_v[v])
		v.on_hook(H.NightMaxSteps, ctx_cap)

	trace.log("NightEnd (step cap)")
	return trace

func _move_villager(trace: SimTrace, v: Villager):
	var from_pos: Vector2i = grid.get_villager_pos(v)
	var to_pos: Vector2i = v.movement.choose_next(from_pos, grid)
	
	var ctx_before := SimContext.new(H.BeforeMove, grid, v, from_pos, to_pos)
	v.on_hook(H.BeforeMove, ctx_before)
	
	# AttemptExit → allow effects to redirect
	if not grid.is_inside(to_pos):
		var ctx_exit := SimContext.new(H.AttemptExit, grid, v, from_pos, to_pos)
		v.on_hook(H.AttemptExit, ctx_exit)
		if ctx_exit.to_pos != to_pos:
			v.on_hook(H.Redirected, ctx_exit)
		to_pos = ctx_exit.to_pos
	
	# Otherwise, they really do exit, and fall alseep
	# TODO - I think this 'looks like' them going to that area - badlands or w/e
	# and they vbox view or w/e just stack up in there, all sleepy like
	if not grid.is_inside(to_pos):
		trace.log("Exit: %s leaves at %s" % [v.to_string(), str(to_pos)])
		# Remove from board; keep in dict but mark as sleeping
		v.mark_sleep("Exited")
	
	# Perform the actual move
	grid.move_villager(v, from_pos, to_pos)
	
	var ctx_after := SimContext.new(H.AfterMove, grid, v, from_pos, to_pos)
	v.on_hook(H.AfterMove, ctx_after)
