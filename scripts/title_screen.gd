extends Control
var menu
var qa_enabled := false
var qa_clock := 0.0
func _ready():
	Roster.in_game=false
	Roster.ensure_loaded()
	var backdrop=TextureRect.new()
	backdrop.texture=preload("res://assets/aervalon/races_v4/title.png")
	backdrop.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	menu=PanelContainer.new()
	menu.set_script(preload("res://scripts/character_menu.gd"))
	add_child(menu)
	menu.minimum_size_changed.connect(func(): layout.call_deferred())
	get_viewport().size_changed.connect(layout)
	layout.call_deferred()
	if OS.has_feature("web"):
		qa_enabled="qa=1" in str(JavaScriptBridge.eval("window.location.search",true))
func layout():
	if not is_instance_valid(menu): return
	var available=get_viewport_rect().size-Vector2(48,40)
	var dimensions=Vector2(1160,570).max(menu.get_combined_minimum_size())
	var factor=minf(1.35,minf(available.x/dimensions.x,available.y/dimensions.y))
	menu.scale=Vector2.ONE*factor
	menu.size=dimensions
	menu.position=(get_viewport_rect().size-dimensions*factor)*0.5
func _process(delta):
	if not qa_enabled: return
	qa_clock+=delta
	if qa_clock<0.1: return
	qa_clock=0
	var r=preload("res://scripts/rpg_state.gd").new()
	var profile=Roster.profiles.get(Roster.active_id,{})
	if not profile.is_empty(): r.restore(profile.data)
	var profiles={}
	for id in Roster.profiles: profiles[id]={"name":Roster.profiles[id].name,"race":Roster.profiles[id].race,"class":Roster.profiles[id].get("class","guardian")}
	var viewport=get_viewport_rect().size
	var state={"scene":"title","world_loaded":false,"menu":true,"modal":true,"viewport":[viewport.x,viewport.y],"buttons":menu.qa_buttons(),"profiles":profiles,"selected_race":menu.race_id,"selected_class":menu.class_id,"profile":Roster.active_id,"character_name":profile.get("name",""),"coins":r.coins,"equipment":r.equipment,"inventory":r.inventory,"level":r.level,"xp":r.xp,"quest_started":r.quest!="available","complete":r.quest=="complete","herbalism":r.herbalism,"discoveries":r.discoveries}
	JavaScriptBridge.eval("document.querySelector('canvas').dataset.aervalon="+JSON.stringify(JSON.stringify(state)),true)
