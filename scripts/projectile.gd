extends Node2D
# Swept collisions prevent fast missiles from tunnelling through thin scenery.
var direction := Vector2.RIGHT
var speed := 360.0
var remaining := 280.0
var damage := 1
var kind := "arrow"
var resolved := false
func _ready():
	add_to_group("projectile")
	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/aervalon/ui/projectile_"+kind+".svg")
	sprite.position.y = -18
	sprite.rotation = direction.angle()
	add_child(sprite)
func _physics_process(delta):
	if resolved: return
	var world = get_tree().current_scene
	if world.player.death_time>0:
		queue_free()
		return
	if world.modal_open: return
	var distance = minf(remaining,speed*delta)
	var next = global_position+direction*distance
	var query = PhysicsRayQueryParameters2D.create(global_position,next,5)
	query.hit_from_inside = true
	var hit = get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		resolved = true
		global_position = hit.position
		if hit.collider.is_in_group("enemy") and hit.collider.health>0:
			hit.collider.take_damage(damage,direction)
		queue_free()
		return
	global_position = next
	remaining -= distance
	if remaining<=0:
		resolved = true
		queue_free()
