extends SceneTree
var failures := 0
func _initialize(): call_deferred("run")
func check(condition: bool, description: String):
	if condition: print("PASS: ",description)
	else:
		push_error("FAIL: "+description)
		failures+=1
func run():
	change_scene_to_file("res://scenes/world/eryndor.tscn")
	await process_frame
	await physics_frame
	var world=current_scene
	var player=world.player
	for enemy in get_nodes_in_group("enemy"): enemy.set_physics_process(false)
	# New routes must remain physically traversable with the real player's radius.
	player.position=Vector2(2330,710)
	for point in [Vector2(2330,790),Vector2(2305,940),Vector2(2330,1040),Vector2(2470,1100),Vector2(2540,1190)]:
		for frame in 180:
			if player.position.distance_to(point)<10: break
			player.set_touch_direction(player.position.direction_to(point))
			await physics_frame
		player.set_touch_direction(Vector2.ZERO)
		check(player.position.distance_to(point)<12,"Player walks the farm trail to %s" % point)
	check(world.rpg.harvest_quest=="available","Exploration alone does not accept Iria's request")
	var iria=world.farm_worker
	iria.set_physics_process(false)
	iria.position=Vector2(2230,690)
	player.position=iria.position+Vector2(55,0)
	for i in 3: await process_frame
	world.interact_nearby()
	check(world.rpg.harvest_quest=="active" and not world.quest_started,"Iria interaction starts a separate regional request at a comfortable distance")
	var starting_coins=world.coins
	var starting_potions=world.rpg.inventory.potion
	world.interact_nearby()
	check(world.coins==starting_coins and world.rpg.harvest_quest=="active","Missing herbs cannot produce a reward")
	for id in ["herb_farm","herb_meadow","herb_forest"]:
		var herb=get_nodes_in_group("world_interaction").filter(func(n): return n.resource_id==id)[0]
		player.position=herb.position+Vector2(25,0)
		for i in 3: await process_frame
		world.interact_nearby()
		check(world.rpg.harvested.has(id),"Actual contextual gathering works at "+id)
	check(world.rpg.inventory.get("river_herb",0)==3,"Three harvests provide the request's real inventory items")
	var restored=preload("res://scripts/rpg_state.gd").new()
	check(restored.restore(world.rpg.snapshot()) and restored.harvest_quest=="active" and restored.harvested.has("herb_meadow"),"Active regional quest and new plant timers survive save restore")
	player.position=iria.position+Vector2(55,0)
	for i in 3: await process_frame
	check(world.quest_text().contains("Volte e fale com Iria"),"Regional objective points back to Iria once herbs are carried")
	world.interact_nearby()
	check(world.rpg.harvest_quest=="complete" and not world.rpg.inventory.has("river_herb") and world.coins==starting_coins+12 and world.rpg.inventory.potion==starting_potions+2 and world.rpg.xp==25,"Turn-in consumes exactly three herbs and grants coins, potions and XP")
	world.interact_nearby()
	check(world.coins==starting_coins+12 and world.rpg.xp==25,"Completed request cannot grant its reward twice")
	check(restored.restore(world.rpg.snapshot()) and restored.harvest_quest=="complete","Completed regional quest persists")
	var legacy=world.rpg.snapshot()
	legacy.erase("harvest_quest")
	check(restored.restore(legacy) and restored.harvest_quest=="available","Old saves receive an available regional quest without losing other progress")
	root.size=Vector2i(844,390)
	await process_frame
	for id in world.rpg.CLASSES:
		world.rpg.configure_new_character(id)
		world.hud.refresh()
		await process_frame
		var power=world.hud.power_button
		check(power.size==Vector2(86,86) and not power.get_global_rect().intersects(world.hud.dodge_button.get_global_rect()),id+" power remains a fixed-size non-overlapping mobile button")
	check(not world.hud.interaction_hint.get_global_rect().intersects(world.hud.power_button.get_global_rect()),"Contextual interaction label stays clear of the power button")
	check(world.hud.xp_label.get_parent()==world.hud.health.get_parent() and world.hud.xp_bar.max_value==world.rpg.xp_needed(),"XP bar and label stay inside the status panel")
	print("POLISH TEST COMPLETE: ",failures," failure(s)")
	quit(1 if failures else 0)
