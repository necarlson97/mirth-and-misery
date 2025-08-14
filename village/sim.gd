## Simulator - the engine that advances one 'night'. For MVP, it will:
## - Walk a single villager via its movement profile
## - Fire hooks in order (BeforeMove -> AttemptExit? -> AfterMove -> OnVisit)
## - Apply villager rules at each hook
## - Stop on death, edge exit (unless redirected), or revisit loop
class_name Sim
extends RefCounted

var grid: VillageGrid
var rng: Rng
var trace: SimTrace

const H = Hooks.H

func _init(_grid, _rng):
	grid = _grid
	rng = _rng
	trace = SimTrace.new()

func run_night(max_steps := 256) -> SimTrace:
	trace.log("NightStart")
	# Snapshot starting positions (villagers were placed during the day)
	var pos_by_villager: Dictionary = grid.villagers_and_positions()

	# Each villager keeps its own visited set (positions)
	var visited_by_v: Dictionary = {}
	for v in pos_by_villager.keys():
		visited_by_v[v] = { pos_by_villager[v]: true }

	for tick in range(max_steps):
		trace.log("Tick %d" % (tick + 1))

		# — Phase 1: intents —
		var intents: Dictionary = {}  # villager => intended Vector2i
		for v in pos_by_villager.keys():
			if v.is_sleeping:
				continue
			var from_pos: Vector2i = pos_by_villager[v]
			var intend: Vector2i = v.movement.choose_next(from_pos, grid)

			# AttemptExit → allow effects to redirect
			if not grid.is_inside(intend):
				var ctx_exit := SimContext.new(H.AttemptExit, grid, v, from_pos, intend, rng, visited_by_v[v])
				v.on_hook(H.AttemptExit, ctx_exit)
				if ctx_exit.to_pos != intend:
					v.on_hook(H.Redirected, ctx_exit)
				intend = ctx_exit.to_pos

			intents[v] = intend

		# — Early exit removal —
		for v in intents.keys():
			var p: Vector2i = intents[v]
			if not grid.is_inside(p):
				trace.log("Exit: %s leaves at %s" % [v.to_string(), str(p)])
				# Remove from board; keep in dict but mark as sleeping
				v.mark_sleep("Exited")
		# drop dead/exited from this tick’s movement
		for v in pos_by_villager.keys():
			if v.is_sleeping:
				intents.erase(v)

		# — Phase 2: BeforeMove —
		for v in intents.keys():
			var from_pos: Vector2i = pos_by_villager[v]
			var to_pos: Vector2i = intents[v]
			var ctx_before := SimContext.new(H.BeforeMove, grid, v, from_pos, to_pos, rng, visited_by_v[v])
			v.on_hook(H.BeforeMove, ctx_before)
			# effects could have modified to_pos (rare, but allow)
			intents[v] = ctx_before.to_pos

		# — Phase 3: commit all moves simultaneously —
		for v in intents.keys():
			var from_pos: Vector2i = pos_by_villager[v]
			var to_pos: Vector2i = intents[v]
			grid.move_villager(v, from_pos, to_pos)
			pos_by_villager[v] = to_pos

		# — Phase 4: AfterMove + OnVisit —
		for v in intents.keys():
			var from_pos: Vector2i = pos_by_villager[v]  # already updated, so compute back
			var to_pos: Vector2i = intents[v]
			var ctx_after := SimContext.new(H.AfterMove, grid, v, from_pos, to_pos, rng, visited_by_v[v])
			v.on_hook(H.AfterMove, ctx_after)

			var ctx_visit := SimContext.new(H.OnVisit, grid, v, to_pos, to_pos, rng, visited_by_v[v])
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
		var ctx_cap := SimContext.new(H.NightMaxSteps, grid, v, p, p, rng, visited_by_v[v])
		v.on_hook(H.NightMaxSteps, ctx_cap)

	trace.log("NightEnd (step cap)")
	return trace
