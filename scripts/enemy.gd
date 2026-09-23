extends CharacterBody2D
signal died
@export var speed:=70.0
@export var health:=75
@export var aggro_range:=210.0
var player:Node2D
var attack_cd:=0.0
var t:=0.0
func _ready(): player=get_tree().get_first_node_in_group("player")
func _physics_process(delta):
	if not is_instance_valid(player):return
	attack_cd=maxf(0,attack_cd-delta);t+=delta*9
	var d=global_position.distance_to(player.global_position)
	if d<aggro_range and d>34:
		velocity=global_position.direction_to(player.global_position)*speed
		move_and_slide()
		$Visual.position.y=sin(t)*1.5
		$Visual.scale.x=1 if velocity.x>=0 else -1
	elif d<=38 and attack_cd<=0:
		velocity=Vector2.ZERO;attack_cd=1.1
		if player.has_method("take_damage"):player.take_damage(12)
	else: velocity=Vector2.ZERO
func take_damage(amount:int):
	health-=amount
	var tw=create_tween();tw.tween_property($Visual,"modulate",Color(1,0.35,0.35),0.06);tw.tween_property($Visual,"modulate",Color.WHITE,0.12)
	if health<=0:
		died.emit();queue_free()
