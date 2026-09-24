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
var coins := 0
var message_time := 0.0
var qa_enabled := false
var qa_clock := 0.0
var nearest_npc
func _ready():
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var key = InputEventKey.new()
		key.physical_keycode = KEY_E
		InputMap.action_add_event("interact",key)
	player = PLAYER.instantiate()
	player.position = Vector2(610,590)
	$YSortWorld.add_child(player)
	spawn_npc("Mara","mara",Vector2(650,540),25)
	spawn_npc("Borin, o ferreiro","borin",Vector2(675,448),0)
	spawn_npc("Eldric","eldric",Vector2(585,795),20)
	spawn_npc("Guarda de Eryndor","guard",Vector2(827,560),35)
	spawn_npc("Galinha","hen",Vector2(440,530),40)
	for point in [Vector2(1250,570),Vector2(1450,655),Vector2(1640,530)]:
		var wolf = WOLF.instantiate()
		wolf.position = point
		$YSortWorld.add_child(wolf)
		wolf.died.connect(_enemy_died)
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
		qa_enabled = JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa')") == true
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
		var distance = player.global_position.distance_to(npc.global_position)
		if distance<best:
			best = distance
			nearest_npc = npc
	if player.position.x>1100 and not quest_started:
		quest_started = true
		show_message("Ameaça na Mata","Os lobos bloquearam a estrada. Derrote três e volte a Mara.")
	if is_instance_valid(hud): hud.refresh()
	if qa_enabled:
		qa_clock += delta
		if qa_clock>0.1:
			qa_clock = 0
			var state = {"position":[player.position.x,player.position.y],"health":player.health,"quest_started":quest_started,"kills":quest_kills,"complete":quest_complete,"viewport":[hud.root.size.x,hud.root.size.y],"joystick":[hud.joy_center.x,hud.joy_center.y],"attack":[hud.attack_button.position.x+54,hud.attack_button.position.y+54],"portrait":hud.portrait_warning.visible}
			JavaScriptBridge.eval("document.querySelector('canvas').dataset.aervalon="+JSON.stringify(JSON.stringify(state)))
func interact_nearby():
	if player.death_time>0: return
	if nearest_npc:
		nearest_npc.interact()
	elif player.global_position.distance_to(Vector2(1620,940))<95:
		if not chest_open:
			chest_open = true
			coins += 10
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
				player.health = player.max_health
				show_message("Estrada Segura • concluída","Mara: Agora podemos levar as mercadorias! +25 moedas • Vida restaurada.")
			elif not quest_started:
				quest_started = true
				show_message("Mara • Ameaça na Mata","Os lobos se aproximaram da ponte. Derrote 3 na estrada e volte a falar comigo.")
			else: show_message("Mara","Atravessando a ponte você encontrará os lobos. Cuidado: recue quando prepararem o bote.")
		"borin": show_message("Borin, o ferreiro","Quando a Pedra Cinzenta voltar a enviar minério, poderemos melhorar seu equipamento. Por ora, cuide desta lâmina.")
		"eldric": show_message("Eldric","Eryndor é só o começo. Além da floresta, as ruínas de Thal’Kor ainda guardam suas histórias.")
		_: show_message(npc.npc_name,"Mara precisa de ajuda. A estrada do outro lado da ponte já não é segura.")
func _enemy_died():
	quest_started = true
	quest_kills = mini(quest_kills+1,quest_target)
	if quest_kills>=quest_target: show_message("Estrada Segura","Os três lobos foram derrotados. Volte à vila e fale com Mara.")
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
