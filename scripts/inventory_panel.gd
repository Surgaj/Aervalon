extends PanelContainer
var world
var shop := ""
var mode := "Mochila"
var category := "Todos"
var selected := ""
var heading: Label
var stats: Label
var grid: GridContainer
var detail: Label
var feedback: Label
var action: Button
var equip_action: Button
var tabs: HBoxContainer
var categories: HBoxContainer
var body: HBoxContainer
var character_sheet
func _ready():
	world = get_tree().current_scene
	mouse_filter = Control.MOUSE_FILTER_STOP
	var style = StyleBoxFlat.new()
	style.bg_color = Color("15221ff5")
	style.border_color = Color("ad9060")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	add_theme_stylebox_override("panel",style)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	add_child(column)
	var top = HBoxContainer.new()
	column.add_child(top)
	heading = Label.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_font_size_override("font_size",24)
	top.add_child(heading)
	var close_button = make_button("Fechar  ×")
	close_button.pressed.connect(close)
	top.add_child(close_button)
	stats = Label.new()
	stats.add_theme_font_size_override("font_size",17)
	column.add_child(stats)
	tabs = HBoxContainer.new()
	column.add_child(tabs)
	for title in ["Mochila","Personagem","Comprar","Vender"]:
		var button = make_button(title)
		button.pressed.connect(func(): mode=title; selected=""; refresh())
		tabs.add_child(button)
	categories = HBoxContainer.new()
	column.add_child(categories)
	for title in ["Todos","Consumíveis","Materiais","Equipamentos","Itens de missão"]:
		var button = make_button(title)
		button.add_theme_font_size_override("font_size",17)
		button.custom_minimum_size.y = 40
		button.pressed.connect(func(): category=title; selected=""; refresh())
		categories.add_child(button)
	body = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.x = 370
	body.add_child(scroll)
	grid = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation",7)
	grid.add_theme_constant_override("v_separation",7)
	scroll.add_child(grid)
	var right = VBoxContainer.new()
	right.custom_minimum_size.x = 240
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	detail = Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_theme_font_size_override("font_size",18)
	right.add_child(detail)
	action = make_button("Selecionar item")
	action.pressed.connect(transact)
	right.add_child(action)
	equip_action = make_button("Usar / Equipar")
	equip_action.pressed.connect(func(): feedback.text=world.use_item(selected); refresh())
	right.add_child(equip_action)
	character_sheet=HBoxContainer.new()
	character_sheet.set_script(preload("res://scripts/character_sheet.gd"))
	character_sheet.size_flags_vertical=Control.SIZE_EXPAND_FILL
	column.add_child(character_sheet)
	feedback = Label.new()
	feedback.add_theme_font_size_override("font_size",17)
	feedback.modulate = Color("f0d18c")
	column.add_child(feedback)
	visible = false
func make_button(text: String) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size.y = 60
	button.add_theme_font_size_override("font_size",18)
	return button
func open(shop_id := ""):
	shop = shop_id
	world.shop = shop
	mode = "Comprar" if shop!="" else "Mochila"
	category = "Todos"
	selected = ""
	feedback.text = "Borin: uma boa lâmina faz diferença." if shop=="borin" else ("Nilo: provisões para a estrada, viajante?" if shop=="merchant" else "Toque em um item para ver os detalhes.")
	world.modal_open = true
	world.player.set_touch_direction(Vector2.ZERO)
	world.player.attack_time = 0
	world.player.dodge_time = 0
	world.player.visual.rotation = 0
	world.hud.joy_touch = -1
	world.hud.joy_vector = Vector2.ZERO
	world.hud.joystick.queue_redraw()
	visible = true
	refresh()
func close():
	visible = false
	world.modal_open = false
	world.shop = ""
	world.player.hit_time = maxf(world.player.hit_time,0.5)
	world.persist()
func refresh():
	heading.text = "Borin • Ferraria" if shop=="borin" else ("Nilo • Mercado" if shop=="merchant" else "Sua mochila")
	var r = world.rpg
	stats.text = "%d moedas   •   Nv. %d   •   Ataque %d   •   Defesa %d   •   Vida %d/%d" % [r.coins,r.level,r.attack(),r.defense(),world.player.health,world.player.max_health]
	for button in tabs.get_children():
		button.visible = button.text in ["Mochila","Personagem"] or shop!=""
		button.disabled = button.text==mode
	character_sheet.visible=mode=="Personagem"
	body.visible=mode!="Personagem"
	categories.visible=mode!="Personagem"
	if mode=="Personagem":
		character_sheet.refresh()
		feedback.text="Equipe itens pela aba Mochila. Arma e armadura estão disponíveis nesta etapa."
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	var ids = r.SHOPS.get(shop,[]) if mode=="Comprar" else r.inventory.keys()
	for id in ids:
		var item = r.ITEMS[id]
		if category!="Todos" and item.type!=category: continue
		var button = make_button(item.name.replace(" ","\n")+("\n%d moedas" % item.price if mode=="Comprar" else "\n×%d" % r.inventory[id]))
		button.icon = load("res://assets/aervalon/ui/"+item.icon+".svg")
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width",26)
		button.add_theme_font_size_override("font_size",17)
		button.custom_minimum_size = Vector2(120,110)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): selected=id; refresh_detail())
		grid.add_child(button)
	refresh_detail()
func refresh_detail():
	var r = world.rpg
	if selected=="" or not r.ITEMS.has(selected) or (mode!="Comprar" and not r.inventory.has(selected)):
		selected=""
		detail.text="Selecione um item.\n\nArma: %s\nArmadura: %s" % [r.ITEMS.get(r.equipment.weapon,{"name":"Nenhuma"}).name,r.ITEMS.get(r.equipment.armor,{"name":"Nenhuma"}).name]
		action.disabled=true
		action.text="Selecione um item"
		equip_action.visible=false
		return
	var item = r.ITEMS[selected]
	detail.text = "%s\n%s\n%s\nVenda: %d moedas%s" % [item.name,item.type,item.description,item.value,"\nEquipado" if selected in r.equipment.values() else ""]
	action.disabled=false
	action.text="Comprar • %d" % item.price if mode=="Comprar" else ("Vender 1 • %d" % item.value if mode=="Vender" else ("Equipar" if item.has("slot") else "Usar"))
	if mode=="Mochila": action.disabled=not item.has("slot") and not item.has("heal")
	equip_action.visible=false
func transact():
	if selected=="": return
	if mode=="Comprar": feedback.text=world.rpg.buy(selected,shop)
	elif mode=="Vender" and shop!="": feedback.text=world.rpg.sell(selected)
	else: feedback.text=world.use_item(selected)
	world.persist()
	refresh()

func qa_buttons() -> Dictionary:
	var result := {}
	if not visible: return result
	for button in find_children("*","Button",true,false):
		if button.is_visible_in_tree() and not button.disabled:
			var point = button.get_global_rect().get_center()
			result[button.text] = [point.x,point.y]
	return result
