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
	var starting_coins = world.coins
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
	check(world.quest_complete and world.coins==starting_coins+25,"Mara completes quest and grants reward")
	world.npc_dialogue(mara)
	check(world.coins==starting_coins+25,"Reward cannot be claimed twice")
	player.hit_time = 0
	player.take_damage(999)
	check(player.death_time>0,"Death animation state starts")
	for i in 105: await physics_frame
	check(player.health==player.max_health and player.position.distance_to(player.spawn)<2,"Death returns player safely to village")
	# Inventory, trade and equipment exercise the same handlers as the touch UI.
	check(world.rpg.level==2 and world.rpg.xp==45,"Combat and mission XP level up once")
	check(get_nodes_in_group("loot").size()==3,"Wolves leave visible loot nodes")
	for drop in get_nodes_in_group("loot"): drop.collect()
	check(world.rpg.inventory.get("wolf_pelt",0)==3,"Ground drops enter inventory")
	var before_sale = world.coins
	check(world.rpg.sell("wolf_pelt")=="Item vendido" and world.coins==before_sale+5,"Loot sale pays exactly once")
	world.coins=0
	check(world.rpg.buy("iron_sword","borin")=="Moedas insuficientes" and not world.rpg.inventory.has("iron_sword"),"Insufficient funds cannot mint items")
	check(world.rpg.buy("iron_sword","merchant")=="Item indisponível","Shop rejects foreign stock")
	world.coins=70
	check(world.rpg.buy("iron_sword","borin")=="Item comprado" and world.coins==32,"Purchase transfers coins into an inventory item")
	var old_attack = world.rpg.attack()
	world.use_item("iron_sword")
	check(world.rpg.attack()==old_attack+13,"Equipped sword increases real attack")
	check(world.rpg.sell("iron_sword")!="Item vendido","Cannot sell the equipped last copy")
	world.rpg.buy("leather_armor","borin")
	world.use_item("leather_armor")
	player.hit_time=0
	var hp=player.health
	player.take_damage(12)
	check(player.health==hp-9,"Armor reduces incoming damage")
	player.health=35
	check(world.use_item("potion")=="Vida recuperada" and player.health==80,"Potion consumes one item and heals")
	player.health=player.max_health
	var potion_count=world.rpg.inventory.get("potion",0)
	world.use_item("potion")
	check(world.rpg.inventory.get("potion",0)==potion_count,"Full health does not waste potions")
	world.hud.open_inventory("borin")
	player.attack_cooldown=0
	player.attack()
	check(world.modal_open and player.attack_time==0,"Trade panel blocks combat")
	player.set_touch_direction(Vector2.RIGHT)
	var stopped=player.position
	for i in 5: await physics_frame
	check(player.position==stopped,"Trade panel blocks movement")
	world.hud.inventory_panel.close()
	world.persist()
	var copy=load("res://scripts/rpg_state.gd").new()
	check(copy.restore(world.rpg.snapshot()) and copy.equipment.weapon=="iron_sword" and copy.quest=="complete" and copy.level==2,"Save round trip retains progression and gear")
	copy.save_path="user://qa-rpg-save.json"
	check(copy.save_game(),"Native atomic save succeeds")
	var reloaded=load("res://scripts/rpg_state.gd").new()
	reloaded.save_path=copy.save_path
	check(reloaded.load_game() and reloaded.snapshot()==copy.snapshot(),"Actual file reload restores every saved field")
	DirAccess.remove_absolute(copy.save_path)
	check(not copy.restore({"version":999}),"Unknown save version is rejected")
	var before_death=world.rpg.snapshot()
	player.hit_time=0
	player.take_damage(999)
	for i in 105: await physics_frame
	check(world.rpg.snapshot()==before_death,"Death preserves inventory, level, coins and quest")
	var respawner=enemies[0]
	respawner.set_physics_process(true)
	respawner.dead_time=26
	for i in 3: await physics_frame
	check(respawner.health==75 and respawner.position.distance_to(respawner.origin)<5,"Wolf respawns away from the player")
	world.quest_started=false
	world.quest_kills=0
	world.quest_complete=false
	player.position=Vector2(1150,600)
	for i in 3: await physics_frame
	check(not world.quest_started,"Crossing coordinates never starts the quest")
	world._enemy_died()
	check(world.quest_kills==0 and not world.quest_started,"Kills before conversation do not start quest")
	# New systems must not erase the legacy progression or bypass world geometry.
	for foe in enemies: foe.set_physics_process(false)
	var legacy = world.rpg.snapshot()
	for field in ["herbalism","harvested","discoveries"]: legacy.erase(field)
	var migrated = load("res://scripts/rpg_state.gd").new()
	check(migrated.restore(legacy) and migrated.equipment==world.rpg.equipment and migrated.herbalism==0 and migrated.discoveries.is_empty(),"Legacy V1 save loads with optional exploration defaults")
	player.position = Vector2(600,600)
	player.hit_time = 0
	player.facing = Vector2.RIGHT
	player.dodge()
	var dodge_hp = player.health
	player.take_damage(12)
	check(player.health==dodge_hp,"Dodge protects only during its early window")
	var cooldown = player.dodge_cooldown
	player.dodge()
	check(player.dodge_cooldown==cooldown,"Repeated input cannot reset dodge cooldown")
	for i in 18: await physics_frame
	check(player.position.x>650 and player.dodge_time==0,"Dodge physically moves and ends")
	player.hit_time = 0
	player.take_damage(12)
	check(player.health<dodge_hp,"Player becomes vulnerable after dodge")
	player.position = Vector2(885,300)
	player.dodge_cooldown = 0
	player.dodge()
	for i in 18: await physics_frame
	check(player.position.x<915,"Dodge cannot pass through the river bank")
	world.hud.open_inventory()
	player.dodge_cooldown = 0
	player.dodge()
	check(player.dodge_time==0,"Inventory blocks dodge")
	world.hud.inventory_panel.close()
	var herb = get_nodes_in_group("world_interaction")[0]
	player.position = herb.position+Vector2(0,30)
	for i in 2: await physics_frame
	world.interact_nearby()
	check(world.rpg.inventory.get("river_herb",0)==1 and world.rpg.herbalism==1,"Contextual interaction harvests real item and practice")
	herb.interact()
	check(world.rpg.inventory.get("river_herb",0)==1 and not herb.available(),"Harvested plant cannot pay repeatedly")
	var exploration_save = load("res://scripts/rpg_state.gd").new()
	check(exploration_save.restore(world.rpg.snapshot()) and exploration_save.harvested.has(herb.resource_id),"Plant regrowth timer survives save restoration")
	player.health = 30
	check(world.use_item("river_herb")=="Vida recuperada" and player.health==45,"Gathered herb is a usable healing consumable")
	world.rpg.harvested[herb.resource_id] = Time.get_unix_time_from_system()-1
	herb.interact()
	check(world.rpg.herbalism==2 and world.rpg.inventory.get("river_herb",0)==1,"Plant regrows and can be gathered again")
	var herb_coins = world.coins
	world.rpg.sell("river_herb")
	check(world.coins==herb_coins+2,"Gathered resource participates in existing economy")
	player.position = Vector2(600,600)
	world.rpg.harvested[herb.resource_id] = 0
	herb.interact()
	check(world.rpg.herbalism==2,"Cannot harvest from outside interaction range")
	var well = get_nodes_in_group("world_interaction")[3]
	player.position = well.position+Vector2(35,0)
	for i in 2: await physics_frame
	var xp_before_echo = world.rpg.xp
	world.interact_nearby()
	check(world.rpg.discoveries.has("well_echo") and world.rpg.xp==xp_before_echo+15 and well.echo.playing,"Well discovery plays its echo and grants one reward")
	well.interact()
	check(world.rpg.xp==xp_before_echo+15,"Discovery reward cannot be farmed")
	check(exploration_save.restore(world.rpg.snapshot()) and exploration_save.discoveries.has("well_echo") and exploration_save.herbalism==2,"Discovery and profession practice persist")
	well.echo.stop()
	current_scene.queue_free()
	await process_frame
	await process_frame
	print("SLICE TEST COMPLETE: ",failures," failure(s)")
	quit(1 if failures else 0)
