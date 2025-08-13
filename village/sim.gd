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

func _init(_grid, _rng):
	grid = _grid
	rng = _rng
	trace = SimTrace.new()

func run_single_walker(v, start_pos: Vector2i, max_steps := 256) -> SimTrace:
	# This is intentionally simple; we’ll expand as we add more villagers/systems.
	var pos := start_pos
	grid.get_house(pos).visitors.append(v)

	trace.log("NightStart: %s at %s" % [v.to_string(), str(pos)])

	var visited := {}
	visited[pos] = true

	for step in range(max_steps):
		# 1) choose intended next
		var intend = v.movement.choose_next(pos, grid)

		# 2) AttemptExit hook (if leaving grid)
		if not grid.is_inside(intend):
			var ctx_exit := SimContext.new(&"AttemptExit", grid, v, pos, intend, rng)
			v.on_hook(&"AttemptExit", ctx_exit)
			# Effect may have redirected into grid
			intend = ctx_exit.to_pos

		# 3) If still outside, we stop (exited)
		if not grid.is_inside(intend):
			trace.log("Exit at %s" % str(intend))
			break

		# 4) BeforeMove / AfterMove
		var ctx_before := SimContext.new(&"BeforeMove", grid, v, pos, intend, rng)
		v.on_hook(&"BeforeMove", ctx_before)

		grid.move_villager(v, pos, intend)
		var ctx_after := SimContext.new(&"AfterMove", grid, v, pos, intend, rng)
		v.on_hook(&"AfterMove", ctx_after)

		pos = intend
		trace.log("Step %d: -> %s" % [step + 1, str(pos)])

		# 5) OnVisit
		var ctx_visit := SimContext.new(&"OnVisit", grid, v, pos, pos, rng)
		v.on_hook(&"OnVisit", ctx_visit)

		# stopping conditions
		if v.is_dead:
			trace.log("Death at %s" % str(pos))
			break
		if visited.has(pos):
			trace.log("Loop detected at %s" % str(pos))
			break
		visited[pos] = true

	trace.log("NightEnd: tears=%d laughter=%d" % [v.tears, v.laughter])
	return trace
