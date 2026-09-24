extends CharacterBody2D
@export var npc_name := "Morador"
@export var role := "A vida continua em Eryndor."
@export var appearance := "mara"
@export var wander_radius := 35.0
@export var speed := 25.0
var origin := Vector2.ZERO
var target := Vector2.ZERO
var wait := 0.0
var facing := Vector2.DOWN
var conversation := 0.0
func _ready():
	origin = global_position
	target = origin
	$Visual.setup(appearance)
func _physics_process(delta):
	conversation = maxf(0,conversation-delta)
	if conversation>0:
		$Visual.set_state("idle",facing)
		return
	if appearance == "borin":
		$Visual.set_state("work",Vector2.DOWN)
		return
	wait -= delta
	if wait>0:
		$Visual.set_state("idle",facing)
		return
	if global_position.distance_to(target)<5:
		wait = randf_range(1.5,3)
		target = origin+Vector2(randf_range(-wander_radius,wander_radius),randf_range(-wander_radius,wander_radius)*0.5)
		return
	velocity = global_position.direction_to(target)*speed
	facing = velocity.normalized()
	move_and_slide()
	$Visual.set_state("walk",facing)
func interact():
	conversation = 5
	var world = get_tree().current_scene
	facing = global_position.direction_to(world.player.global_position)
	world.npc_dialogue(self)
