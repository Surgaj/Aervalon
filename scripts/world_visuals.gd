extends Node2D
var t:=0.0
var particles:Array[Node2D]=[]
func _ready(): _build()
func _process(delta):
	t+=delta
	for i in particles.size():
		var p=particles[i]
		if is_instance_valid(p):
			p.position.y-=delta*(7.0+i%3*2.0)
			p.modulate.a=0.35+sin(t*3+i)*0.18
			if p.position.y < 320: p.position.y=380
func poly(parent:Node,pts:Array,c:Color,z:=0):
	var p=Polygon2D.new();p.polygon=PackedVector2Array(pts);p.color=c;p.z_index=z;parent.add_child(p);return p
func _build():
	# stone road texture
	for y in range(260,500,24):
		for x in range(370+(y%48),900,46):
			poly(self,[Vector2(x,y),Vector2(x+28,y-3),Vector2(x+34,y+9),Vector2(x+5,y+13)],Color("#9b8158"),1)
	# dense vegetation frame
	for pos in [Vector2(35,150),Vector2(95,105),Vector2(160,155),Vector2(245,110),Vector2(310,165),Vector2(900,85),Vector2(955,125),Vector2(1015,75),Vector2(1080,130),Vector2(1140,80),Vector2(1210,145),Vector2(1260,90),Vector2(930,215),Vector2(1180,230)]:
		_tree(pos)
	# detailed buildings
	_house(Vector2(430,255),Color("#513c35"),"INN")
	_house(Vector2(690,250),Color("#37465a"),"GUILD")
	_forge(Vector2(455,370))
	_market(Vector2(735,365))
	_shrine(Vector2(845,305))
	_bridge()
	# props
	for p in [Vector2(405,430),Vector2(870,420),Vector2(775,455),Vector2(355,395)] : _barrel(p)
	for p in [Vector2(390,330),Vector2(825,445),Vector2(920,390)] : _crate(p)
	# banners and lamps
	_banner(Vector2(615,285));_banner(Vector2(895,345))
	_lamp(Vector2(575,370));_lamp(Vector2(815,345))
	# flowers
	for p in [Vector2(345,290),Vector2(910,280),Vector2(955,350),Vector2(300,445),Vector2(870,465)]:
		for k in 5:
			var q=p+Vector2(k*7,(k%2)*5);poly(self,[q,q+Vector2(2,-6),q+Vector2(4,0)],Color("#d7b7dc"),4)
func _tree(pos):
	poly(self,[pos+Vector2(-7,20),pos+Vector2(8,20),pos+Vector2(7,65),pos+Vector2(-6,65)],Color("#513b27"),3)
	for d in [Vector2(-20,12),Vector2(12,10),Vector2(0,-14)]:
		var q=pos+d;poly(self,[q+Vector2(-28,25),q+Vector2(-15,-15),q,q+Vector2(17,-22),q+Vector2(32,24)],Color("#21482c"),5)
		poly(self,[q+Vector2(-19,13),q+Vector2(-8,-13),q+Vector2(12,-16),q+Vector2(22,12)],Color("#356b3c"),6)
func _house(pos,roof,label):
	poly(self,[pos,pos+Vector2(145,0),pos+Vector2(145,92),pos+Vector2(0,92)],Color("#b18c58"),4)
	poly(self,[pos+Vector2(-15,3),pos+Vector2(30,-38),pos+Vector2(115,-38),pos+Vector2(160,3)],roof,7)
	# timber framing
	for x in [8,70,132]: poly(self,[pos+Vector2(x,4),pos+Vector2(x+7,4),pos+Vector2(x+7,90),pos+Vector2(x,90)],Color("#4b3327"),8)
	poly(self,[pos+Vector2(58,52),pos+Vector2(86,52),pos+Vector2(86,92),pos+Vector2(58,92)],Color("#35261f"),9)
	for x in [20,105]:
		poly(self,[pos+Vector2(x,28),pos+Vector2(x+22,28),pos+Vector2(x+22,48),pos+Vector2(x,48)],Color("#7fc0c5"),9)
func _forge(pos):
	poly(self,[pos,pos+Vector2(135,0),pos+Vector2(125,75),pos+Vector2(5,75)],Color("#332c29"),8)
	poly(self,[pos+Vector2(-10,0),pos+Vector2(20,-25),pos+Vector2(120,-25),pos+Vector2(145,0)],Color("#4b3b34"),9)
	# forge glow and anvil
	poly(self,[pos+Vector2(25,62),pos+Vector2(42,28),pos+Vector2(58,62)],Color("#f27b25"),10)
	poly(self,[pos+Vector2(32,60),pos+Vector2(42,40),pos+Vector2(50,60)],Color("#ffd66a"),11)
	poly(self,[pos+Vector2(78,50),pos+Vector2(112,50),pos+Vector2(105,59),pos+Vector2(85,59)],Color("#5b6265"),10)
	for i in 6:
		var s=poly(self,[Vector2(0,0),Vector2(3,-7),Vector2(6,0)],Color("#ffb347"),12);s.position=pos+Vector2(38+i*2,45+i*3);particles.append(s)
func _market(pos):
	poly(self,[pos,pos+Vector2(130,0),pos+Vector2(120,70),pos+Vector2(8,70)],Color("#70422f"),7)
	for x in range(0,130,26):
		poly(self,[pos+Vector2(x,-18),pos+Vector2(x+26,-18),pos+Vector2(x+22,4),pos+Vector2(x+2,4)],Color("#d8c292") if x%52==0 else Color("#3d5b79"),9)
	for x in [18,55,92]: _crate(pos+Vector2(x,50))
func _shrine(pos):
	poly(self,[pos+Vector2(-24,65),pos+Vector2(24,65),pos+Vector2(18,72),pos+Vector2(-18,72)],Color("#77766e"),7)
	poly(self,[pos+Vector2(-9,8),pos+Vector2(9,8),pos+Vector2(13,65),pos+Vector2(-13,65)],Color("#a6a39a"),8)
	poly(self,[pos+Vector2(-17,14),pos+Vector2(0,-18),pos+Vector2(17,14),pos+Vector2(7,24),pos+Vector2(-7,24)],Color("#c0bdb1"),9)
func _bridge():
	for x in range(560,705,16): poly(self,[Vector2(x,510),Vector2(x+13,510),Vector2(x+13,600),Vector2(x,600)],Color("#694727"),8)
	poly(self,[Vector2(550,510),Vector2(557,510),Vector2(557,600),Vector2(550,600)],Color("#39291f"),9)
	poly(self,[Vector2(708,510),Vector2(715,510),Vector2(715,600),Vector2(708,600)],Color("#39291f"),9)
func _barrel(p):
	poly(self,[p+Vector2(-9,-12),p+Vector2(9,-12),p+Vector2(11,12),p+Vector2(-11,12)],Color("#76502e"),9)
	poly(self,[p+Vector2(-11,-6),p+Vector2(11,-6),p+Vector2(11,-2),p+Vector2(-11,-2)],Color("#302c28"),10)
func _crate(p): poly(self,[p+Vector2(-11,-11),p+Vector2(11,-11),p+Vector2(11,11),p+Vector2(-11,11)],Color("#8b6035"),9)
func _banner(p):
	poly(self,[p,p+Vector2(4,0),p+Vector2(4,70),p+Vector2(0,70)],Color("#342b24"),9)
	poly(self,[p+Vector2(4,8),p+Vector2(32,8),p+Vector2(32,52),p+Vector2(18,62),p+Vector2(4,52)],Color("#284d75"),10)
func _lamp(p):
	poly(self,[p,p+Vector2(4,0),p+Vector2(4,52),p+Vector2(0,52)],Color("#332820"),10)
	poly(self,[p+Vector2(-7,-5),p+Vector2(11,-5),p+Vector2(8,12),p+Vector2(-4,12)],Color("#f2c05f"),11)
