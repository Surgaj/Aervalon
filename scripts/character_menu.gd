extends PanelContainer
const RACES = preload("res://scripts/races.gd").ALL
const CLASSES = preload("res://scripts/classes.gd").ALL
var list: VBoxContainer
var portrait: TextureRect
var description: Label
var name_input: LineEdit
var create_button: Button
var enter_button: Button
var delete_button: Button
var race_grid: GridContainer
var class_grid: GridContainer
var feedback: Label
var selected := ""
var race_id := "valen"
var class_id := "guardian"
var new_character := false
var deleting := ""
var deletion_name := ""
var confirm_panel: PanelContainer
var confirm_label: Label
func _ready():
	mouse_filter=Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel",panel_style(Color("101c22dd")))
	var column=VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	add_child(column)
	var title=Label.new()
	title.text="A E R V A L O N"
	title.add_theme_font_size_override("font_size",30)
	title.modulate=Color("ebd5a0")
	column.add_child(title)
	var body=HBoxContainer.new()
	body.size_flags_vertical=Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",18)
	column.add_child(body)
	var left=VBoxContainer.new()
	left.custom_minimum_size.x=235
	body.add_child(left)
	var caption=Label.new()
	caption.text="SEUS PERSONAGENS"
	caption.modulate=Color("c2b58e")
	left.add_child(caption)
	var scroll=ScrollContainer.new()
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	left.add_child(scroll)
	list=VBoxContainer.new()
	list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var add=make_button("Novo personagem")
	add.pressed.connect(func(): selected=""; new_character=true; refresh())
	left.add_child(add)
	portrait=TextureRect.new()
	portrait.custom_minimum_size=Vector2(200,220)
	portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	body.add_child(portrait)
	var right=VBoxContainer.new()
	right.custom_minimum_size.x=440
	right.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation",6)
	body.add_child(right)
	var race_label=Label.new()
	race_label.text="RAÇA"
	race_label.modulate=Color("c2b58e")
	right.add_child(race_label)
	race_grid=GridContainer.new()
	race_grid.columns=4
	right.add_child(race_grid)
	for id in RACES:
		var race_button=make_button(RACES[id].name)
		race_button.custom_minimum_size=Vector2(104,52)
		race_button.pressed.connect(func(): race_id=id; refresh())
		race_grid.add_child(race_button)
	var class_label=Label.new()
	class_label.text="CLASSE"
	class_label.modulate=Color("c2b58e")
	right.add_child(class_label)
	class_grid=GridContainer.new()
	class_grid.columns=5
	right.add_child(class_grid)
	for key in CLASSES:
		var class_button=make_button(CLASSES[key].name)
		class_button.custom_minimum_size=Vector2(84,48)
		class_button.add_theme_font_size_override("font_size",16)
		class_button.pressed.connect(func(): class_id=key; refresh())
		class_grid.add_child(class_button)
	description=Label.new()
	description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size",18)
	description.size_flags_vertical=Control.SIZE_EXPAND_FILL
	right.add_child(description)
	name_input=LineEdit.new()
	name_input.placeholder_text="Nome do personagem"
	name_input.max_length=20
	name_input.custom_minimum_size.y=54
	name_input.add_theme_font_size_override("font_size",22)
	right.add_child(name_input)
	create_button=make_button("Criar personagem")
	create_button.pressed.connect(create_character)
	right.add_child(create_button)
	enter_button=make_button("Entrar em Eryndor")
	enter_button.pressed.connect(enter_world)
	right.add_child(enter_button)
	delete_button=make_button("Excluir personagem")
	delete_button.modulate=Color("e4a69a")
	delete_button.pressed.connect(request_delete)
	right.add_child(delete_button)
	feedback=Label.new()
	feedback.add_theme_font_size_override("font_size",16)
	feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	feedback.modulate=Color("ebd5a0")
	column.add_child(feedback)
	# This overlay is outside the content container: it covers all profile actions.
	var shield=Control.new()
	shield.name="DeleteShield"
	shield.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shield.mouse_filter=Control.MOUSE_FILTER_STOP
	add_child(shield)
	confirm_panel=PanelContainer.new()
	confirm_panel.add_theme_stylebox_override("panel",panel_style(Color("211b21ff")))
	confirm_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shield.add_child(confirm_panel)
	var confirm_column=VBoxContainer.new()
	confirm_panel.add_child(confirm_column)
	confirm_label=Label.new()
	confirm_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	confirm_label.add_theme_font_size_override("font_size",24)
	confirm_label.size_flags_vertical=Control.SIZE_EXPAND_FILL
	confirm_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	confirm_column.add_child(confirm_label)
	var cancel=make_button("Cancelar exclusão")
	cancel.pressed.connect(func(): deleting=""; shield.hide())
	confirm_column.add_child(cancel)
	var confirm=make_button("Excluir definitivamente")
	confirm.modulate=Color("eeaaa0")
	confirm.pressed.connect(confirm_delete)
	confirm_column.add_child(confirm)
	shield.hide()
	open()
func panel_style(color: Color) -> StyleBoxFlat:
	var s=StyleBoxFlat.new()
	s.bg_color=color
	s.border_color=Color("a48a59")
	s.set_border_width_all(2)
	s.set_corner_radius_all(8)
	s.content_margin_left=20
	s.content_margin_right=20
	s.content_margin_top=14
	s.content_margin_bottom=14
	return s
func make_button(text: String) -> Button:
	var b=Button.new()
	b.text=text
	b.custom_minimum_size.y=62
	b.add_theme_font_size_override("font_size",18)
	b.focus_mode=Control.FOCUS_NONE
	return b
func open():
	selected=Roster.active_id
	new_character=Roster.profiles.is_empty()
	refresh()
func refresh():
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	for id in Roster.profiles:
		var p=Roster.profiles[id]
		var b=make_button("%s\n%s • %s • Nv. %d" % [p.name,RACES[p.race].name,CLASSES[p.get("class","guardian")].name,p.data.level])
		b.disabled=id==selected and not new_character
		b.pressed.connect(func(): selected=id; new_character=false; feedback.text=""; refresh())
		list.add_child(b)
	var r=preload("res://scripts/rpg_state.gd").new()
	if not new_character and Roster.profiles.has(selected):
		r.restore(Roster.profiles[selected].data)
		race_id=Roster.profiles[selected].race
		class_id=Roster.profiles[selected].get("class","guardian")
	r.race=race_id
	r.class_id=class_id
	portrait.texture=preload("res://scripts/actor_visual.gd").portrait_for(r)
	var race=RACES[race_id]
	var class_data=CLASSES[class_id]
	for b in race_grid.get_children(): b.disabled=b.text==race.name
	for b in class_grid.get_children(): b.disabled=b.text==class_data.name
	description.text=("%s • %s\n%s • Origem: %s\n%s\n\nArmas: %s\nCaminhos: %s\nPoder: %s" % [race.name,class_data.name,race.faction,race.origin,race.description,class_data.weapons,class_data.specializations,class_data.power]) if new_character else ("%s\n%s • %s • Nível %d\n%s\nOrigem: %s\n\nAtaque %d   Defesa %d   Vida %d\nPoder: %s\n%d moedas" % [Roster.profiles.get(selected,{}).get("name","Viajante"),race.name,class_data.name,r.level,race.faction,race.origin,r.attack(),r.defense(),r.max_health(),class_data.power,r.coins])
	race_grid.visible=new_character
	class_grid.visible=new_character
	name_input.visible=new_character
	create_button.visible=new_character
	enter_button.visible=not new_character
	delete_button.visible=not new_character
	enter_button.disabled=not Roster.profiles.has(selected) or Roster.blocked
	delete_button.disabled=enter_button.disabled
	create_button.disabled=Roster.profiles.size()>=Roster.MAX_CHARACTERS or Roster.blocked
	feedback.text="Raça e classe ficam ligadas ao personagem. As 10 classes já usam atributos, armas iniciais e poder próprio; especializações e arte completa de armas entram nas próximas etapas. Até 8 personagens." if not Roster.blocked else "Não foi possível ler o save. Seus dados foram preservados; recarregue para tentar novamente."
func create_character():
	var id=Roster.create_character(name_input.text,race_id,class_id)
	if id=="":
		feedback.text="Use um nome único de 2–20 caracteres. Limite: 8 personagens. Verifique se o navegador permite salvar."
		return
	selected=id
	new_character=false
	name_input.text=""
	refresh()
func enter_world():
	if not Roster.select_character(selected):
		feedback.text="Não foi possível salvar a seleção. Tente novamente."
		return
	Roster.in_game=true
	get_tree().change_scene_to_file("res://scenes/world/eryndor.tscn")
func request_delete():
	if not Roster.profiles.has(selected): return
	deleting=selected
	deletion_name=Roster.profiles[selected].name
	confirm_label.text="Excluir %s?\n\nTodo o progresso deste personagem será removido deste navegador. Os demais personagens serão mantidos.\n\nEsta ação não pode ser desfeita pelo jogo." % deletion_name
	$DeleteShield.show()
func confirm_delete():
	if not Roster.delete_character(deleting,deletion_name):
		confirm_label.text="Não foi possível excluir. O personagem foi preservado. Cancele e tente novamente."
		return
	deleting=""
	$DeleteShield.hide()
	open()
func qa_buttons() -> Dictionary:
	var result := {}
	var scope=$DeleteShield if $DeleteShield.visible else self
	for b in scope.find_children("*","Button",true,false):
		if b.is_visible_in_tree() and not b.disabled:
			var point=b.get_global_rect().get_center()
			result[b.text]=[point.x,point.y]
	if name_input.visible and not $DeleteShield.visible:
		var point=name_input.get_global_rect().get_center()
		result["Nome do personagem"]=[point.x,point.y]
	return result
