extends Node2D
var player
var quest_started := false
var quest_kills := 0
var quest_target := 3
var message_time := 0.0
var water_phase := 0.0
func _ready():
	player=get_tree().get_first_node_in_group("player")
	for e in get_tree().get_nodes_in_group("enemy"):
		if e.has_signal("died"): e.died.connect(_enemy_died)
	$UI/Quest.text="ERYNDOR • Chegue à Floresta Sussurrante"
	$UI/Health.text="❤ 100 / 100"
func _process(delta):
	water_phase += delta
	$River.modulate = Color(0.72+sin(water_phase)*0.04,0.88,1.0,1)
	if player:
		$UI/Health.text="❤ %d / %d" % [player.health,player.max_health]
		if not quest_started and player.global_position.x>860:
			quest_started=true
			$UI/Quest.text="AMEAÇA NA MATA • Lobos 0 / 3"
			show_message("Nova missão","Afaste os lobos da estrada de Eryndor.")
		_check_interaction()
	if message_time>0:
		message_time-=delta
		if message_time<=0: $UI/Message.visible=false
func _check_interaction():
	for n in get_tree().get_nodes_in_group("npc"):
		if player.global_position.distance_to(n.global_position)<55:
			if n.has_method("interact") and Input.is_action_just_pressed("interact"): n.interact()
func interact_nearby():
	if not player:return
	var nearest=null
	var dist=999.0
	for n in get_tree().get_nodes_in_group("npc"):
		var d=player.global_position.distance_to(n.global_position)
		if d<dist: dist=d;nearest=n
	if nearest and dist<85 and nearest.has_method("interact"): nearest.interact()
	else: show_message("Eryndor","Nada para interagir aqui.")
func _enemy_died():
	quest_kills+=1
	if quest_started:
		$UI/Quest.text="AMEAÇA NA MATA • Lobos %d / %d" % [min(quest_kills,quest_target),quest_target]
	if quest_kills>=quest_target:
		$UI/Quest.text="✓ ESTRADA SEGURA • Volte à vila"
		show_message("Missão concluída","A estrada para a Floresta Sussurrante está segura.")
func show_message(title:String,body:String):
	$UI/Message/Title.text=title
	$UI/Message/Body.text=body
	$UI/Message.visible=true
	message_time=3.5
