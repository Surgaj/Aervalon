extends Node2D

func _ready():
	_build_world()

func poly(parent:Node, pts:Array, color:Color, z:=0):
	var p=Polygon2D.new()
	p.polygon=PackedVector2Array(pts)
	p.color=color
	p.z_index=z
	parent.add_child(p)
	return p

func _build_world():
	# grass texture patches
	for data in [[90,120],[180,185],[300,100],[930,520],[1040,610],[1150,560],[80,430],[280,420],[760,120]]:
		for j in range(5):
			var x=float(data[0])+j*13
			var y=float(data[1])+(j%2)*7
			poly(self,[Vector2(x,y+8),Vector2(x+3,y),Vector2(x+6,y+8)],Color("#5b7d3b"),1)
	# trees, deliberately layered silhouettes
	for pos in [Vector2(910,90),Vector2(970,70),Vector2(1030,105),Vector2(1090,70),Vector2(1160,115),Vector2(1220,75),Vector2(930,180),Vector2(1010,190),Vector2(1190,210),Vector2(1120,170),Vector2(90,170),Vector2(150,130),Vector2(230,175),Vector2(310,145)]:
		_tree(pos)
	# houses with roofs/windows
	_house(Vector2(445,280),Color("#9b5b32"))
	_house(Vector2(705,275),Color("#7d4930"))
	# forge awning + glowing fire
	poly(self,[Vector2(455,390),Vector2(565,390),Vector2(550,375),Vector2(470,375)],Color("#3a2922"),4)
	poly(self,[Vector2(493,426),Vector2(510,395),Vector2(527,426)],Color("#ff9b32"),5)
	poly(self,[Vector2(500,425),Vector2(510,407),Vector2(519,425)],Color("#ffe06a"),6)
	# bridge planks
	for x in range(570,691,15):
		poly(self,[Vector2(x,515),Vector2(x+11,515),Vector2(x+11,600),Vector2(x,600)],Color("#76502c"),3)
	# rocks and flowers
	for pos in [Vector2(350,530),Vector2(820,555),Vector2(905,480),Vector2(260,260)]:
		poly(self,[pos+Vector2(-10,6),pos+Vector2(-4,-6),pos+Vector2(8,-4),pos+Vector2(13,6)],Color("#77776c"),2)

func _tree(pos:Vector2):
	poly(self,[pos+Vector2(-6,24),pos+Vector2(7,24),pos+Vector2(5,58),pos+Vector2(-5,58)],Color("#604329"),2)
	poly(self,[pos+Vector2(-28,25),pos+Vector2(0,-28),pos+Vector2(28,25)],Color("#244c2c"),3)
	poly(self,[pos+Vector2(-22,5),pos+Vector2(2,-42),pos+Vector2(25,8)],Color("#35643a"),4)
	poly(self,[pos+Vector2(-13,-12),pos+Vector2(4,-48),pos+Vector2(17,-10)],Color("#477849"),5)

func _house(pos:Vector2, roof:Color):
	poly(self,[pos,pos+Vector2(100,0),pos+Vector2(100,70),pos+Vector2(0,70)],Color("#c4a36a"),3)
	poly(self,[pos+Vector2(-12,5),pos+Vector2(50,-38),pos+Vector2(112,5)],roof,5)
	poly(self,[pos+Vector2(43,40),pos+Vector2(61,40),pos+Vector2(61,70),pos+Vector2(43,70)],Color("#493224"),5)
	poly(self,[pos+Vector2(12,26),pos+Vector2(31,26),pos+Vector2(31,43),pos+Vector2(12,43)],Color("#8fd3d8"),5)
