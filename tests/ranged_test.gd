extends SceneTree
var failures := 0
func _initialize(): call_deferred("run")
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
	var enemies = get_nodes_in_group("enemy")
	for i in enemies.size():
		enemies[i].set_physics_process(false)
		enemies[i].position = Vector2(2500+i*70,600)
	var enemy = enemies[0]
	player.position = Vector2(2080,600)
	player.facing = Vector2.RIGHT
	for id in ["tracker","arcanist","artificer"]:
		world.rpg.configure_new_character(id)
		enemy.position = Vector2(2280,600)
		enemy.health = 200
		player._strike()
		check(enemy.health==200 and get_nodes_in_group("projectile").size()==1,id+" launches a travelling projectile instead of instant melee damage")
		for i in 60: await physics_frame
		check(enemy.health==200-world.rpg.attack() and get_nodes_in_group("projectile").is_empty(),id+" hits once at 200px and removes its projectile")
	world.rpg.configure_new_character("tracker")
	enemy.health=200
	enemies[1].position=Vector2(2340,600)
	enemies[1].health=200
	player.attack_cooldown=0
	player.attack()
	player.attack()
	for i in 60: await physics_frame
	check(enemy.health==174 and enemies[1].health==200,"Cooldown prevents duplicate fire and the first target absorbs the arrow")
	var wall=StaticBody2D.new()
	wall.position=Vector2(2180,600)
	var collider=CollisionShape2D.new()
	var shape=RectangleShape2D.new()
	shape.size=Vector2(8,100)
	collider.shape=shape
	wall.add_child(collider)
	world.add_child(wall)
	await physics_frame
	enemy.health=200
	player._strike()
	for i in 60: await physics_frame
	check(enemy.health==200 and get_nodes_in_group("projectile").is_empty(),"Swept arrow collision stops at a thin wall")
	wall.queue_free()
	await physics_frame
	await physics_frame
	player._strike()
	var shot=get_nodes_in_group("projectile")[0]
	var paused_position=shot.position
	world.modal_open=true
	for i in 12: await physics_frame
	check(shot.position==paused_position and enemy.health==200,"Inventory pauses projectiles without dealing damage")
	world.modal_open=false
	for i in 60: await physics_frame
	check(enemy.health==174,"Closing inventory resumes the same projectile exactly once")
	for foe in enemies: foe.position=Vector2(2700,1000)
	player._strike()
	for i in 75: await physics_frame
	check(get_nodes_in_group("projectile").is_empty(),"Missed shots expire at the weapon range")
	player._strike()
	player.death_time=1
	for i in 3: await physics_frame
	check(get_nodes_in_group("projectile").is_empty(),"Player death clears outstanding shots")
	player.death_time=0
	world.rpg.configure_new_character("guardian")
	enemy.position=Vector2(2280,600)
	enemy.health=200
	player._strike()
	await physics_frame
	check(enemy.health==200 and get_nodes_in_group("projectile").is_empty(),"Sword remains a close-combat weapon")
	for id in world.rpg.CLASSES:
		var r=preload("res://scripts/rpg_state.gd").new()
		r.configure_new_character(id)
		var upgrades=r.shop_stock("borin").filter(func(item): return r.ITEMS[item].get("slot","")=="weapon")
		check(not upgrades.is_empty(),id+" has a compatible weapon upgrade in Borin's shop")
		var upgrade=upgrades[0]
		var before=r.attack()
		r.coins=37
		check(r.buy(upgrade,"borin")=="Moedas insuficientes" and not r.inventory.has(upgrade),id+" upgrade requires sufficient coins")
		r.coins=38
		check(r.buy(upgrade,"borin")=="Item comprado" and r.equip(upgrade) and r.attack()>before and r.coins==0,id+" can buy, equip and gain real damage")
		var restored=preload("res://scripts/rpg_state.gd").new()
		restored.class_id=id
		check(restored.restore(r.snapshot()) and restored.equipment.weapon==upgrade and restored.attack()==r.attack(),id+" upgraded weapon survives save restore")
	# Kills still flow through the existing XP/drop pipeline, once per enemy.
	world.rpg.configure_new_character("arcanist")
	enemy.health=world.rpg.attack()
	enemy.collision_layer=4
	var xp_before=world.rpg.xp
	var drops_before=get_nodes_in_group("loot").size()
	player._strike()
	for i in 65: await physics_frame
	check(enemy.health<=0 and world.rpg.xp>xp_before and get_nodes_in_group("loot").size()==drops_before+1,"Projectile kill grants XP and a real loot drop")
	print("RANGED TEST COMPLETE: ",failures," failure(s)")
	quit(1 if failures else 0)
