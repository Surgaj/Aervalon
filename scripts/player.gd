extends CharacterBody2D
signal health_changed
@export var speed := 170.0
@export var max_health := 100
var health := 100
var facing := Vector2.DOWN
var touch_dir := Vector2.ZERO
var attack_cooldown := 0.0
var attack_time := 0.0
var hit_time := 0.0
var death_time := 0.0
var dodge_time := 0.0
var dodge_cooldown := 0.0
var dodge_direction := Vector2.DOWN
var strike_done := false
var spawn := Vector2(610,590)
@onready var visual = $Visual
func _ready():
	visual.setup("hero")
func _physics_process(delta):
	dodge_cooldown = maxf(0,dodge_cooldown-delta)
	attack_cooldown = maxf(0,attack_cooldown-delta)
	hit_time = maxf(0,hit_time-delta)
	if death_time > 0:
		death_time -= delta
		visual.set_state("death",facing)
		if death_time <= 0:
			global_position = spawn
			health = max_health
			hit_time = 2.0
			touch_dir = Vector2.ZERO
			health_changed.emit()
			get_tree().current_scene.show_message("Um novo fôlego","Você voltou à vila. Os lobos restantes ainda rondam a estrada.")
		return
	if get_tree().current_scene.modal_open:
		velocity = Vector2.ZERO
		touch_dir = Vector2.ZERO
		attack_time = 0
		dodge_time = 0
		visual.rotation = 0
		visual.set_state("idle",facing)
		return
	var input_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if touch_dir.length()>0.05: input_dir = touch_dir
	if Input.is_action_just_pressed("dodge"): dodge()
	if dodge_time>0:
		dodge_time = maxf(0,dodge_time-delta)
		velocity = dodge_direction*370.0
		move_and_slide()
		visual.set_state("walk",dodge_direction)
		visual.rotation = sin(dodge_time/0.24*PI)*0.16*signf(dodge_direction.x)
		return
	visual.rotation = 0
	if attack_time > 0:
		attack_time -= delta
		velocity = Vector2.ZERO
		visual.set_state("attack",facing)
		if attack_time <= 0.23 and not strike_done:
			strike_done = true
			_strike()
	else:
		if input_dir.length()>0.05: facing = input_dir.normalized()
		velocity = input_dir * speed
		move_and_slide()
		visual.set_state("hit" if hit_time>0 else ("walk" if velocity.length()>5 else "idle"),facing)
	if Input.is_action_just_pressed("attack"): attack()
	if Input.is_action_just_pressed("interact"): get_tree().current_scene.interact_nearby()
func set_touch_direction(dir: Vector2):
	touch_dir = dir.limit_length(1.0)
func attack():
	if attack_cooldown>0 or dodge_time>0 or death_time>0 or get_tree().current_scene.modal_open: return
	attack_cooldown = 0.55
	attack_time = 0.4
	strike_done = false
func dodge():
	if dodge_cooldown>0 or death_time>0 or get_tree().current_scene.modal_open: return
	var direction = touch_dir if touch_dir.length()>0.05 else Input.get_vector("move_left","move_right","move_up","move_down")
	dodge_direction = direction.normalized() if direction.length()>0.05 else facing
	facing = dodge_direction
	dodge_time = 0.24
	dodge_cooldown = 1.25
	attack_time = 0
	strike_done = true
func _strike():
	get_tree().current_scene.slash(global_position,facing)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var offset: Vector2 = enemy.global_position-global_position
		if enemy.health>0 and offset.length()<86 and (offset.length()<26 or facing.dot(offset.normalized())>0.25):
			# World geometry must not allow sword hits through walls.
			var query = PhysicsRayQueryParameters2D.create(global_position,enemy.global_position,1,[get_rid()])
			if get_world_2d().direct_space_state.intersect_ray(query).is_empty(): enemy.take_damage(get_tree().current_scene.rpg.attack(),facing)
func take_damage(amount: int):
	if death_time>0 or dodge_time>0.08 or hit_time>0 or get_tree().current_scene.modal_open: return
	amount = maxi(1,amount-get_tree().current_scene.rpg.defense())
	health = maxi(0,health-amount)
	hit_time = 0.3
	visual.flash()
	health_changed.emit()
	get_tree().current_scene.damage_number(global_position,amount,Color.SALMON)
	if health == 0:
		dodge_time = 0
		visual.rotation = 0
		death_time = 1.6
		attack_time = 0
