extends CanvasLayer
var world
var root: Control
var health: ProgressBar
var health_text: Label
var quest: Label
var message_panel: Panel
var message_title: Label
var message_body: Label
var dodge_button: Button
var attack_button: Button
var interact_button: Button
var portrait_warning: Panel
var coins: Label
var joystick: Control
var minimap: Control
var character_menu
var inventory_panel
var inventory_button: Button
var level_label: Label
var xp_label: Label
var interaction_hint: Label
var joy_touch := -1
var joy_vector := Vector2.ZERO
var joy_center := Vector2.ZERO
const RADIUS := 58.0
func _ready():
	world = get_tree().current_scene
	root = Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var status = panel(Vector2(22,20),Vector2(280,82))
	level_label = label(status,"AERVALON  /  Nv. 1",Vector2(16,9),18,Color(0.95,0.85,0.59))
	health = ProgressBar.new()
	health.position = Vector2(16,39)
	health.size = Vector2(248,24)
	health.show_percentage = false
	health.add_theme_stylebox_override("background",box(Color(0.14,0.08,0.07),5))
	health.add_theme_stylebox_override("fill",box(Color(0.65,0.12,0.12),5))
	status.add_child(health)
	health_text = label(status,"100 / 100",Vector2(103,40),16)
	xp_label = label(root,"",Vector2(26,101),14,Color.LIGHT_SKY_BLUE)
	var quest_panel = panel(Vector2(22,116),Vector2(295,78))
	quest = label(quest_panel,"",Vector2(14,10),17,Color(0.96,0.87,0.65))
	coins = label(root,"",Vector2(26,205),16,Color(0.95,0.82,0.52))
	joystick = Control.new()
	joystick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(joystick)
	joystick.draw.connect(_draw_joystick)
	attack_button = button("",Vector2(108,108),Color(0.35,0.065,0.07))
	attack_button.icon = load("res://assets/aervalon/ui/sword.svg")
	attack_button.add_theme_constant_override("icon_max_width",46)
	attack_button.button_down.connect(func(): world.player.attack())
	dodge_button = button("Esquiva",Vector2(86,86),Color(0.13,0.20,0.26))
	dodge_button.button_down.connect(func(): world.player.dodge())
	interact_button = button("Falar",Vector2(86,86),Color(0.11,0.18,0.17))
	interact_button.button_down.connect(func(): world.interact_nearby())
	message_panel = panel(Vector2.ZERO,Vector2(570,123))
	message_title = label(message_panel,"",Vector2(18,12),21,Color(1,0.86,0.52))
	message_body = label(message_panel,"",Vector2(18,43),18)
	message_body.size = Vector2(534,76)
	message_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	interaction_hint = label(root,"",Vector2.ZERO,17,Color("f0d18c"))
	minimap = Control.new()
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(minimap)
	minimap.draw.connect(_draw_map)
	portrait_warning = panel(Vector2.ZERO,Vector2(380,95))
	label(portrait_warning,"Gire o celular para jogar",Vector2(20,15),24,Color(1,0.86,0.55))
	label(portrait_warning,"Aervalon foi feito para a tela deitada.",Vector2(20,52),17)
	inventory_button = button("Mochila",Vector2(128,54),Color(0.14,0.19,0.16))
	inventory_button.pressed.connect(func(): open_inventory())
	inventory_panel = PanelContainer.new()
	inventory_panel.set_script(preload("res://scripts/inventory_panel.gd"))
	root.add_child(inventory_panel)
	character_menu = PanelContainer.new()
	character_menu.set_script(preload("res://scripts/character_menu.gd"))
	root.add_child(character_menu)
	inventory_panel.minimum_size_changed.connect(func(): layout.call_deferred())
	character_menu.minimum_size_changed.connect(func(): layout.call_deferred())
	get_viewport().size_changed.connect(layout)
	layout()
func box(color: Color, radius: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.55,0.45,0.28)
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	return style
func panel(point: Vector2, dimensions: Vector2) -> Panel:
	var p = Panel.new()
	p.position = point
	p.size = dimensions
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel",box(Color(0.035,0.047,0.043,0.91),8))
	root.add_child(p)
	return p
func label(parent: Node, value: String, point: Vector2, font_size: int, color := Color(0.94,0.93,0.86)) -> Label:
	var l = Label.new()
	l.text = value
	l.position = point
	l.add_theme_font_size_override("font_size",font_size)
	l.modulate = color
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l
func button(value: String, dimensions: Vector2, color: Color) -> Button:
	var b = Button.new()
	b.text = value
	b.size = dimensions
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size",18)
	b.add_theme_stylebox_override("normal",box(color,54))
	b.add_theme_stylebox_override("pressed",box(color.lightened(0.25),54))
	b.add_theme_stylebox_override("hover",box(color.lightened(0.08),54))
	root.add_child(b)
	return b
func layout():
	var size = get_viewport().get_visible_rect().size
	root.size = size
	joy_center = Vector2(105,size.y-110)
	joystick.position = joy_center
	attack_button.position = size-Vector2(145,155)
	interact_button.position = size-Vector2(252,123)
	dodge_button.position = size-Vector2(140,263)
	message_panel.position = Vector2((size.x-570)*0.5,size.y-155)
	interaction_hint.position = Vector2(size.x-380,size.y-195)
	minimap.position = Vector2(size.x-184,24)
	portrait_warning.position = size*0.5-Vector2(190,47)
	portrait_warning.visible = size.y>size.x
	inventory_button.position = Vector2(size.x-170,140)
	var ui_scale = clampf(size.x/1150.0,1.0,1.35)
	inventory_panel.scale = Vector2.ONE*ui_scale
	inventory_panel.size = Vector2(minf(930,(size.x-64)/ui_scale),minf(500,(size.y-64)/ui_scale))
	inventory_panel.position = (size-inventory_panel.size*ui_scale)*0.5
	character_menu.scale = Vector2.ONE*ui_scale
	character_menu.size = Vector2(minf(1080,(size.x-64)/ui_scale),minf(580,(size.y-40)/ui_scale))
	character_menu.position = (size-character_menu.size*ui_scale)*0.5
	joystick.queue_redraw()
func open_inventory(shop_id := ""):
	if world.player.death_time>0 or character_menu.visible: return
	inventory_panel.open(shop_id)
func refresh():
	health.max_value = world.player.max_health
	health.value = world.player.health
	level_label.text = "AERVALON  /  Nv. %d" % world.rpg.level
	xp_label.text = "XP %d / %d" % [world.rpg.xp,world.rpg.xp_needed()]
	health_text.text = "%d / %d" % [world.player.health,world.player.max_health]
	quest.text = world.quest_text()
	interaction_hint.text = world.nearest_npc.npc_name if world.nearest_npc and not world.modal_open else ""
	if world.nearest_object and not world.modal_open: interaction_hint.text = world.nearest_object.title()
	coins.text = "%d moedas" % world.coins
	message_panel.visible = world.message_time>0 and not world.modal_open
	interact_button.text = ("Loja" if world.nearest_npc.appearance in ["borin","merchant"] else "Falar") if world.nearest_npc else "Usar"
	if world.nearest_object: interact_button.text = world.nearest_object.action_text()
	dodge_button.text = "%.1f" % world.player.dodge_cooldown if world.player.dodge_cooldown>0 else "Esquiva"
	dodge_button.modulate = Color(0.7,0.7,0.7) if world.player.dodge_cooldown>0 else Color.WHITE
	attack_button.modulate = Color(0.7,0.7,0.7) if world.player.attack_cooldown>0 else Color.WHITE
	minimap.queue_redraw()
func _input(event):
	if is_instance_valid(character_menu) and character_menu.visible: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_ESCAPE and world.modal_open: inventory_panel.close()
		elif event.physical_keycode==KEY_I:
			if world.modal_open: inventory_panel.close()
			else: open_inventory()
	if world.modal_open: return
	if event is InputEventScreenTouch:
		if event.pressed and event.position.distance_to(joy_center)<100 and joy_touch == -1:
			joy_touch = event.index
			_update_joystick(event.position)
		elif not event.pressed and event.index == joy_touch:
			joy_touch = -1
			joy_vector = Vector2.ZERO
			world.player.set_touch_direction(Vector2.ZERO)
			joystick.queue_redraw()
	elif event is InputEventScreenDrag and event.index == joy_touch:
		_update_joystick(event.position)
func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(world):
		joy_touch = -1
		joy_vector = Vector2.ZERO
		world.player.set_touch_direction(Vector2.ZERO)
func _update_joystick(point: Vector2):
	joy_vector = (point-joy_center).limit_length(RADIUS)
	world.player.set_touch_direction(joy_vector/RADIUS)
	joystick.queue_redraw()
func _draw_joystick():
	joystick.draw_circle(Vector2.ZERO,76,Color(0.025,0.035,0.03,0.65))
	joystick.draw_arc(Vector2.ZERO,76,0,TAU,64,Color(0.65,0.56,0.37),3,true)
	joystick.draw_circle(joy_vector,28,Color(0.64,0.66,0.57,0.85))
	joystick.draw_arc(joy_vector,28,0,TAU,32,Color(0.86,0.81,0.66),2,true)
func _draw_map():
	minimap.draw_style_box(box(Color(0.06,0.105,0.07,0.92),10),Rect2(0,0,160,103))
	minimap.draw_line(Vector2(80,3),Vector2(80,100),Color(0.15,0.39,0.48),10)
	minimap.draw_line(Vector2(32,56),Vector2(144,56),Color(0.67,0.56,0.35),4)
	for p in [Vector2(30,34),Vector2(59,36),Vector2(30,66)]:
		minimap.draw_rect(Rect2(p,Vector2(12,10)),Color(0.55,0.62,0.69))
	var position = world.player.position/Vector2(1900,1100)*Vector2(156,99)+Vector2(2,2)
	minimap.draw_circle(position,4,Color(1,0.89,0.48))
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.health>0: minimap.draw_circle(enemy.position/Vector2(1900,1100)*Vector2(156,99)+Vector2(2,2),2,Color(0.95,0.32,0.2))
