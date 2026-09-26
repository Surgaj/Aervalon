extends Node2D
var items := {}
var coins := 0
var lifetime := 0.0
var collected := false
func _ready():
	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/aervalon/ui/loot.svg")
	sprite.position.y = -10
	add_child(sprite)
	add_to_group("loot")
func _process(delta):
	if collected: return
	lifetime += delta
	var world = get_tree().current_scene
	if world.modal_open or world.player.death_time>0: return
	if lifetime>0.6 and world.player.global_position.distance_to(global_position)<48:
		var ray = PhysicsRayQueryParameters2D.create(global_position,world.player.global_position,1)
		if get_world_2d().direct_space_state.intersect_ray(ray).is_empty(): collect()
func collect():
	if collected: return
	collected = true
	var world = get_tree().current_scene
	var messages: Array[String] = []
	for id in items:
		world.rpg.add_item(id,items[id])
		messages.append("+%d %s" % [items[id],world.rpg.ITEMS[id].name])
	world.coins += coins
	if coins>0: messages.append("+%d moedas" % coins)
	world.show_message("Recolhido", " • ".join(messages))
	world.persist()
	queue_free()
