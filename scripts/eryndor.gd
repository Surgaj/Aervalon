extends Node2D
const PLAYER = preload("res://scenes/actors/player.tscn")
const NPC = preload("res://scenes/actors/npc.tscn")
const WOLF = preload("res://scenes/actors/wolf.tscn")
var player
var hud
var quest_started := false
var quest_kills := 0
var quest_target := 3
var quest_complete := false
var chest_open := false
var rpg = preload("res://scripts/rpg_state.gd").new()
var modal_open := false
var shop := ""
var coins: int:
	get: return rpg.coins
	set(value): rpg.coins = value
var message_time := 0.0
var qa_enabled := false
var qa_clock := 0.0
var nearest_npc
func _ready():
	rpg.save_enabled = not "--test" in OS.get_cmdline_user_args()
	rpg.load_game()
	quest_started = rpg.quest != "available"
	quest_complete = rpg.quest == "complete"
	quest_kills = rpg.kills
	chest_open = rpg.chest_open
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var key = InputEventKey.new()
		key.physical_keycode = KEY_E
		InputMap.action_add_event("interact",key)
	player = PLAYER.instantiate()
	player.position = Vector2(610,590)
	$YSortWorld.add_child(player)
	player.max_health = rpg.max_health()
	player.health = player.max_health
	spawn_npc("Mara","mara",Vector2(650,540),25)
	spawn_npc("Borin, o ferreiro","borin",Vector2(670,339),0)
	spawn_npc("Nilo, mercador","merchant",Vector2(490,665),0)
	spawn_npc("Eldric","eldric",Vector2(585,795),20)
	spawn_npc("Guarda de Eryndor","guard",Vector2(827,560),35)
	spawn_npc("Galinha","hen",Vector2(440,530),40)
	for point in [Vector2(1250,570),Vector2(1450,655),Vector2(1640,530)]:
		var wolf = WOLF.instantiate()
		wolf.position = point
		$YSortWorld.add_child(wolf)
		wolf.died.connect(_enemy_died.bind(wolf))
	var chest = Sprite2D.new()
	chest.name = "Chest"
	chest.texture = load("res://assets/aervalon/v2/chest.png")
	chest.position = Vector2(1620,940)
	chest.scale = Vector2.ONE*0.25
	$YSortWorld.add_child(chest)
	hud = CanvasLayer.new()
	hud.set_script(load("res://scripts/mobile_controls.gd"))
	add_child(hud)
	if OS.has_feature("web"):
		qa_enabled = "qa=1" in str(JavaScriptBridge.eval("window.location.search", true))
		print("Aervalon Web QA enabled: ", qa_enabled)
	show_message("Vale de Eryndor","Fale com Mara junto à ponte. WASD / setas para andar • E para falar • Espaço para atacar.")
func spawn_npc(title: String, appearance: String, point: Vector2, radius: float):
	var npc = NPC.instantiate()
	npc.npc_name = title
	npc.appearance = appearance
	npc.position = point
	npc.wander_radius = radius
	$YSortWorld.add_child(npc)
func _process(delta):
	if not is_instance_valid(player): return
	message_time = maxf(0,message_time-delta)
	nearest_npc = null
	var best := 100.0
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.appearance == "hen": continue
		var interact_point = npc.global_position+Vector2(0,80) if npc.appearance=="borin" else npc.global_position
		var distance = player.global_position.distance_to(interact_point)
		if distance<best:
			best = distance
			nearest_npc = npc
	if is_instance_valid(hud): hud.refresh()
	if qa_enabled:
		qa_clock += delta
		if qa_clock>0.1:
			qa_clock = 0
			var state = {"position":[player.position.x,player.position.y],"health":player.health,"quest_started":quest_started,"kills":quest_kills,"complete":quest_complete,"viewport":[hud.root.size.x,hud.root.size.y],"joystick":[hud.joy_center.x,hud.joy_center.y],"attack":[hud.attack_button.position.x+54,hud.attack_button.position.y+54],"portrait":hud.portrait_warning.visible,"modal":modal_open,"level":rpg.level,"xp":rpg.xp,"coins":coins,"equipment":rpg.equipment,"inventory":rpg.inventory,"shop":shop,"buttons":hud.inventory_panel.qa_buttons()}
			JavaScriptBridge.eval("document.querySelector('canvas').dataset.aervalon="+JSON.stringify(JSON.stringify(state)), true)
func interact_nearby():
	if player.death_time>0 or modal_open: return
	if nearest_npc:
		nearest_npc.interact()
	elif player.global_position.distance_to(Vector2(1620,940))<95:
		if not chest_open:
			chest_open = true
			coins += 10
			persist()
			$YSortWorld/Chest.modulate = Color(0.5,0.5,0.5)
			show_message("Um achado entre as raízes","Você encontrou 10 moedas. Há recompensas fora da estrada.")
		else: show_message("Baú vazio","Você já recolheu este tesouro.")
	else: show_message("Explore Eryndor","Aproxime-se de um morador ou procure algo entre as árvores.")
func npc_dialogue(npc):
	match npc.appearance:
		"mara":
			if quest_complete:
				show_message("Mara","A estrada voltou a respirar. Obrigada, viajante.")
			elif quest_kills>=quest_target:
				quest_complete = true
				coins += 25
				rpg.add_item("mara_token")
				grant_xp(45)
				player.health = player.max_health
				show_message("Estrada Segura • concluída","Mara: Agora podemos levar as mercadorias! +25 moedas • +45 XP • Vida restaurada.")
			elif not quest_started:
				quest_started = true
				show_message("Mara • Ameaça na Mata","Os lobos se aproximaram da ponte. Derrote 3 na estrada e volte a falar comigo.")
			else: show_message("Mara","Atravessando a ponte você encontrará os lobos. Cuidado: recue quando prepararem o bote.")
		"borin":
			hud.open_inventory("borin")
			show_message("Borin", "Uma boa lâmina faz diferença. Veja minhas peças; também compro seus materiais.")
		"merchant":
			hud.open_inventory("merchant")
			show_message("Nilo", "Pão fresco e poções para a estrada. Posso comprar o que encontrou na floresta.")
		"eldric": show_message("Eldric","Eryndor é só o começo. Além da floresta, as ruínas de Thal’Kor ainda guardam suas histórias.")
		_: show_message(npc.npc_name,"Mara precisa de ajuda. A estrada do outro lado da ponte já não é segura.")
	persist()
func _enemy_died(wolf = null):
	if quest_started and not quest_complete:
		quest_kills = mini(quest_kills+1,quest_target)
		if quest_kills>=quest_target: show_message("Estrada Segura","Volte à vila e fale com Mara.")
	grant_xp(20)
	if is_instance_valid(wolf):
		var loot = Node2D.new()
		loot.set_script(preload("res://scripts/loot.gd"))
		loot.position = wolf.position
		loot.items = {"wolf_pelt":1}
		if randf()<0.5: loot.items["wolf_fang"]=1
		loot.coins = randi_range(1,3)
		$YSortWorld.add_child(loot)
	persist()
func grant_xp(amount: int):
	var leveled = rpg.add_xp(amount)
	player.max_health = rpg.max_health()
	if leveled:
		player.health = player.max_health
		show_message("Nível %d!" % rpg.level,"Ataque +2 • Vida máxima +8 • Vida restaurada")
		damage_number(player.position,rpg.level,Color.GOLD)
	else: damage_number(player.position,amount,Color.LIGHT_SKY_BLUE)
func persist():
	rpg.quest = "complete" if quest_complete else ("return" if quest_kills>=3 else ("active" if quest_started else "available"))
	rpg.kills = quest_kills
	rpg.chest_open = chest_open
	if not rpg.save_game(): show_message("Não foi possível salvar", "O navegador bloqueou o armazenamento. Mantenha esta aba aberta para preservar esta sessão.")
func use_item(id: String) -> String:
	if not rpg.inventory.has(id): return "Item indisponível"
	var item = rpg.ITEMS[id]
	if item.has("slot"):
		rpg.equip(id)
		persist()
		return "Equipado • Ataque %d • Defesa %d" % [rpg.attack(),rpg.defense()]
	if item.has("heal"):
		if player.health>=player.max_health: return "Sua vida já está cheia"
		player.health = mini(player.max_health,player.health+int(item.heal))
		rpg.remove_item(id)
		persist()
		return "Vida recuperada"
	return "Este item não pode ser usado"
func quest_text() -> String:
	if quest_complete: return "ESTRADA SEGURA\nConcluída • Explore o vale"
	if quest_kills>=quest_target: return "ESTRADA SEGURA\nVolte à vila • Fale com Mara"
	if quest_started: return "AMEAÇA NA MATA\nLobos derrotados  %d / 3" % quest_kills
	return "VILA DE ERYNDOR\nFale com Mara junto à ponte"
func show_message(title: String, body: String):
	if not is_instance_valid(hud): return
	hud.message_title.text = title
	hud.message_body.text = body
	message_time = 7
func damage_number(point: Vector2, amount: int, tint: Color):
	var label = Label.new()
	label.text = str(amount)
	label.position = point+Vector2(-10,-65)
	label.modulate = tint
	label.add_theme_font_size_override("font_size",22)
	label.z_index = 20
	add_child(label)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label,"position:y",label.position.y-38,0.65)
	tween.tween_property(label,"modulate:a",0.0,0.65)
	tween.chain().tween_callback(label.queue_free)
func slash(point: Vector2, facing: Vector2):
	var arc = Line2D.new()
	arc.width = 3
	arc.default_color = Color(1,0.91,0.63,0.9)
	arc.position = point
	arc.z_index = 8
	for i in 12:
		var angle = facing.angle()-0.9+float(i)/11*1.8
		arc.add_point(Vector2.from_angle(angle)*55+Vector2(0,-20))
	add_child(arc)
	var tween = create_tween()
	tween.tween_property(arc,"modulate:a",0.0,0.17)
	tween.tween_callback(arc.queue_free)
