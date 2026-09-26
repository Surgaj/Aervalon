extends RefCounted
const CLASSES = preload("res://scripts/classes.gd").ALL
# IDs are stable save keys. Definitions can grow without changing the save schema.
const ITEMS = {
	"river_herb": {"name":"Erva de Orvalho", "type":"Consumíveis", "heal":15, "price":0, "value":2, "icon":"herb", "description":"Colhida no vale. Recupera 15 de vida."},
	"rusty_sword": {"name":"Espada Enferrujada", "type":"Equipamentos", "slot":"weapon", "family":"blade", "attack":5, "price":8, "value":3, "icon":"sword", "description":"Uma lâmina gasta. Ataque +5."},
	"iron_sword": {"name":"Espada de Ferro", "type":"Equipamentos", "slot":"weapon", "family":"blade", "attack":18, "price":38, "value":15, "icon":"sword", "description":"Forjada por Borin. Ataque +18."},
	"shadow_daggers": {"name":"Lâminas Gêmeas", "type":"Equipamentos", "slot":"weapon", "family":"dagger", "attack":4, "price":0, "value":1, "icon":"sword", "description":"Duas lâminas leves de iniciado. Feitas para golpes rápidos."},
	"tracker_bow": {"name":"Arco de Rastreador", "type":"Equipamentos", "slot":"weapon", "family":"bow", "attack":4, "price":0, "value":1, "icon":"sword", "description":"Arco simples de viagem, próprio para manter distância."},
	"arcanist_staff": {"name":"Báculo de Cinza", "type":"Equipamentos", "slot":"weapon", "family":"staff", "attack":5, "price":0, "value":1, "icon":"sword", "description":"Canaliza a primeira disciplina de um Arcanista."},
	"luminar_mace": {"name":"Maça do Alvorecer", "type":"Equipamentos", "slot":"weapon", "family":"mace", "attack":5, "price":0, "value":1, "icon":"sword", "description":"Arma de peregrino usada pelos Luminares."},
	"bound_spear": {"name":"Lança Vinculada", "type":"Equipamentos", "slot":"weapon", "family":"spear", "attack":5, "price":0, "value":1, "icon":"sword", "description":"Lança ritual marcada para um vínculo espiritual."},
	"veil_scythe": {"name":"Foice Velária", "type":"Equipamentos", "slot":"weapon", "family":"scythe", "attack":5, "price":0, "value":1, "icon":"sword", "description":"Foice curta usada para conduzir ecos vitais."},
	"artificer_pistol": {"name":"Pistola de Oficina", "type":"Equipamentos", "slot":"weapon", "family":"firearm", "attack":5, "price":0, "value":1, "icon":"sword", "description":"Mecanismo robusto de um Artífice iniciante."},
	"storm_spear": {"name":"Lança da Tempestade", "type":"Equipamentos", "slot":"weapon", "family":"spear", "attack":5, "price":0, "value":1, "icon":"sword", "description":"Haste condutora usada pelos Tempestários."},
	"echo_blade": {"name":"Lâmina de Eco", "type":"Equipamentos", "slot":"weapon", "family":"blade", "attack":5, "price":0, "value":1, "icon":"sword", "description":"Lâmina equilibrada para técnicas de ruptura e memória."},
	"iron_armor": {"name":"Armadura de Ferro", "type":"Equipamentos", "slot":"armor", "defense":5, "price":55, "value":22, "icon":"armor", "description":"Placas e capa de viagem. Defesa +5."},
	"leather_armor": {"name":"Armadura Simples", "type":"Equipamentos", "slot":"armor", "defense":3, "price":24, "value":9, "icon":"armor", "description":"Couro reforçado. Defesa +3."},
	"potion": {"name":"Poção de Vida", "type":"Consumíveis", "heal":45, "price":8, "value":3, "icon":"potion", "description":"Recupera 45 pontos de vida."},
	"bread": {"name":"Pão da Vila", "type":"Consumíveis", "heal":20, "price":4, "value":1, "icon":"bread", "description":"Recupera 20 pontos de vida."},
	"wolf_pelt": {"name":"Pele de Lobo", "type":"Materiais", "price":0, "value":5, "icon":"pelt", "description":"Pele aproveitável. Os comerciantes a compram."},
	"wolf_fang": {"name":"Presa de Lobo", "type":"Materiais", "price":0, "value":3, "icon":"fang", "description":"Uma presa afiada encontrada na floresta."},
	"mara_token": {"name":"Selo de Eryndor", "type":"Itens de missão", "price":0, "value":0, "icon":"seal", "description":"Mara agradece por tornar a estrada segura."}
}
const SHOPS = {"borin":["iron_sword","leather_armor","iron_armor"], "merchant":["potion","bread"]}
var level := 1
var xp := 0
var coins := 12
var inventory := {"rusty_sword":1, "potion":2}
var equipment := {"weapon":"rusty_sword", "armor":""}
var quest := "available"
var kills := 0
var chest_open := false
var herbalism := 0
var harvested := {}
var discoveries := {}
var profile_id := ""
var race := "valen" # Identity belongs to the roster, not the gameplay snapshot.
var class_id := "guardian" # Class identity also belongs to the roster.
var save_enabled := true
var save_path := "user://eryndor_rpg_v1.json"
func xp_needed() -> int: return 60 + (level-1)*35
func class_data() -> Dictionary: return CLASSES.get(class_id,CLASSES.guardian)
func attack() -> int: return 20+(level-1)*2+int(ITEMS.get(equipment.weapon,{}).get("attack",0))+int(class_data().attack_bonus)
func defense() -> int: return int(ITEMS.get(equipment.armor,{}).get("defense",0))+int(class_data().defense_bonus)
func max_health() -> int: return maxi(60,100+(level-1)*8+int(class_data().health_bonus))
func move_speed() -> float: return float(class_data().speed)
func attack_cooldown_value() -> float: return float(class_data().attack_cooldown)
func attack_range() -> float: return float(class_data().attack_range)
func class_power_cooldown() -> float: return float(class_data().power_cooldown)
func configure_new_character(id: String):
	class_id = id if CLASSES.has(id) else "guardian"
	var starter = str(class_data().starter)
	inventory = {"potion":2}
	if ITEMS.has(starter): inventory[starter]=1
	equipment = {"weapon":starter if ITEMS.has(starter) else "", "armor":""}
func can_equip(id: String) -> bool:
	if not ITEMS.has(id) or not ITEMS[id].has("slot"): return false
	if ITEMS[id].slot!="weapon": return true
	return str(ITEMS[id].get("family","")) in class_data().families
func add_item(id: String, count := 1):
	if ITEMS.has(id) and count>0: inventory[id] = int(inventory.get(id,0))+count
func add_xp(amount: int) -> bool:
	xp += maxi(0,amount)
	var leveled := false
	while xp>=xp_needed():
		xp -= xp_needed()
		level += 1
		leveled = true
	return leveled
func buy(id: String, shop: String) -> String:
	if not id in SHOPS.get(shop,[]): return "Item indisponível"
	if ITEMS[id].get("slot","")=="weapon" and not can_equip(id): return "Sua classe não usa este tipo de arma"
	var cost = ITEMS[id].price
	if coins<cost: return "Moedas insuficientes"
	coins -= cost
	add_item(id)
	return "Item comprado"
func sell(id: String) -> String:
	if not ITEMS.has(id) or int(inventory.get(id,0))<=0: return "Item indisponível"
	if ITEMS[id].type=="Itens de missão": return "Guarde este item de missão"
	if id in equipment.values() and int(inventory[id])<=1: return "Equipe outro item antes de vender"
	coins += int(ITEMS[id].value)
	remove_item(id)
	return "Item vendido"
func remove_item(id: String):
	inventory[id] = int(inventory.get(id,0))-1
	if inventory[id]<=0: inventory.erase(id)
func equip(id: String) -> bool:
	if not ITEMS.has(id) or int(inventory.get(id,0))<=0 or not ITEMS[id].has("slot") or not can_equip(id): return false
	equipment[ITEMS[id].slot] = id
	return true
func snapshot() -> Dictionary:
	return {"version":1,"level":level,"xp":xp,"coins":coins,"inventory":inventory.duplicate(),"equipment":equipment.duplicate(),"quest":quest,"kills":kills,"chest_open":chest_open,"herbalism":herbalism,"harvested":harvested.duplicate(),"discoveries":discoveries.duplicate()}
func restore(data) -> bool:
	if not data is Dictionary or data.get("version",0)!=1: return false
	if not data.get("inventory") is Dictionary or not data.get("equipment") is Dictionary: return false
	for field in ["level","xp","coins","kills"]:
		if data.has(field) and not (data[field] is int or data[field] is float): return false
	level = clampi(int(data.get("level",1)),1,100)
	xp = clampi(int(data.get("xp",0)),0,xp_needed()-1)
	coins = clampi(int(data.get("coins",12)),0,999999)
	inventory.clear()
	for id in data.inventory:
		if ITEMS.has(id) and (data.inventory[id] is float or data.inventory[id] is int):
			var count = clampi(int(data.inventory[id]),0,9999)
			if count>0: inventory[id] = count
	for slot in ["weapon","armor"]:
		var id = str(data.equipment.get(slot,""))
		equipment[slot] = id if inventory.has(id) and ITEMS[id].get("slot","")==slot else ""
	quest = str(data.get("quest","available"))
	if not quest in ["available","active","return","complete"]: quest = "available"
	kills = clampi(int(data.get("kills",0)),0,3)
	if quest=="available": kills=0
	if quest in ["return","complete"]: kills=3
	if quest=="active" and kills==3: quest="return"
	chest_open = bool(data.get("chest_open",false))
	herbalism = 0
	if data.get("herbalism",0) is int or data.get("herbalism",0) is float:
		herbalism = clampi(int(data.get("herbalism",0)),0,9999)
	harvested.clear()
	if data.get("harvested",{}) is Dictionary:
		var now = Time.get_unix_time_from_system()
		for id in ["herb_village","herb_bank","herb_forest"]:
			var stamp = data.get("harvested",{}).get(id,0)
			if (stamp is float or stamp is int) and is_finite(float(stamp)) and float(stamp)>now:
				harvested[id] = minf(float(stamp),now+120.0)
	discoveries.clear()
	if data.get("discoveries",{}) is Dictionary and data.get("discoveries",{}).get("well_echo",false)==true:
		discoveries["well_echo"] = true
	return true
func save_game() -> bool:
	if not save_enabled: return true
	if profile_id!="":
		return Engine.get_main_loop().root.get_node("Roster").save_profile(profile_id,snapshot())
	var text = JSON.stringify(snapshot())
	# Origin-scoped key stays stable across immutable Web build URLs.
	if OS.has_feature("web"):
		return bool(JavaScriptBridge.eval("(()=>{try{localStorage.setItem('aervalon.eryndor.v1',"+JSON.stringify(text)+");return true}catch(e){return false}})()",true))
	var file = FileAccess.open(save_path+".tmp",FileAccess.WRITE)
	if file==null: return false
	file.store_string(text)
	file.close()
	return DirAccess.rename_absolute(save_path+".tmp",save_path)==OK
func load_game() -> bool:
	if not save_enabled: return false
	if OS.has_feature("web"):
		var text = JavaScriptBridge.eval("(()=>{try{return localStorage.getItem('aervalon.eryndor.v1')||''}catch(e){return ''}})()",true)
		return restore(JSON.parse_string(str(text))) if text else false
	if FileAccess.file_exists(save_path): return restore(JSON.parse_string(FileAccess.get_file_as_string(save_path)))
	return false
