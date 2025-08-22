## Simulator - the engine that advances one 'night'. For MVP, it will:
## - Walk a single villager via its movement profile
## - Fire hooks in order (BeforeMove -> AttemptExit? -> AfterMove -> OnVisit)
## - Apply villager rules at each hook
## - Stop on death, edge exit (unless redirected), or revisit loop
class_name Sim
extends RefCounted

var grid: VillageGridModel
var snapshot: RoundSnapshot

const H = Hooks.H

func _init(_grid):
	grid = _grid

func run_round(max_steps := 256) -> RoundSnapshot:
	grid.round_start_refresh()
	snapshot = RoundSnapshot.new()
	
	print("Starting night with grid %s and villagers: %s"%[grid, grid.all_villagers()])
	
	for tick_idx in range(max_steps):
		print("Starting tick %s"%tick_idx)
		var tick = snapshot.add_tick(grid)

		for v in grid.all_villagers():
			print("Starting villager %s" % v)
			# Don't perform rules for sleeping / dead / etc
			if v.is_inactive():
				continue
			_move_villager(tick, v)
			
			# couldn've died/exited from movement
			# TODO I think it more fun if they still get to trigger even if
			# 'OnMove' put them to sleep or w/e
			if v.is_inactive():
				continue

		# Ticks keep happening until everyone is alseep or dead or w/e
		var all_sleeping = grid.all_villagers().all(func(v): return v.is_inactive())
		
		if all_sleeping:
			print("Night over: all villagers sleeping")
			return snapshot

	# If we get here, we hit the step cap
	print("Night reached max steps")
	
	# TODO can trigger some sort of 'you made it to dawn!'('you broke the game!')
	# or w/e
	# Let content decide what bonuses happen at cap:
	return snapshot

func _move_villager(tick: RoundSnapshot.TickSnapshot, v: VillagerModel):
	var from_pos: Vector2i = grid.get_villager_pos(v)
	var to_pos: Vector2i = v.movement.choose_next(from_pos, grid)
	
	# TODO okay - so it looks like we need 'on_hook' to return the rules called,
	# and some more info so we can add rule_performed to the trace
	v.on_hook(SimContext.new(H.BeforeMove, grid, v, from_pos, to_pos))
	
	# AttemptExit → allow effects to redirect
	if not grid.is_inside(to_pos):
		var ctx_exit := SimContext.new(H.AttemptExit, grid, v, from_pos, to_pos)
		v.on_hook(ctx_exit)
		if ctx_exit.to_pos != to_pos:
			v.on_hook(SimContext.new(H.Redirected, grid, v, from_pos, to_pos))
		to_pos = ctx_exit.to_pos
	
	# Otherwise, they really do exit, and fall alseep
	# TODO - I think this 'looks like' them going to that area - badlands or w/e
	# and they vbox view or w/e just stack up in there, all sleepy like
	if not grid.is_inside(to_pos):
		print("Exit: %s leaves at %s" % [v, str(to_pos)])
		# Remove from board; keep in dict but mark as sleeping
		# TODO I don't think we handle this here - I think it is handled
		# as any other rule (one that most all villagers have)
		v.mark_sleep("Exited")
	
	# Perform the actual move
	grid.move_villager(v, from_pos, to_pos)
	
	v.on_hook(SimContext.new(H.AfterMove, grid, v, from_pos, to_pos))
	
	# TODO This should trigger, I think, on:
	# New visitor -> all existing visitors in that house
	# All existing visitors -> new visitor
	v.on_hook(SimContext.new(H.OnVisit, grid, v, to_pos, to_pos))
