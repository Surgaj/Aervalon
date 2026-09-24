extends CharacterBody2D
signal died
@export var speed := 94.0
@export var health := 75
@export var aggro_range := 180.0
var player: Node2D
var origin: Vector2
var target: Vector2
var facing := Vector2.RIGHT
var attack_cd := 0.0
var windup := 0.0
var hit_stun := 0.0
var patrol_time := 0.0
var dead_time := 0.0
var state := "patrol"
func _ready():
	player = get_tree().get_first_node_in_group("player")
	origin = global_position
	target = origin
	$Visual.setup("wolf")
func _physics_process(delta):
	if health<=0:
		dead_time += delta
		$Visual.set_state("death",facing)
		modulate.a = clampf(1.5-dead_time*0.22,0,1)
		if dead_time>7: queue_free()
		return
	if not is_instance_valid(player): return
	attack_cd = maxf(0,attack_cd-delta)
	if hit_stun>0:
		hit_stun -= delta
		move_and_slide()
		$Visual.set_state("hit",facing)
		return
	var distance = global_position.distance_to(player.global_position)
	if windup>0:
		windup -= delta
		$Visual.set_state("attack",facing)
		if windup<=0 and distance<56 and player.death_time<=0: player.take_damage(12)
		return
	if player.death_time>0 or global_position.distance_to(origin)>310:
		state = "return"
	elif state != "return" and distance<aggro_range:
		state = "chase"
	elif state == "chase" and distance>250:
		state = "return"
	if state == "return":
		target = origin
		if global_position.distance_to(origin)<12: state = "patrol"
	elif state == "chase":
		target = player.global_position
		if distance<45:
			velocity = Vector2.ZERO
			if attack_cd<=0:
				attack_cd = 1.25
				windup = 0.4
				facing = global_position.direction_to(target)
			return
	else:
		patrol_time -= delta
		if patrol_time<=0:
			patrol_time = randf_range(2,4)
			target = origin+Vector2(randf_range(-45,45),randf_range(-35,35))
	velocity = global_position.direction_to(target)*(speed if state != "patrol" else 26.0) if global_position.distance_to(target)>5 else Vector2.ZERO
	if velocity.length()>1: facing = velocity.normalized()
	move_and_slide()
	$Visual.set_state("walk" if velocity.length()>1 else "idle",facing)
func take_damage(amount: int, direction := Vector2.ZERO):
	if health<=0: return
	health -= amount
	$Visual.flash()
	get_tree().current_scene.damage_number(global_position,amount,Color(1,0.9,0.6))
	hit_stun = 0.18
	velocity = direction*150
	windup = 0
	state = "chase"
	if health<=0:
		collision_layer = 0
		died.emit()
