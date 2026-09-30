extends Node
# Separate storage leaves the original single-character save untouched as a backup.
const RPG = preload("res://scripts/rpg_state.gd")
const RACES = preload("res://scripts/races.gd").ALL
const CLASSES = preload("res://scripts/classes.gd").ALL
const MAX_CHARACTERS = 8
const KEY = "aervalon.characters.v1"
var save_path := "user://aervalon_characters_v1.json"
var legacy_save_path := "user://eryndor_rpg_v1.json"
var profiles := {}
var active_id := ""
var loaded := false
var blocked := false
var in_game := false
var save_enabled := true
func snapshot() -> Dictionary:
	return {"version":1,"active":active_id,"profiles":profiles.duplicate(true)}
func restore(data) -> bool:
	if not data is Dictionary or data.get("version",0)!=1 or not data.get("profiles") is Dictionary: return false
	if data.profiles.size()>MAX_CHARACTERS: return false
	var validated := {}
	for id in data.profiles:
		var p = data.profiles[id]
		if not id is String or not p is Dictionary: return false
		var class_id = str(p.get("class","guardian"))
		if not RACES.has(p.get("race","")) or not CLASSES.has(class_id): return false
		var r = RPG.new()
		if not r.restore(p.get("data")): return false
		validated[id] = {"name":str(p.get("name","Viajante")).left(20),"race":p.race,"class":class_id,"legacy":bool(p.get("legacy",false)),"data":r.snapshot()}
	profiles = validated
	active_id = str(data.get("active",""))
	if not profiles.has(active_id): active_id = str(profiles.keys()[0]) if not profiles.is_empty() else ""
	return true
func ensure_loaded():
	if loaded: return
	loaded = true
	var raw = ""
	if OS.has_feature("web"):
		var result = JavaScriptBridge.eval("(()=>{try{return localStorage.getItem('"+KEY+"')||''}catch(e){return null}})()",true)
		if result==null:
			blocked=true
			return
		raw = str(result)
	elif FileAccess.file_exists(save_path): raw = FileAccess.get_file_as_string(save_path)
	if raw!="":
		blocked = not restore(JSON.parse_string(raw))
		return
	var legacy = RPG.new()
	legacy.save_path = legacy_save_path
	if legacy.load_game():
		profiles["legacy"] = {"name":"Viajante de Eryndor","race":"valen","class":"guardian","legacy":true,"data":legacy.snapshot()}
		active_id = "legacy"
		blocked = not flush()
func flush() -> bool:
	if blocked: return false
	if not save_enabled: return true
	var text = JSON.stringify(snapshot())
	if OS.has_feature("web"):
		return bool(JavaScriptBridge.eval("(()=>{try{localStorage.setItem('"+KEY+"',"+JSON.stringify(text)+");return true}catch(e){return false}})()",true))
	var file = FileAccess.open(save_path+".tmp",FileAccess.WRITE)
	if file==null: return false
	file.store_string(text)
	file.close()
	return DirAccess.rename_absolute(save_path+".tmp",save_path)==OK
func create_character(character_name: String, race_id := "valen", class_id := "guardian") -> String:
	var clean = character_name.strip_edges()
	if blocked or profiles.size()>=MAX_CHARACTERS or clean.length()<2 or clean.length()>20 or not RACES.has(race_id) or not CLASSES.has(class_id): return ""
	for c in clean:
		if c.unicode_at(0)<32: return ""
	for p in profiles.values():
		if str(p.name).nocasecmp_to(clean)==0: return ""
	var id = "c_%d_%d" % [Time.get_ticks_usec(),randi()]
	var r = RPG.new()
	r.configure_new_character(class_id)
	profiles[id] = {"name":clean,"race":race_id,"class":class_id,"legacy":false,"data":r.snapshot()}
	if not flush():
		profiles.erase(id)
		return ""
	return id
func select_character(id: String) -> bool:
	if blocked or not profiles.has(id): return false
	var previous = active_id
	active_id = id
	if not flush():
		active_id = previous
		return false
	return true
func save_profile(id: String, data: Dictionary) -> bool:
	if blocked or not profiles.has(id): return false
	var previous = profiles[id].data
	profiles[id].data = data.duplicate(true)
	if not flush():
		profiles[id].data = previous
		return false
	return true

func delete_character(id: String, expected_name: String) -> bool:
	if blocked or in_game or not profiles.has(id) or profiles[id].name!=expected_name: return false
	var previous=profiles.duplicate(true)
	var previous_active=active_id
	profiles.erase(id)
	if active_id==id: active_id=str(profiles.keys()[0]) if not profiles.is_empty() else ""
	if not flush():
		profiles=previous
		active_id=previous_active
		return false
	return true
