extends CharacterBody2D
@export var npc_name := "Morador"
@export var role := "A vida continua em Eryndor."
@export var wander_radius := 55.0
@export var speed := 28.0
var origin := Vector2.ZERO
var target := Vector2.ZERO
var wait := 0.0
func _ready():
	origin = global_position
	_pick_target()
func _physics_process(delta):
	wait -= delta
	if wait > 0.0:
		velocity = Vector2.ZERO
		return
	if global_position.distance_to(target) < 5.0:
		wait = 1.5 + randf() * 2.5
		_pick_target()
		return
	velocity = global_position.direction_to(target) * speed
	move_and_slide()
	if velocity.length() > 1.0:
		$Visual.rotation = sin(Time.get_ticks_msec() * 0.012) * 0.035
func _pick_target():
	target = origin + Vector2(randf_range(-wander_radius,wander_radius),randf_range(-wander_radius,wander_radius))
func interact():
	var ui = get_tree().get_first_node_in_group("world_ui")
	if ui and ui.has_method("show_message"):
		ui.show_message(npc_name, role)
