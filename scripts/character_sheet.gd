extends HBoxContainer
var world
var portrait: TextureRect
var identity: Label
var slots: Label
var remove_armor: Button
func _ready():
	world=get_tree().current_scene
	add_theme_constant_override("separation",24)
	portrait=TextureRect.new()
	portrait.custom_minimum_size=Vector2(170,120)
	portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	add_child(portrait)
	var scroll=ScrollContainer.new()
	scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size=Vector2(280,0)
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var right=VBoxContainer.new()
	right.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(right)
	identity=Label.new()
	identity.add_theme_font_size_override("font_size",21)
	right.add_child(identity)
	slots=Label.new()
	slots.add_theme_font_size_override("font_size",19)
	slots.size_flags_vertical=Control.SIZE_EXPAND_FILL
	right.add_child(slots)
	remove_armor=world.hud.inventory_panel.make_button("Retirar armadura")
	remove_armor.pressed.connect(func():
		world.rpg.equipment.armor=""
		world.player.visual.apply_equipment(world.rpg)
		world.persist()
		world.hud.inventory_panel.refresh())
	right.add_child(remove_armor)
	var characters=world.hud.inventory_panel.make_button("Personagens")
	characters.pressed.connect(func():
		if world.persist():
			Roster.in_game=false
			get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn"))
	right.add_child(characters)
func refresh():
	var r=world.rpg
	portrait.texture=preload("res://scripts/actor_visual.gd").portrait_for(r)
	var class_data=preload("res://scripts/classes.gd").ALL[r.class_id]
	identity.text="%s\n%s • %s" % [Roster.profiles.get(r.profile_id,{}).get("name","Viajante"),preload("res://scripts/races.gd").ALL[r.race].name,class_data.name]
	slots.text="Arma: %s\nArmadura: %s\n\nArmas da classe: %s\nPoder: %s" % [r.ITEMS.get(r.equipment.weapon,{"name":"Nenhuma"}).name,r.ITEMS.get(r.equipment.armor,{"name":"Roupa de linho"}).name,class_data.weapons,class_data.power]
	remove_armor.disabled=r.equipment.armor==""
