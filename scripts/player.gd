extends CharacterBody2D

@export var speed := 220.0
@export var max_health := 100
var health := max_health
var facing := Vector2.DOWN
var attack_cooldown := 0.0
var touch_dir := Vector2.ZERO

func _physics_process(delta):
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if touch_dir.length() > 0.05:
		input_dir = touch_dir
	if input_dir.length() > 0.05:
		facing = input_dir.normalized()
	velocity = input_dir * speed
	move_and_slide()
	if Input.is_action_just_pressed("attack"):
		attack()

func set_touch_direction(dir: Vector2):
	touch_dir = dir.normalized() if dir.length() > 0.05 else Vector2.ZERO

func attack():
	if attack_cooldown > 0.0: return
	attack_cooldown = 0.45
	$AttackArea.position = facing * 30.0
	for body in $AttackArea.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(25)
	var tween = create_tween()
	tween.tween_property($Body, "scale", Vector2(1.25, 0.8), 0.07)
	tween.tween_property($Body, "scale", Vector2.ONE, 0.10)

func take_damage(amount:int):
	health = maxi(0, health - amount)
	if health == 0:
		global_position = Vector2(640, 390)
		health = max_health
