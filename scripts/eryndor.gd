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
var nearest_object
func _ready():
	rpg.save_enabled = not "--test" in OS.get_cmdline_user_args()
	if rpg.save_enabled:
		Roster.ensure_loaded()
		if not Roster.profiles.has(Roster.active_id):
			get_tree().change_scene_to_file.call_deferred("res://scenes/ui/title_screen.tscn")
			return
		if Roster.profiles.has(Roster.active_id):
			rpg.restore(Roster.profiles[Roster.active_id].data)
			rpg.profile_id = Roster.active_id
			rpg.race = Roster.profiles[Roster.active_id].race
			rpg.class_id = Roster.profiles[Roster.active_id].get("class","guardian")
	quest_started = rpg.quest != "available"
	quest_complete = rpg.quest == "complete"
	quest_kills = rpg.kills
	chest_open = rpg.chest_open
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var key = InputEventKey.new()
		key.physical_keycode = KEY_E
		InputMap.action_add_event("interact",key)
	if not InputMap.has_action("dodge"):
		InputMap.add_action("dodge")
		var key = InputEventKey.new()
		key.physical_keycode = KEY_SHIFT
		InputMap.action_add_event("dodge",key)
	if not InputMap.has_action("power"):
		InputMap.add_action("power")
		var power_key = InputEventKey.new()
		power_key.physical_keycode = KEY_Q
		InputMap.action_add_event("power",power_key)
	player = PLAYER.instantiate()
	player.position = Vector2(610,590)
	player.speed = rpg.move_speed()
	$YSortWorld.add_child(player)
	player.max_health = rpg.max_health()
	player.health = player.max_health
	player.visual.apply_equipment(rpg)
	spawn_npc("Mara","mara",Vector2(650,540),25)
	spawn_npc("Borin, o ferreiro","borin",Vector2(670,339),0)
	spawn_npc("Nilo, mercador","merchant",Vector2(490,665),0)
	spawn_npc("Eldric","eldric",Vector2(585,795),20)
	spawn_npc("Guarda de Eryndor","guard",Vector2(827,560),35)
	spawn_npc("Galinha","hen",Vector2(440,530),40)
	var lia = spawn_npc("Lia, a padeira","lia",Vector2(540,720),0)
	lia.route.assign([Vector2(560,720),Vector2(560,615),Vector2(520,590),Vector2(520,720)])
	lia.role = "O pão já saiu do forno. Quando a estrada estiver segura, levarei uma cesta às fazendas de Elden."
	var tomas = spawn_npc("Tomás, carregador","tomas",Vector2(240,530),0)
	tomas.route.assign([Vector2(240,760),Vector2(270,815),Vector2(270,530)])
	tomas.role = "Nilo está esperando estes sacos. Um dia ainda compro uma carroça para as entregas."
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
	if chest_open: chest.modulate = Color(0.5,0.5,0.5)
	for entry in [["herb_village",Vector2(745,700)],["herb_bank",Vector2(1150,735)],["herb_forest",Vector2(1530,790)],["well_echo",Vector2(695,829)]]:
		var resource = Node2D.new()
		resource.set_script(preload("res://scripts/world_interaction.gd"))
		resource.resource_id = entry[0]
		resource.position = entry[1]
		$YSortWorld.add_child(resource)
	hud = CanvasLayer.new()
	hud.set_script(load("res://scripts/mobile_controls.gd"))
	add_child(hud)
	if OS.has_feature("web"):
		qa_enabled = "qa=1" in str(JavaScriptBridge.eval("window.location.search", true))
		print("Aervalon Web QA enabled: ", qa_enabled)
	show_message("Vale de Eryndor","Fale com Mara junto à ponte. WASD / setas para andar • E para falar • Espaço: atacar • Shift: esquivar.")
func spawn_npc(title: String, appearance: String, point: Vector2, radius: float):
	var npc = NPC.instantiate()
	npc.npc_name = title
	npc.appearance = appearance
	npc.position = point
	npc.wander_radius = radius
	$YSortWorld.add_child(npc)
	return npc
func _process(delta):
	if not is_instance_valid(player): return
	message_time = maxf(0,message_time-delta)
	nearest_npc = null
	var best := 100.0
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.appearance == "hen": continue
		var interact_point = npc.global_position+Vector2(0,80) if npc.appearance=="borin" else npc.global_position
		var distance = player.global_position.distance_to(interact_point)
		if npc.appearance in ["lia","tomas"] and distance>42: continue
		if distance<best:
			best = distance
			nearest_npc = npc
	nearest_object = null
	for object in get_tree().get_nodes_in_group("world_interaction"):
		var distance = player.global_position.distance_to(object.global_position)
		if distance<minf(best,80) and object.can_reach(player):
			best = distance
			nearest_object = object
			nearest_npc = null
	if is_instance_valid(hud): hud.refresh()
	if qa_enabled:
		qa_clock += delta
		if qa_clock>0.1:
			qa_clock = 0
			var state = {"dodge_cooldown":player.dodge_cooldown,"dodge":[hud.dodge_button.position.x+43,hud.dodge_button.position.y+43],"herbalism":rpg.herbalism,"discoveries":rpg.discoveries,"interaction":nearest_object.resource_id if nearest_object else "","position":[player.position.x,player.position.y],"health":player.health,"quest_started":quest_started,"kills":quest_kills,"complete":quest_complete,"viewport":[hud.root.size.x,hud.root.size.y],"joystick":[hud.joy_center.x,hud.joy_center.y],"attack":[hud.attack_button.position.x+54,hud.attack_button.position.y+54],"portrait":hud.portrait_warning.visible,"modal":modal_open,"level":rpg.level,"xp":rpg.xp,"coins":coins,"equipment":rpg.equipment,"inventory":rpg.inventory,"shop":shop,"profile":rpg.profile_id,"scene":"eryndor","world_loaded":true,"race":rpg.race,"class":rpg.class_id,"visual_race":player.visual.hero_race,"power_cooldown":player.power_cooldown,"menu":false,"character_name":Roster.profiles.get(rpg.profile_id,{}).get("name",""),"buttons":hud.inventory_panel.qa_buttons()}
			JavaScriptBridge.eval("document.querySelector('canvas').dataset.aervalon="+JSON.stringify(JSON.stringify(state)), true)
func interact_nearby():
	if player.death_time>0 or modal_open: return
	if nearest_object:
		nearest_object.interact()
	elif nearest_npc:
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
		"eldric": show_message("Eldric","Você também ouviu? Eu conheço este poço desde menino. Nunca houve outro som além da água. Não sabemos o que existe lá embaixo." if rpg.discoveries.has("well_echo") else "Desde o tremor, às vezes o poço responde antes de a água cair. Escute com calma, se passar por lá.")
		"lia","tomas": show_message(npc.npc_name,npc.role)
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
func persist() -> bool:
	rpg.quest = "complete" if quest_complete else ("return" if quest_kills>=3 else ("active" if quest_started else "available"))
	rpg.kills = quest_kills
	rpg.chest_open = chest_open
	var saved = rpg.save_game()
	if not saved: show_message("Não foi possível salvar", "O navegador bloqueou o armazenamento. Mantenha esta aba aberta para preservar esta sessão.")
	return saved
func use_class_power() -> bool:
	if player.death_time>0 or modal_open: return false
	var data=rpg.class_data()
	match rpg.class_id:
		"guardian":
			player.guard_time=2.5
			power_ring(player.global_position,82,Color("e6c56d"))
			show_message(data.power,"Por alguns segundos, o próximo dano recebido é fortemente reduzido.")
		"shadow":
			power_ring(player.global_position+player.facing*48,92,Color("b597d6"))
			hit_forward(112,0.15,0.62,99)
			hit_forward(112,0.15,0.62,99)
			show_message(data.power,"Duas passagens rápidas cortam inimigos à frente.")
		"tracker":
			var target=nearest_forward_enemy(245,0.62)
			var end=player.global_position+player.facing*230
			if target:
				end=target.global_position
				if clear_shot(target): target.take_damage(roundi(rpg.attack()*1.65),player.facing)
			power_line(player.global_position,end,Color("d9c58a"))
			show_message(data.power,"Um disparo preciso atravessa a distância até o alvo.")
		"arcanist":
			var center=player.global_position+player.facing*120
			power_ring(center,105,Color("8fb8ff"))
			hit_area(center,112,1.25)
			show_message(data.power,"Energia arcana explode à frente e atinge quem estiver no círculo.")
		"luminar":
			var healed=maxi(20,roundi(player.max_health*0.35))
			player.health=mini(player.max_health,player.health+healed)
			player.health_changed.emit()
			power_ring(player.global_position,94,Color("ffe3a3"))
			show_message(data.power,"A luz restaura %d pontos de vida." % healed)
		"bound":
			var target=nearest_forward_enemy(155,-0.25)
			var healed=18
			if target and clear_shot(target):
				var amount=roundi(rpg.attack()*1.15)
				target.take_damage(amount,player.global_position.direction_to(target.global_position))
				healed+=roundi(amount*0.25)
			player.health=mini(player.max_health,player.health+healed)
			player.health_changed.emit()
			power_ring(player.global_position,105,Color("9fd199"))
			show_message(data.power,"O vínculo fere o alvo próximo e devolve parte da força ao corpo.")
		"veil":
			var target=nearest_forward_enemy(175,-0.7)
			if target and clear_shot(target):
				var amount=roundi(rpg.attack()*1.05)
				target.take_damage(amount,player.global_position.direction_to(target.global_position))
				player.health=mini(player.max_health,player.health+roundi(amount*0.5))
				player.health_changed.emit()
				power_line(target.global_position,player.global_position,Color("bd84b8"))
			else: power_ring(player.global_position,76,Color("bd84b8"))
			show_message(data.power,"Um eco vital é puxado do inimigo mais próximo.")
		"artificer":
			var center=player.global_position+player.facing*145
			power_ring(center,100,Color("e7a56c"))
			hit_area(center,100,1.35)
			show_message(data.power,"Uma carga de oficina detona no ponto à frente.")
		"storm":
			power_ring(player.global_position,135,Color("91d7e5"))
			hit_area(player.global_position,135,1.0)
			show_message(data.power,"A descarga se espalha ao redor do Tempestário.")
		"echo":
			player.attack_cooldown=0
			player.dodge_cooldown=0
			player.hit_time=0
			power_ring(player.global_position,112,Color("a9b7ff"))
			show_message(data.power,"O instante se rompe: ataque e esquiva ficam disponíveis novamente.")
	return true
func clear_shot(enemy) -> bool:
	var query=PhysicsRayQueryParameters2D.create(player.global_position,enemy.global_position,1,[player.get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()
func nearest_forward_enemy(max_range: float, dot_min: float):
	var result=null
	var best=max_range
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.health<=0: continue
		var offset: Vector2=enemy.global_position-player.global_position
		var distance=offset.length()
		if distance<=best and (distance<24 or player.facing.dot(offset.normalized())>=dot_min):
			best=distance
			result=enemy
	return result
func hit_forward(max_range: float, dot_min: float, multiplier: float, max_targets: int):
	var hits=0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.health<=0: continue
		var offset: Vector2=enemy.global_position-player.global_position
		if offset.length()<=max_range and (offset.length()<24 or player.facing.dot(offset.normalized())>=dot_min) and clear_shot(enemy):
			enemy.take_damage(maxi(1,roundi(rpg.attack()*multiplier)),player.facing)
			hits+=1
			if hits>=max_targets: break
func hit_area(center: Vector2, radius: float, multiplier: float):
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.health>0 and enemy.global_position.distance_to(center)<=radius:
			enemy.take_damage(maxi(1,roundi(rpg.attack()*multiplier)),center.direction_to(enemy.global_position))
func power_ring(point: Vector2, radius: float, tint: Color):
	var ring=Line2D.new()
	ring.width=4
	ring.default_color=tint
	ring.position=point
	ring.z_index=9
	for i in 33:
		ring.add_point(Vector2.from_angle(float(i)/32.0*TAU)*radius)
	add_child(ring)
	ring.scale=Vector2.ONE*0.65
	var tween=create_tween().set_parallel(true)
	tween.tween_property(ring,"scale",Vector2.ONE*1.18,0.35)
	tween.tween_property(ring,"modulate:a",0.0,0.35)
	tween.chain().tween_callback(ring.queue_free)
func power_line(from: Vector2, to: Vector2, tint: Color):
	var line=Line2D.new()
	line.width=5
	line.default_color=tint
	line.z_index=9
	line.add_point(from)
	line.add_point(to)
	add_child(line)
	var tween=create_tween()
	tween.tween_property(line,"modulate:a",0.0,0.24)
	tween.tween_callback(line.queue_free)
func use_item(id: String) -> String:
	if not rpg.inventory.has(id): return "Item indisponível"
	var item = rpg.ITEMS[id]
	if item.has("slot"):
		if not rpg.equip(id): return "Sua classe não usa este tipo de arma"
		player.visual.apply_equipment(rpg)
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
