extends Node2D
# Stable IDs address optional V1 save fields. No scene-path save dependencies.
var resource_id := ""
var world
var plant: Sprite2D
var shimmer: CPUParticles2D
var was_available := true
var echo_time := 0.0
var echo: AudioStreamPlayer2D
func _ready():
	world = get_tree().current_scene
	add_to_group("world_interaction")
	if resource_id.begins_with("herb_"):
		plant = Sprite2D.new()
		plant.texture = preload("res://assets/aervalon/v2/flowers.png")
		plant.scale = Vector2.ONE*(58.0/plant.texture.get_width())
		plant.position.y = -17
		add_child(plant)
	shimmer = CPUParticles2D.new()
	shimmer.amount = 5
	shimmer.lifetime = 1.8
	shimmer.position.y = -20 if plant else -58
	shimmer.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	shimmer.emission_sphere_radius = 14
	shimmer.direction = Vector2.UP
	shimmer.gravity = Vector2.ZERO
	shimmer.initial_velocity_min = 3
	shimmer.initial_velocity_max = 8
	shimmer.scale_amount_min = 0.8
	shimmer.scale_amount_max = 1.6
	shimmer.color = Color(0.65,0.9,0.6,0.7) if plant else Color(0.4,0.8,1,0.75)
	shimmer.emitting = false
	add_child(shimmer)
	if not plant:
		echo = AudioStreamPlayer2D.new()
		echo.stream = preload("res://assets/aervalon/audio/well_echo.wav")
		echo.volume_db = -10
		echo.max_distance = 450
		add_child(echo)
	update_appearance()
func available() -> bool:
	return Time.get_unix_time_from_system()>=float(world.rpg.harvested.get(resource_id,0))
func title() -> String:
	if plant: return "Erva de Orvalho" if available() else "Erva • rebrotando"
	return "Poço de Eryndor • um eco"
func action_text() -> String:
	return ("Colher" if available() else "Rebrota") if plant else "Escutar"
func can_reach(player: Node2D) -> bool:
	var ray = PhysicsRayQueryParameters2D.create(player.global_position,global_position,1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
func _process(delta):
	echo_time = maxf(0,echo_time-delta)
	if plant and available()!=was_available: update_appearance()
	var close = world.player.global_position.distance_to(global_position)<130
	shimmer.emitting = close and not world.modal_open and (available() if plant else echo_time>0)
func update_appearance():
	was_available = available()
	if plant: plant.modulate = Color.WHITE if was_available else Color(0.6,0.64,0.53,0.45)
func interact():
	if world.modal_open or world.player.death_time>0 or world.player.dodge_time>0: return
	if world.player.global_position.distance_to(global_position)>80 or not can_reach(world.player): return
	if plant:
		if not available():
			world.show_message("Deixe as raízes crescerem","Esta erva está rebrotando. Procure outras pelo vale.")
			return
		world.rpg.harvested[resource_id] = Time.get_unix_time_from_system()+120.0
		world.rpg.herbalism = mini(world.rpg.herbalism+1,9999)
		world.rpg.add_item("river_herb")
		update_appearance()
		var tween = create_tween()
		tween.tween_property(plant,"position:y",-22.0,0.12)
		tween.tween_property(plant,"position:y",-17.0,0.18)
		world.show_message("+1 Erva de Orvalho","Herbalismo • %d coletas. Use na mochila para recuperar 15 de vida ou venda por 2 moedas." % world.rpg.herbalism)
	else:
		if not world.rpg.discoveries.has(resource_id):
			world.rpg.discoveries[resource_id] = true
			world.grant_xp(15)
			world.show_message("Um eco sob Eryndor • +15 XP","Três batidas regulares sob a água. Uma luz pulsa por um instante. Alguém responde… ou alguma coisa ainda funciona?")
		else:
			world.show_message("O poço responde","As batidas continuam, profundas e regulares. Talvez Eldric também as tenha ouvido.")
		echo_time = 3.2
		if not echo.playing: echo.play()
		shimmer.restart()
		shimmer.emitting = true
	world.persist()
