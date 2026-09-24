extends SceneTree
var failures := 0
func _initialize():
	call_deferred("run")
func check(condition: bool, description: String):
	if condition: print("PASS: ",description)
	else:
		push_error("FAIL: "+description)
		failures += 1
func run():
	change_scene_to_file("res://scenes/world/eryndor.tscn")
	await process_frame
	await physics_frame
	var world = current_scene
	var player = world.player
	check(world.get_node("YSortWorld").y_sort_enabled,"Actors and props share Y-sort")
	check(get_nodes_in_group("enemy").size()==3,"Three wolves loaded with raster animation")
	var mara = get_nodes_in_group("npc")[0]
	world.npc_dialogue(mara)
	check(world.quest_started,"Mara starts quest")
	var river_query = PhysicsRayQueryParameters2D.create(Vector2(880,300),Vector2(1100,300),1)
	check(not player.get_world_2d().direct_space_state.intersect_ray(river_query).is_empty(),"River blocks crossing outside bridge")
	var bridge_query = PhysicsRayQueryParameters2D.create(Vector2(890,545),Vector2(1080,637),1)
	check(player.get_world_2d().direct_space_state.intersect_ray(bridge_query).is_empty(),"Bridge deck has a continuous walkable corridor")
	var house_query = PhysicsRayQueryParameters2D.create(Vector2(360,480),Vector2(360,355),1)
	check(not player.get_world_2d().direct_space_state.intersect_ray(house_query).is_empty(),"House footprint blocks movement")
	# Verify real movement across bridge, with the same CharacterBody controller.
	player.position = Vector2(880,535)
	player.set_touch_direction(Vector2(1,0.483))
	for i in 92: await physics_frame
	player.set_touch_direction(Vector2.ZERO)
	check(player.position.x>1060,"Player physically crosses bridge without teleporting")
	var enemies = get_nodes_in_group("enemy")
	for enemy in enemies: enemy.set_physics_process(false)
	var enemy = enemies[0]
	player.position = enemy.position-Vector2(55,0)
	player.facing = Vector2.LEFT
	player._strike()
	check(enemy.health==75,"Sword does not hit behind player")
	player.facing = Vector2.RIGHT
	player.attack()
	for i in 30: await physics_frame
	check(enemy.health==50,"Timed attack deals exactly one hit")
	for foe in enemies:
		player.position = foe.position-Vector2(55,0)
		player.facing = Vector2.RIGHT
		while foe.health>0: player._strike()
	check(world.quest_kills==3 and not world.quest_complete,"Three kills require return to Mara")
	world.npc_dialogue(mara)
	check(world.quest_complete and world.coins==25,"Mara completes quest and grants reward")
	world.npc_dialogue(mara)
	check(world.coins==25,"Reward cannot be claimed twice")
	player.hit_time = 0
	player.take_damage(100)
	check(player.death_time>0,"Death animation state starts")
	for i in 105: await physics_frame
	check(player.health==100 and player.position.distance_to(player.spawn)<2,"Death returns player safely to village")
	print("SLICE TEST COMPLETE: ",failures," failure(s)")
	quit(1 if failures else 0)
