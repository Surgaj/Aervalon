extends PanelContainer
var world
var list: VBoxContainer
var portrait: TextureRect
var description: Label
var name_input: LineEdit
var create_button: Button
var enter_button: Button
var feedback: Label
var selected := ""
var new_character := false
func _ready():
	world = get_tree().current_scene
	mouse_filter = Control.MOUSE_FILTER_STOP
	var style = world.hud.box(Color("111b20f5"),12)
	style.content_margin_left=24
	style.content_margin_right=24
	style.content_margin_top=18
	style.content_margin_bottom=18
	add_theme_stylebox_override("panel",style)
	var column=VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	add_child(column)
	var title=Label.new()
	title.text="A E R V A L O N"
	title.add_theme_font_size_override("font_size",32)
	title.modulate=Color("ebd5a0")
	column.add_child(title)
	var subtitle=Label.new()
	subtitle.text="Sua jornada começa em Eryndor • Elden"
	subtitle.add_theme_font_size_override("font_size",19)
	column.add_child(subtitle)
	var body=HBoxContainer.new()
	body.size_flags_vertical=Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",20)
	column.add_child(body)
	var left=VBoxContainer.new()
	left.custom_minimum_size.x=270
	body.add_child(left)
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
	portrait.custom_minimum_size=Vector2(240,280)
	portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	body.add_child(portrait)
	var right=VBoxContainer.new()
	right.custom_minimum_size.x=320
	right.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	body.add_child(right)
	description=Label.new()
	description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_size_override("font_size",21)
	description.size_flags_vertical=Control.SIZE_EXPAND_FILL
	right.add_child(description)
	name_input=LineEdit.new()
	name_input.placeholder_text="Nome do personagem"
	name_input.max_length=20
	name_input.custom_minimum_size.y=56
	name_input.add_theme_font_size_override("font_size",22)
	right.add_child(name_input)
	create_button=make_button("Criar personagem")
	create_button.pressed.connect(create_character)
	right.add_child(create_button)
	enter_button=make_button("Entrar em Eryndor")
	enter_button.pressed.connect(enter_world)
	right.add_child(enter_button)
	feedback=Label.new()
	feedback.add_theme_font_size_override("font_size",17)
	feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	feedback.modulate=Color("ebd5a0")
	column.add_child(feedback)
	visible=false
func make_button(text: String) -> Button:
	var b=Button.new()
	b.text=text
	b.custom_minimum_size.y=58
	b.add_theme_font_size_override("font_size",19)
	return b
func open():
	world.modal_open=true
	visible=true
	selected=Roster.active_id
	new_character=Roster.profiles.is_empty()
	refresh()
func refresh():
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	for id in Roster.profiles:
		var p=Roster.profiles[id]
		var b=make_button("%s\nNv. %d • Guardião" % [p.name,p.data.level])
		b.disabled=id==selected and not new_character
		b.pressed.connect(func(): selected=id; new_character=false; feedback.text=""; refresh())
		list.add_child(b)
	var r=preload("res://scripts/rpg_state.gd").new()
	if not new_character and Roster.profiles.has(selected): r.restore(Roster.profiles[selected].data)
	portrait.texture=preload("res://scripts/actor_visual.gd").portrait_for(r)
	description.text="VALEN • GUARDIÃO\nPacto da Superfície\n\nEryndor • Elden\nEspada e esquiva.\nRoupa simples, sem armadura." if new_character else "%s\nValen • Guardião • Nível %d\n\nAtaque %d   Defesa %d\n%d moedas\n\nEryndor • Elden" % [Roster.profiles.get(selected,{}).get("name","Viajante"),r.level,r.attack(),r.defense(),r.coins]
	name_input.visible=new_character
	create_button.visible=new_character
	enter_button.visible=not new_character
	enter_button.disabled=not Roster.profiles.has(selected) or Roster.blocked
	create_button.disabled=Roster.profiles.size()>=6 or Roster.blocked
	feedback.text="As outras raças, classes e opções de aparência chegarão com suas próprias aventuras. Até 6 personagens." if not Roster.blocked else "Não foi possível ler o save. Seus dados foram preservados; recarregue para tentar novamente."
func create_character():
	var id=Roster.create_character(name_input.text)
	if id=="":
		feedback.text="Use um nome único de 2–20 letras. Limite: 6 personagens. Verifique se o navegador permite salvar."
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
func qa_buttons() -> Dictionary:
	var result := {}
	if not visible: return result
	for b in find_children("*","Button",true,false):
		if b.is_visible_in_tree() and not b.disabled:
			var point=b.get_global_rect().get_center()
			result[b.text]=[point.x,point.y]
	if name_input.visible:
		var point=name_input.get_global_rect().get_center()
		result["Nome do personagem"]=[point.x,point.y]
	return result
