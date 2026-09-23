extends CharacterBody2D
@export var speed:=180.0
@export var max_health:=100
var health:=max_health
var facing:=Vector2.DOWN
var attack_cooldown:=0.0
var touch_dir:=Vector2.ZERO
var anim_t:=0.0
func _physics_process(delta):
	attack_cooldown=maxf(0.0,attack_cooldown-delta)
	var input_dir=Input.get_vector("move_left","move_right","move_up","move_down")
	if touch_dir.length()>0.05: input_dir=touch_dir
	if input_dir.length()>0.05: facing=input_dir.normalized()
	velocity=input_dir*speed
	move_and_slide()
	anim_t+=delta*10.0
	if velocity.length()>2:
		$Visual.position.y=sin(anim_t)*1.8
		$Visual.rotation=sin(anim_t)*0.025
	else:
		$Visual.position.y=sin(anim_t*0.35)*0.6
		$Visual.rotation=0
	if facing.x!=0: $Visual.scale.x=1.0 if facing.x>0 else -1.0
	if Input.is_action_just_pressed("attack"): attack()
func set_touch_direction(dir:Vector2): touch_dir=dir.normalized() if dir.length()>0.05 else Vector2.ZERO
func attack():
	if attack_cooldown>0:return
	attack_cooldown=0.42
	$AttackArea.position=facing*32
	var t=create_tween()
	t.tween_property($Visual/Sword,"rotation",1.4,0.08)
	t.tween_property($Visual/Sword,"rotation",-0.25,0.13)
	for body in $AttackArea.get_overlapping_bodies():
		if body.has_method("take_damage"): body.take_damage(25)
func take_damage(amount:int):
	health=maxi(0,health-amount)
	var t=create_tween()
	t.tween_property($Visual,"modulate",Color(1,0.45,0.45),0.07)
	t.tween_property($Visual,"modulate",Color.WHITE,0.14)
	if health==0:
		global_position=Vector2(640,390);health=max_health
