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
var work_clock := 0.0
var route: Array[Vector2] = []
var route_index := 0
func _ready():
	origin = global_position
	target = origin
	$Visual.setup(appearance)
	if appearance=="borin": $Visual.frame_changed.connect(_hammer_hit)
func _physics_process(delta):
	conversation = maxf(0,conversation-delta)
	if conversation>0 or get_tree().current_scene.modal_open:
		$Visual.set_state("idle",facing)
		return
	if appearance == "merchant":
		$Visual.set_state("work",Vector2.RIGHT)
		return
	if appearance == "borin":
		work_clock = fmod(work_clock+delta,4.5)
		$Visual.set_state("work" if work_clock>1.0 and work_clock<3.0 else "idle",Vector2.DOWN)
		return
	wait -= delta
	if wait>0:
		$Visual.set_state("idle",facing)
		return
	if global_position.distance_to(target)<5:
		wait = randf_range(1.5,3)
		if not route.is_empty():
			target = route[route_index]
			route_index = (route_index+1)%route.size()
		else:
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

func _hammer_hit():
	if $Visual.animation!="work0" or $Visual.frame!=2: return
	var sparks = CPUParticles2D.new()
	sparks.position = Vector2(20,-1)
	sparks.amount = 6
	sparks.one_shot = true
	sparks.explosiveness = 1.0
	sparks.lifetime = 0.22
	sparks.direction = Vector2.UP
	sparks.spread = 65
	sparks.initial_velocity_min = 25
	sparks.initial_velocity_max = 55
	sparks.gravity = Vector2(0,110)
	sparks.scale_amount_min = 1
	sparks.scale_amount_max = 2
	sparks.color = Color(1,0.7,0.15)
	add_child(sparks)
	sparks.finished.connect(sparks.queue_free)
