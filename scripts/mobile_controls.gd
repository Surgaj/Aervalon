extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var knob = $Joystick/Knob
var joy_touch := -1
var joy_center := Vector2.ZERO
const RADIUS := 62.0

func _ready():
	joy_center = $Joystick.global_position + Vector2(72,72)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < 330 and event.position.y > 430 and joy_touch == -1:
			joy_touch = event.index
			_update_joystick(event.position)
		elif not event.pressed and event.index == joy_touch:
			joy_touch = -1
			knob.position = Vector2(48,48)
			if player: player.set_touch_direction(Vector2.ZERO)
		elif event.pressed and event.position.x > get_viewport().get_visible_rect().size.x - 260 and event.position.y > 430:
			if player: player.attack()
	elif event is InputEventScreenDrag and event.index == joy_touch:
		_update_joystick(event.position)

func _update_joystick(pos: Vector2):
	var delta = pos - joy_center
	var clamped = delta.limit_length(RADIUS)
	knob.position = Vector2(48,48) + clamped
	if player: player.set_touch_direction(clamped / RADIUS)
