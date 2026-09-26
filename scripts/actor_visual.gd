extends AnimatedSprite2D
# Art adapter: gameplay only sets state and direction, never frame numbers.
const ROOT = "res://assets/aervalon/v2/"
var hero_sheet := "res://assets/aervalon/characters_v3/valen_linen.png"
var kind := "hero"
var state := "idle"
var direction := Vector2.DOWN
func setup(actor_kind: String):
	kind = actor_kind
	sprite_frames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	if kind == "hero":
		var sheet = load(hero_sheet)
		var cell = Vector2(sheet.get_width()/8.0,sheet.get_height()/4.0)
		for row in 4:
			for action in ["idle", "walk", "attack", "hit", "death"]:
				var frames: Array = {"idle":[0],"walk":[1,2,3,2],"attack":[4,5],"hit":[6],"death":[7]}[action]
				_add(action + str(row), sheet, frames, cell, row, 9.0)
		scale = Vector2.ONE * (87.04/cell.x)
		position.y = -35
	elif kind == "wolf":
		for row in 2:
			var sheet = load(ROOT + ("wolf_down.png" if row == 0 else "wolf_up.png"))
			for action in ["idle", "walk", "attack", "hit", "death"]:
				var frames: Array = {"idle":[0],"walk":[1,2,3,2],"attack":[0,4],"hit":[4],"death":[5]}[action]
				_add(action + str(row),sheet,frames,Vector2(256,256),0,8.0)
		scale = Vector2.ONE * 0.30
		position.y = -23
	else:
		var sheet = load(ROOT + kind + ".png")
		var count = {"mara":2,"borin":3,"eldric":1,"guard":2,"hen":2}.get(kind,1)
		var size = Vector2(sheet.get_width()/count,sheet.get_height())
		_add("idle0",sheet,[0],size,0,3)
		_add("walk0",sheet,[0,1] if count > 1 else [0],size,0,5)
		_add("work0",sheet,[0,1,2,1],size,0,4) if kind == "borin" else null
		scale = Vector2.ONE * (0.15 if kind == "hen" else 0.29)
		position.y = -16 if kind == "hen" else -34
	set_state("idle",Vector2.DOWN)
func _add(anim: String, sheet: Texture2D, indices: Array, cell: Vector2, row: int, fps: float):
	sprite_frames.add_animation(anim)
	sprite_frames.set_animation_speed(anim,fps)
	sprite_frames.set_animation_loop(anim,not anim.begins_with("death"))
	for i in indices:
		var frame_texture = AtlasTexture.new()
		frame_texture.atlas = sheet
		frame_texture.region = Rect2(Vector2(i*cell.x,row*cell.y),cell)
		sprite_frames.add_frame(anim,frame_texture)
func set_state(value: String, facing: Vector2):
	state = value
	direction = facing
	var row = 0
	if kind == "hero":
		row = (1 if facing.x < 0 else 2) if absf(facing.x)>absf(facing.y) else (3 if facing.y<0 else 0)
		flip_h = false
		if value == "attack" and absf(facing.x)>absf(facing.y):
			row = 0
			flip_h = facing.x<0
	elif kind == "wolf":
		row = 1 if facing.y < -0.4 else 0
		flip_h = facing.x < 0 if row == 0 else facing.x > 0
	elif kind != "borin":
		flip_h = facing.x < 0
	var anim = value + str(row)
	if sprite_frames.has_animation(anim): play(anim)
func flash():
	modulate = Color(1.8,0.55,0.45)
	create_tween().tween_property(self,"modulate",Color.WHITE,0.2)

static func sheet_for(rpg) -> String:
	match rpg.equipment.armor:
		"iron_armor": return "res://assets/aervalon/v2/hero.png"
		"leather_armor": return "res://assets/aervalon/characters_v3/valen_leather.png"
	return "res://assets/aervalon/characters_v3/valen_linen.png"
static func portrait_for(rpg) -> AtlasTexture:
	var texture=load(sheet_for(rpg))
	var atlas=AtlasTexture.new()
	atlas.atlas=texture
	atlas.region=Rect2(0,0,texture.get_width()/8.0,texture.get_height()/4.0)
	return atlas
func apply_equipment(rpg):
	var path=sheet_for(rpg)
	if hero_sheet==path and sprite_frames!=null: return
	hero_sheet=path
	setup("hero")
