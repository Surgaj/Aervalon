extends CharacterBody2D

@export var speed := 75.0
@export var health := 75
@export var aggro_range := 220.0
var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if not is_instance_valid(player): return
	var d = global_position.distance_to(player.global_position)
	if d < aggro_range and d > 32.0:
		velocity = global_position.direction_to(player.global_position) * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func take_damage(amount:int):
	health -= amount
	var tween = create_tween()
	tween.tween_property($Body, "modulate", Color(1,0.45,0.45), 0.06)
	tween.tween_property($Body, "modulate", Color.WHITE, 0.12)
	if health <= 0:
		queue_free()
