extends Node2D
# Authored placements, raster terrain/materials and foot pivots. No procedural map art.
const ROOT = "res://assets/aervalon/v2/"
var trees: Array[Sprite2D] = []
var phase := 0.0
var yworld: Node2D
var variation := RandomNumberGenerator.new()
var terrain: Node2D
func _ready():
	variation.seed = 417
	yworld = get_parent().get_node("YSortWorld")
	terrain = get_parent().get_node("Terrain")
	ground("grass",Rect2(0,0,1900,1100),false,Color(0.58,0.68,0.51))
	ground("cobble",Rect2(180,260,700,650),true,Color(0.94,0.92,0.84))
	ground("dirt",Rect2(1025,505,780,220),true,Color(0.87,0.83,0.72))
	var river = ground("water",Rect2(915,0,145,1100),false,Color(0.65,0.9,0.92))
	var water_shader = Shader.new()
	water_shader.code = "shader_type canvas_item; varying vec4 tint; varying vec2 local; void vertex(){tint=COLOR;local=VERTEX;} void fragment(){ vec2 uv=UV+vec2(sin(UV.y*26.0+TIME)*0.009,TIME*0.018); float edge=abs(local.x)+12.0*sin(local.y*0.013)+7.0*sin(local.y*0.039); vec4 c=texture(TEXTURE,uv)*tint; c.a*=1.0-smoothstep(249.0,290.0,edge); COLOR=c; }"
	var material = ShaderMaterial.new()
	material.shader = water_shader
	river.material = material
	# The diagonal deck crosses the river; banks follow both deck edges.
	wall_polygon([Vector2(915,0),Vector2(1060,0),Vector2(1060,579),Vector2(915,509)])
	wall_polygon([Vector2(915,589),Vector2(1060,659),Vector2(1060,1100),Vector2(915,1100)])
	prop("bridge",Vector2(990,684),330,Vector2.ZERO,false)
	prop("house",Vector2(360,405),310,Vector2(210,85))
	var forge = prop("forge",Vector2(700,420),310,Vector2(200,65))
	forge.get_parent().position.y -= 105
	for child in forge.get_parent().get_children(): child.position.y += 105
	prop("market",Vector2(360,720),220,Vector2(135,55))
	prop("well",Vector2(695,805),115,Vector2(65,36))
	prop("supplies",Vector2(490,416),76,Vector2(48,28))
	prop("supplies",Vector2(798,445),70,Vector2(45,28))
	prop("supplies",Vector2(441,721),70,Vector2(45,28))
	prop("flowers",Vector2(271,450),83,Vector2.ZERO)
	prop("flowers",Vector2(780,777),88,Vector2.ZERO)
	prop("flowers",Vector2(527,825),92,Vector2.ZERO)
	# Trees frame routes and offer deliberate front/back occlusion test points.
	for point in [Vector2(150,270),Vector2(155,600),Vector2(150,940),Vector2(380,980),Vector2(700,1010),Vector2(820,265),Vector2(1110,275),Vector2(1300,330),Vector2(1510,300),Vector2(1730,380),Vector2(1820,600),Vector2(1170,890),Vector2(1390,950),Vector2(1630,870),Vector2(590,205),Vector2(350,160),Vector2(1700,1040),Vector2(1850,950),Vector2(1490,145),Vector2(1220,130)]:
		var width = variation.randf_range(188,236)
		var tree = prop("tree",point+Vector2(variation.randf_range(-16,16),variation.randf_range(-10,10)),width,Vector2(27,24))
		tree.flip_h = variation.randf()>0.5
		tree.modulate = Color(variation.randf_range(0.90,1.0),variation.randf_range(0.92,1.0),variation.randf_range(0.88,1.0))
		trees.append(tree)
	for point in [Vector2(1130,720),Vector2(1350,450),Vector2(1625,760),Vector2(1790,500),Vector2(850,825),Vector2(858,380),Vector2(1090,430),Vector2(1080,785),Vector2(865,990),Vector2(1700,590)]:
		var flowers = prop("flowers",point,variation.randf_range(48,83),Vector2(26,14))
		flowers.flip_h = variation.randf()>0.5
	for y in [60,155,270,375,455,765,850,950,1070]:
		prop("flowers",Vector2(913-variation.randf_range(0,8),y),variation.randf_range(38,62),Vector2.ZERO)
		prop("flowers",Vector2(1063+variation.randf_range(0,8),y+30),variation.randf_range(38,62),Vector2.ZERO)
	wall(Rect2(-30,-30,1960,30))
	wall(Rect2(-30,1100,1960,30))
	wall(Rect2(-30,0,30,1100))
	wall(Rect2(1900,0,30,1100))
	particles(Vector2(736,321),Color(1,0.43,0.07,0.85),18,Vector2(0,-22),1.0,2.6)
	particles(Vector2(718,133),Color(0.65,0.70,0.68,0.28),12,Vector2(12,-22),3.0,7)
	particles(Vector2(414,116),Color(0.65,0.70,0.68,0.22),9,Vector2(12,-22),3.0,6)
	particles(Vector2(987,850),Color(0.75,0.95,1,0.6),22,Vector2(0,26),2.0,2)
	label_at("ERYNDOR",Vector2(535,285),18,Color(0.9,0.82,0.57))
	label_at("FLORESTA SUSSURRANTE",Vector2(1250,465),14,Color(0.8,0.85,0.66))
func ground(asset: String, rect: Rect2, feather: bool, tint: Color) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = load(ROOT+asset+".png")
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO,rect.size*4)
	sprite.scale = Vector2.ONE*0.25
	sprite.position = rect.get_center()
	sprite.modulate = tint
	terrain.add_child(sprite)
	if feather:
		var shader = Shader.new()
		shader.code = "shader_type canvas_item; varying vec2 local; varying vec4 tint; void vertex(){local=VERTEX;tint=COLOR;} void fragment(){vec4 c=texture(TEXTURE,UV)*tint; vec2 a=abs(local)/vec2(%f,%f); float noise=0.028*sin(local.x*0.043)*sin(local.y*0.033)+0.025*sin(local.y*0.061); float e=pow(pow(a.x,6.0)+pow(a.y,6.0),1.0/6.0)+noise; c.a*=1.0-smoothstep(0.76,0.98,e); COLOR=c;}" % [rect.size.x*2,rect.size.y*2]
		var mat = ShaderMaterial.new()
		mat.shader = shader
		sprite.material = mat
	return sprite
func prop(asset: String, feet: Vector2, width: float, collision: Vector2, sorted := true) -> Sprite2D:
	var root = Node2D.new()
	root.position = feet
	(yworld if sorted else terrain).add_child(root)
	var sprite = Sprite2D.new()
	sprite.texture = load(ROOT+asset+".png")
	var factor = width/sprite.texture.get_width()
	sprite.scale = Vector2.ONE*factor
	sprite.position.y = -sprite.texture.get_height()*factor*0.5
	root.add_child(sprite)
	if collision != Vector2.ZERO:
		var body = StaticBody2D.new()
		body.position.y = -collision.y*0.5
		var shape = CollisionShape2D.new()
		var rectangle = RectangleShape2D.new()
		rectangle.size = collision
		shape.shape = rectangle
		body.add_child(shape)
		root.add_child(body)
	return sprite
func wall(rect: Rect2):
	var body = StaticBody2D.new()
	body.position = rect.get_center()
	var shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = rect.size
	shape.shape = rectangle
	body.add_child(shape)
	add_child(body)
func wall_polygon(points: Array):
	var body = StaticBody2D.new()
	var polygon = CollisionPolygon2D.new()
	polygon.polygon = PackedVector2Array(points)
	body.add_child(polygon)
	add_child(body)
func particles(point: Vector2, color: Color, amount: int, direction: Vector2, lifetime: float, size: float):
	var p = CPUParticles2D.new()
	p.position = point
	p.amount = amount
	p.lifetime = lifetime
	p.direction = direction.normalized()
	p.initial_velocity_min = direction.length()*0.5
	p.initial_velocity_max = direction.length()
	p.gravity = Vector2.ZERO
	p.spread = 20
	p.scale_amount_min = size*0.5
	p.scale_amount_max = size
	p.color = color
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 7
	p.z_index = 5
	add_child(p)
func label_at(value: String, point: Vector2, size: int, color: Color):
	var label = Label.new()
	label.text = value
	label.position = point
	label.add_theme_font_size_override("font_size",size)
	label.modulate = color
	label.add_theme_color_override("font_shadow_color",Color.BLACK)
	label.add_theme_constant_override("shadow_offset_y",2)
	terrain.add_child(label)
func _process(delta):
	phase += delta
	for i in trees.size():
		trees[i].skew = sin(phase*0.7+i)*0.006
