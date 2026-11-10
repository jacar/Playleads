extends SceneTree


const STREET_MIN := -39.0
const STREET_MAX := 39.0
const ROAD_HALF := 4.0
const WALK_TOP := 0.16
const FACADE := 7.5


func _initialize() -> void:
	CityGeo.setup(null)
	var city := Node3D.new()
	city.name = "City"
	CityGeo.setup(city)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2727
	_ground(city)
	_north_buildings(city, rng)
	_south_buildings(city, rng)
	_far_buildings(city)
	_props(city, rng)
	_people(city)
	_boundaries(city)
	var spawn := Marker3D.new()
	spawn.name = "Spawn"
	spawn.position = Vector3(-24.0, 0.2, -5.35)
	spawn.rotation_degrees.y = 180.0
	city.add_child(spawn)
	CityGeo.own(spawn)
	var packed := PackedScene.new()
	packed.pack(city)
	var err := ResourceSaver.save(packed, "res://world/city.tscn")
	print("save result: ", err)
	city.free()
	quit()


func _ground(city: Node) -> void:
	CityGeo.box(city, "BaseGround", Vector3(0, -0.6, 0), Vector3(140, 1.0, 70), "stucco_sand", Vector3.ZERO, true)
	CityGeo.box(city, "Road", Vector3(0, -0.02, 0), Vector3(78, 0.08, 8.0), "asphalt")
	CityGeo.box(city, "SidewalkN", Vector3(0, 0.08, -5.75), Vector3(78, 0.16, 3.5), "concrete", Vector3.ZERO, true)
	CityGeo.box(city, "SidewalkS", Vector3(0, 0.08, 5.75), Vector3(78, 0.16, 3.5), "concrete", Vector3.ZERO, true)
	CityGeo.box(city, "CurbN", Vector3(0, 0.09, -4.08), Vector3(78, 0.18, 0.2), "curb", Vector3.ZERO, true)
	CityGeo.box(city, "CurbS", Vector3(0, 0.09, 4.08), Vector3(78, 0.18, 0.2), "curb", Vector3.ZERO, true)
	var x := -36.0
	while x < 37.0:
		CityGeo.box(city, "Dash", Vector3(x, 0.025, 0), Vector3(1.9, 0.01, 0.12), "road_line")
		CityGeo.box(city, "LaneEdgeN", Vector3(x + 1.2, 0.024, -3.55), Vector3(2.4, 0.01, 0.06), "road_line")
		x += 5.2
	for i in 8:
		CityGeo.box(city, "Crosswalk", Vector3(34.0, 0.026, -3.2 + float(i) * 0.92), Vector3(2.6, 0.012, 0.45), "road_line")
	for i in 3:
		CityGeo.cylinder(city, "Manhole", Vector3(-18.0 + float(i) * 26.0, 0.028, 0.9 * float(i % 2) - 0.4), 0.38, 0.02, "metal_dark", Vector3.ZERO, false, 20)
	var sx := -36.0
	while sx < 37.0:
		CityGeo.box(city, "SlabSeamN", Vector3(sx, 0.165, -5.75), Vector3(0.035, 0.006, 3.4), "curb")
		CityGeo.box(city, "SlabSeamS", Vector3(sx, 0.165, 5.75), Vector3(0.035, 0.006, 3.4), "curb")
		sx += 4.2
	CityGeo.box(city, "CurbPaintN", Vector3(-2.0, 0.19, -4.19), Vector3(24.0, 0.012, 0.08), "paint")
	CityGeo.box(city, "CurbPaintS", Vector3(10.0, 0.19, 4.19), Vector3(18.0, 0.012, 0.08), "paint")


func _north_buildings(city: Node, rng: RandomNumberGenerator) -> void:
	var shops := [
		{"id": "ferreteria", "cx": -15.0, "pal": {
			"wall": "stucco_ochre", "upper": "stucco_sand", "sign": "sign_darkgreen",
			"text": Color(0.95, 0.88, 0.72), "awning_a": "awning_terra", "awning_b": "awning_cream",
			"door": "wood", "tagline": "FERRETERÍA · DESDE 1987", "number": "27-43", "balcony": false}},
		{"id": "papeleria", "cx": 0.0, "pal": {
			"wall": "stucco_blue", "upper": "stucco_cream", "sign": "sign_blue",
			"text": Color(0.95, 0.9, 0.79), "awning_a": "awning_blue", "awning_b": "awning_cream",
			"door": "trim_dark", "tagline": "PAPELERÍA · IMPRESIONES", "number": "27-51", "balcony": false}},
		{"id": "cafeteria", "cx": 15.0, "pal": {
			"wall": "stucco_terra", "upper": "stucco_ochre", "sign": "sign_wood",
			"text": Color(0.97, 0.9, 0.74), "awning_a": "awning_green", "awning_b": "awning_cream",
			"door": "wood", "tagline": "CAFÉ · PAN · TARDE", "number": "27-63", "balcony": true}},
	]
	for shop in shops:
		CityShops.build(city, str(shop["id"]), float(shop["cx"]), shop["pal"])
	_simple_building(city, "TiendaDonPacho", -7.5, 6.4, 7.4, -1, "stucco_rose", "Tienda Don Pacho", "sign_darkgreen", "ABARROTES · FIAMBRES", "awning_terra", "awning_cream", rng, true)
	_simple_building(city, "ZapateriaElPaso", 7.5, 6.4, 8.2, -1, "stucco_green", "Zapatería El Paso", "sign_wood", "CUERO · REMIENDOS", "awning_green", "awning_cream", rng, false)
	_simple_building(city, "MercadoLa27", -27.0, 9.4, 7.0, -1, "stucco_cream", "Mercado La 27", "sign_darkgreen", "FRUTAS · VERDURAS", "awning_green", "awning_cream", rng, true)
	_simple_building(city, "Casa31", -35.5, 7.0, 9.6, -1, "stucco_sand", "", "", "", "awning_terra", "awning_cream", rng, false)
	_simple_building(city, "DrogueriaLa27", 27.0, 9.4, 8.6, -1, "stucco_blue", "Droguería La 27", "sign_blue", "SALUD · DOMICILIOS", "awning_blue", "awning_cream", rng, true)
	_simple_building(city, "Casa39", 35.5, 7.0, 7.6, -1, "stucco_ochre", "", "", "", "awning_terra", "awning_cream", rng, false)


func _south_buildings(city: Node, rng: RandomNumberGenerator) -> void:
	_simple_building(city, "TiendaDonaPilar", -32.0, 12.0, 7.8, 1, "stucco_rose", "Tienda Doña Pilar", "sign_wood", "ABARROTES · LICORES", "awning_terra", "awning_cream", rng, true)
	_simple_building(city, "PanaderiaEspiga", -18.0, 14.0, 8.6, 1, "stucco_ochre", "Panadería La Espiga", "sign_darkgreen", "PAN CALIENTE · TORTAS", "awning_green", "awning_cream", rng, true)
	_simple_building(city, "EdificioValencia", -2.0, 16.0, 10.2, 1, "stucco_cream", "Edificio Valencia", "", "APARTAMENTOS · 1962", "awning_blue", "awning_cream", rng, false)
	_simple_building(city, "SastreriaPiedad", 14.0, 14.0, 8.2, 1, "stucco_blue", "Sastrería Piedad", "sign_blue", "COSTURAS · ARREGLOS", "awning_blue", "awning_cream", rng, false)
	_simple_building(city, "Casa27", 30.0, 14.0, 9.4, 1, "stucco_green", "", "", "", "awning_green", "awning_cream", rng, true)


func _simple_building(city: Node, node_name: String, cx: float, width: float, height: float, side: int, wall_key: String, sign_text: String, sign_key: String, tagline: String, awn_a: String, awn_b: String, rng: RandomNumberGenerator, lit_shop: bool) -> void:
	var root := Node3D.new()
	root.name = node_name
	city.add_child(root)
	CityGeo.own(root)
	var facade_z := FACADE * float(side)
	var body_z := facade_z + float(side) * 3.25
	var front_yaw := 0.0 if side < 0 else 180.0
	var towards := -float(side)
	CityGeo.box(root, "Body", Vector3(cx, height * 0.5, body_z), Vector3(width, height, 6.5), wall_key, Vector3.ZERO, true)
	CityGeo.box(root, "Cornice", Vector3(cx, 3.35, facade_z - towards * 0.14), Vector3(width + 0.3, 0.22, 0.4), "trim_cream")
	CityGeo.box(root, "BaseBand", Vector3(cx, 0.34, facade_z - towards * 0.08), Vector3(width + 0.1, 0.5, 0.24), "trim_dark")
	CityGeo.box(root, "PilasterL", Vector3(cx - width * 0.5 + 0.28, height * 0.5, facade_z - towards * 0.1), Vector3(0.4, height, 0.3), "trim_cream")
	CityGeo.box(root, "PilasterR", Vector3(cx + width * 0.5 - 0.28, height * 0.5, facade_z - towards * 0.1), Vector3(0.4, height, 0.3), "trim_cream")
	CityGeo.box(root, "TopBand", Vector3(cx, height - 0.35, facade_z - towards * 0.12), Vector3(width + 0.2, 0.5, 0.28), "trim_cream")
	if sign_text != "":
		CityGeo.box(root, "ShopFrontGlass", Vector3(cx - width * 0.18, 1.75, facade_z - towards * 0.02), Vector3(width * 0.42, 1.5, 0.05), "glass_warm" if lit_shop else "glass")
		CityGeo.box(root, "ShopFrontFrameL", Vector3(cx - width * 0.39, 1.75, facade_z - towards * 0.03), Vector3(0.1, 1.65, 0.1), "trim_dark")
		CityGeo.box(root, "ShopFrontFrameR", Vector3(cx + width * 0.03, 1.75, facade_z - towards * 0.03), Vector3(0.1, 1.65, 0.1), "trim_dark")
		CityGeo.box(root, "ShopFrontMullion", Vector3(cx - width * 0.18, 1.75, facade_z - towards * 0.03), Vector3(0.06, 1.5, 0.08), "trim_dark")
		CityGeo.box(root, "ShopSill", Vector3(cx - width * 0.18, 1.0, facade_z - towards * 0.12), Vector3(width * 0.46, 0.12, 0.3), "trim_cream")
		CityGeo.awning(root, "Awning", Vector3(cx - width * 0.14, 2.62, facade_z - towards * 0.02), front_yaw, width * 0.5, 1.0, awn_a, awn_b)
		CityGeo.sign(root, "Sign", Vector3(cx, 3.72, facade_z - towards * 0.1), front_yaw, minf(width - 1.0, 6.2), 0.7, sign_key, sign_text, Color(0.95, 0.89, 0.76), "display", 0.26)
		CityGeo.label3d(root, tagline, Vector3(cx, 3.3, facade_z - towards * 0.1), 0.11, Color(0.16, 0.13, 0.10), Vector3(0, front_yaw, 0), "display")
		CityGeo.box(root, "ShopDoor", Vector3(cx + width * 0.34, 1.2, facade_z - towards * 0.01), Vector3(1.1, 2.3, 0.1), "wood")
		CityGeo.box(root, "ShopDoorGlass", Vector3(cx + width * 0.34, 1.75, facade_z - towards * 0.06), Vector3(0.62, 0.85, 0.03), "glass")
		CityGeo.sphere(root, "ShopKnob", Vector3(cx + width * 0.34 - 0.38, 1.05, facade_z - towards * 0.07), 0.04, "brass")
		CityGeo.box(root, "Step", Vector3(cx + width * 0.34, 0.16, facade_z - towards * 0.35), Vector3(1.4, 0.08, 0.5), "curb")
	else:
		CityGeo.box(root, "MainDoor", Vector3(cx + width * 0.28, 1.25, facade_z - towards * 0.01), Vector3(1.3, 2.5, 0.12), "wood")
		CityGeo.box(root, "DoorFrameL", Vector3(cx + width * 0.28 - 0.7, 1.25, facade_z - towards * 0.04), Vector3(0.14, 2.6, 0.16), "trim_dark")
		CityGeo.box(root, "DoorFrameR", Vector3(cx + width * 0.28 + 0.7, 1.25, facade_z - towards * 0.04), Vector3(0.14, 2.6, 0.16), "trim_dark")
		CityGeo.box(root, "DoorCanopy", Vector3(cx + width * 0.28, 2.7, facade_z - towards * 0.55), Vector3(2.0, 0.12, 1.1), "trim_dark", Vector3(-8 * towards, 0, 0))
		CityGeo.box(root, "Step", Vector3(cx + width * 0.28, 0.16, facade_z - towards * 0.4), Vector3(1.8, 0.08, 0.6), "curb")
	# upper windows
	var floors := 1
	if height > 7.2:
		floors = 2
	var cols := 3 if width >= 10.0 else 2
	for f in floors:
		var wy := 4.9 + float(f) * 2.0
		if wy > height - 1.2:
			continue
		for c in cols:
			var wx := cx - width * 0.28 + float(c) * (width * 0.56 / float(maxi(cols - 1, 1)))
			var lit := rng.randf() < 0.14
			CityGeo.window_unit(root, "Win", Vector3(wx, wy, facade_z - towards * 0.06), front_yaw, 1.15, 1.5, lit, true)
			if rng.randf() < 0.3:
				CityGeo.plant(root, Vector3(wx, wy - 0.85, facade_z - towards * 0.28), 0.7)
	CityGeo.ac_unit(root, Vector3(cx + width * 0.36, 5.7, facade_z - towards * 0.2), front_yaw)
	CityGeo.box(root, "DrainPipe", Vector3(cx - width * 0.48, height * 0.45, facade_z - towards * 0.14), Vector3(0.1, height * 0.85, 0.1), "metal_dark")
	CityGeo.box(root, "MeterBox", Vector3(cx - width * 0.42, 2.0, facade_z - towards * 0.12), Vector3(0.3, 0.42, 0.14), "metal")
	CityGeo.box(root, "ParapetF", Vector3(cx, height + 0.22, facade_z + towards * 0.0), Vector3(width + 0.2, 0.5, 0.25), "trim_cream")
	for i in int(width / 3.2):
		var bx := cx - width * 0.3 + float(i) * 2.9
		CityGeo.balcony(root, "Balcony", Vector3(bx, 4.15, facade_z), front_yaw, 2.4, rng.randf() < 0.55)
	if (node_name == "EdificioValencia" or node_name == "Casa31" or node_name == "Casa27") and floors > 1:
		CityGeo.balcony(root, "BalconyTop", Vector3(cx - 2.2, 6.2, facade_z), front_yaw, 4.2, true)
	CityGeo.roof_tank(root, Vector3(cx - width * 0.22, height + 0.4, body_z - 1.4))
	CityGeo.roof_tank(root, Vector3(cx + width * 0.2, height + 0.4, body_z + 1.1))
	CityGeo.tube(root, Vector3(cx + width * 0.05, height + 0.4, body_z + 2.0), Vector3(cx + width * 0.05, height + 2.6, body_z + 2.0), 0.03, "metal_dark")
	CityGeo.tube(root, Vector3(cx + width * 0.05 - 0.4, height + 2.3, body_z + 2.0), Vector3(cx + width * 0.05 + 0.4, height + 2.3, body_z + 2.0), 0.02, "metal_dark")
	if tagline != "":
		CityGeo.label3d(root, tagline, Vector3(cx - width * 0.02, 2.25, facade_z - towards * 0.14), 0.13, Color(0.62, 0.5, 0.35), Vector3(0, front_yaw, 0), "serif_italic")


func _far_buildings(city: Node) -> void:
	var heights := [8.0, 11.0, 9.0, 13.0, 7.5, 10.0]
	for i in 6:
		var x := -52.0 + float(i) * 3.6
		CityGeo.box(city, "FarW", Vector3(x, float(heights[i]) * 0.5 - 0.1, -13.0 - float(i % 2) * 2.0), Vector3(3.4, float(heights[i]), 8.0), "stucco_sand")
		CityGeo.box(city, "FarE", Vector3(46.0 + float(i) * 3.4, float(heights[5 - i]) * 0.5 - 0.1, -11.0 + float(i % 3) * 7.0), Vector3(3.2, float(heights[5 - i]), 9.0), "stucco_cream")
	CityGeo.box(city, "EndWallE", Vector3(62.0, 5.0, 0), Vector3(2.0, 11.0, 34.0), "stucco_sand")


func _props(city: Node, rng: RandomNumberGenerator) -> void:
	var props := Node3D.new()
	props.name = "StreetProps"
	city.add_child(props)
	CityGeo.own(props)
	CityGeo.street_lamp(props, Vector3(-30.0, 0.16, -4.65), -90.0)
	CityGeo.street_lamp(props, Vector3(-8.0, 0.16, -4.65), -90.0)
	CityGeo.street_lamp(props, Vector3(20.0, 0.16, -4.65), -90.0)
	CityGeo.street_lamp(props, Vector3(-19.0, 0.16, 4.65), 90.0)
	CityGeo.street_lamp(props, Vector3(8.0, 0.16, 4.65), 90.0)
	CityGeo.street_lamp(props, Vector3(32.0, 0.16, 4.65), 90.0)
	for cx in [-26.0, -6.0, 12.0, 30.0]:
		CityGeo.cable(props, Vector3(cx, 6.1, -7.4), Vector3(cx + 3.0, 5.7, 7.4), 0.7, 0.018, "metal_dark", 10)
		CityGeo.cable(props, Vector3(cx + 3.0, 5.7, 7.4), Vector3(cx + 14.0, 6.3, -7.4), 0.9, 0.016, "metal_dark", 12)
	CityGeo.cable(props, Vector3(-20, 5.3, -7.3), Vector3(4, 5.0, 7.3), 0.85, 0.014, "metal_dark", 12)
	CityGeo.cable(props, Vector3(-2, 5.1, -7.3), Vector3(22, 4.9, 7.3), 0.8, 0.014, "metal_dark", 12)
	for i in 10:
		var t := 0.08 + float(i) * 0.09
		var p := Vector3(-20, 5.3, -7.3).lerp(Vector3(4, 5.0, 7.3), t)
		p.y -= sin(t * PI) * 0.85
		CityGeo.sphere(props, "StringBulb", p + Vector3(0, -0.1, 0), 0.05, "lamp_glow", Vector3(1, 1.3, 1))
	for i in 9:
		var t := 0.1 + float(i) * 0.1
		var p := Vector3(-2, 5.1, -7.3).lerp(Vector3(22, 4.9, 7.3), t)
		p.y -= sin(t * PI) * 0.8
		CityGeo.sphere(props, "StringBulb2", p + Vector3(0, -0.1, 0), 0.045, "lamp_glow", Vector3(1, 1.3, 1))
	CityGeo.car(props, Vector3(6.0, 0.0, 2.55), 0.0, "car_blue")
	CityGeo.car(props, Vector3(-27.0, 0.0, 2.55), 0.0, "car_red")
	CityGeo.car(props, Vector3(25.0, 0.0, -2.55), 0.0, "car_blue")
	# fruit stand
	var fs := Node3D.new()
	fs.name = "FruitStand"
	fs.position = Vector3(-23.0, 0.16, 5.6)
	props.add_child(fs)
	CityGeo.own(fs)
	CityGeo.box(fs, "Table", Vector3(0, 0.52, 0), Vector3(4.0, 0.9, 1.1), "wood", Vector3.ZERO, true)
	CityGeo.box(fs, "TableTop", Vector3(0, 0.99, 0), Vector3(4.2, 0.07, 1.2), "wood_light")
	CityGeo.awning(fs, "StandAwning", Vector3(0, 2.3, -0.1), 180.0, 4.6, 1.7, "awning_terra", "awning_cream")
	for i in 4:
		var bx := -1.5 + float(i) * 1.0
		CityGeo.box(fs, "FruitCrate", Vector3(bx, 1.14, 0.1), Vector3(0.85, 0.3, 0.75), "wood_light")
		for j in 6:
			var fx := bx - 0.28 + float(j % 3) * 0.28
			var fz := -0.05 + float(j / 3) * 0.3
			CityGeo.sphere(fs, "Fruit", Vector3(fx, 1.33, fz), 0.11, ["fruit_orange", "fruit_red", "fruit_green"][i % 3], Vector3(1, 0.9, 1))
	CityGeo.label3d(fs, "FRUTAS", Vector3(0, 2.52, 0.72), 0.24, Color(0.95, 0.88, 0.7), Vector3(0, 180, 0), "display")
	CityGeo.box(fs, "PriceBoard", Vector3(1.6, 1.55, 0.42), Vector3(0.4, 0.3, 0.03), "paper_white", Vector3(-12, 0, 0))
	CityGeo.label3d(fs, "3 x 1.000", Vector3(1.6, 1.55, 0.45), 0.06, Color(0.2, 0.14, 0.1), Vector3(-12, 180, 0), "display")
	CityGeo.cylinder(fs, "ScaleBase", Vector3(-1.9, 1.12, 0.1), 0.16, 0.05, "metal_dark", Vector3.ZERO, false, 14)
	CityGeo.box(fs, "ScaleArm", Vector3(-1.9, 1.28, 0.1), Vector3(0.08, 0.35, 0.08), "metal")
	CityGeo.box(fs, "ScaleHead", Vector3(-1.9, 1.48, 0.1), Vector3(0.26, 0.05, 0.18), "metal_dark")
	CityGeo.label3d(fs, "FRUTERÍA DON ISMA", Vector3(0, 2.15, 0.8), 0.065, Color(0.15, 0.12, 0.09), Vector3(0, 180, 0), "display")
	# street sign
	var ss := Node3D.new()
	ss.name = "StreetSign"
	ss.position = Vector3(-34.5, 0.16, -4.55)
	props.add_child(ss)
	CityGeo.own(ss)
	CityGeo.cylinder(ss, "Post", Vector3(0, 1.6, 0), 0.05, 3.2, "metal_dark", Vector3.ZERO, false, 10)
	CityGeo.box(ss, "PlateA", Vector3(0, 2.95, 0.06), Vector3(1.5, 0.28, 0.04), "sign_blue")
	CityGeo.label3d(ss, "CALLE 27", Vector3(0, 2.95, 0.09), 0.11, Color(0.95, 0.9, 0.78), Vector3.ZERO, "display")
	CityGeo.box(ss, "PlateB", Vector3(0, 2.6, 0.06), Vector3(1.3, 0.24, 0.04), "sign_darkgreen", Vector3(0, 0, 90))
	CityGeo.label3d(ss, "CRA 5", Vector3(0, 2.6, 0.09), 0.09, Color(0.95, 0.9, 0.78), Vector3.ZERO, "display")
	CityGeo.bike(props, Vector3(22.0, 0.16, -6.4), 12.0, "plastic_red")
	CityGeo.bike(props, Vector3(-12.0, 0.16, -6.6), -8.0, "metal")
	CityGeo.bike(props, Vector3(29.0, 0.16, 6.5), 96.0, "plastic_green")
	CityGeo.cylinder(props, "TrashCan", Vector3(12.5, 0.5, -6.5), 0.28, 0.8, "plastic_green", Vector3.ZERO, false, 12)
	CityGeo.cylinder(props, "TrashLid", Vector3(12.5, 0.94, -6.5), 0.3, 0.06, "metal_dark", Vector3.ZERO, false, 12)
	CityGeo.cylinder(props, "Hydrant", Vector3(3.5, 0.42, -4.7), 0.13, 0.55, "plastic_red", Vector3.ZERO, false, 10)
	CityGeo.sphere(props, "HydrantTop", Vector3(3.5, 0.72, -4.7), 0.14, "plastic_red")
	CityGeo.box(props, "HydrantCap", Vector3(3.5, 0.55, -4.7), Vector3(0.42, 0.1, 0.12), "plastic_red")
	CityGeo.box(props, "Mailbox", Vector3(-15.5, 0.75, -4.75), Vector3(0.45, 0.8, 0.3), "plastic_green")
	CityGeo.label3d(props, "CORREO", Vector3(-15.5, 0.88, -4.58), 0.05, Color(0.95, 0.9, 0.76), Vector3.ZERO, "display")
	CityGeo.box(props, "ChalkSignA", Vector3(14.2, 0.56, -4.9), Vector3(0.6, 0.8, 0.05), "chalk", Vector3(-8, 18, 0))
	CityGeo.label3d(props, "HOY\nTINTO\nCAMPERO", Vector3(14.2, 0.62, -4.82), 0.07, Color(0.92, 0.86, 0.66), Vector3(-8, 18, 0), "chalk")
	CityGeo.table(props, Vector3(17.2, 0.16, -5.7))
	CityGeo.chair(props, Vector3(16.5, 0.16, -5.7), 90.0)
	CityGeo.chair(props, Vector3(17.9, 0.16, -5.7), -90.0)
	CityGeo.table(props, Vector3(18.6, 0.16, -5.0))
	CityGeo.chair(props, Vector3(18.6, 0.16, -4.35), 180.0)
	CityGeo.plant(props, Vector3(19.4, 0.16, -6.6), 0.95)
	CityGeo.plant(props, Vector3(-21.8, 0.16, -6.7), 1.0)
	CityGeo.plant(props, Vector3(-9.2, 0.16, -6.6), 0.8)
	CityGeo.plant(props, Vector3(23.8, 0.16, 6.6), 1.0)
	# trees in planters
	for tp in [Vector3(-32.5, 0.16, 6.6), Vector3(2.5, 0.16, 6.7), Vector3(27.0, 0.16, -6.6)]:
		var p: Vector3 = tp
		CityGeo.cylinder(props, "TreePlanter", p + Vector3(0, 0.3, 0), 0.55, 0.6, "curb", Vector3.ZERO, true, 14, 0.58)
		CityGeo.cylinder(props, "Trunk", p + Vector3(0, 1.5, 0), 0.11, 2.0, "wood", Vector3.ZERO, false, 10, 0.08)
		CityGeo.sphere(props, "Crown", p + Vector3(0, 3.0, 0), 1.1, "leaf", Vector3(1.0, 0.85, 1.0))
		CityGeo.sphere(props, "Crown2", p + Vector3(0.6, 2.7, 0.2), 0.85, "leaf_light")
		CityGeo.sphere(props, "Crown3", p + Vector3(-0.55, 2.8, -0.3), 0.8, "leaf")
	# cones and crates near the corner
	CityGeo.cylinder(props, "Cone", Vector3(33.0, 0.38, -4.8), 0.2, 0.45, "fruit_orange", Vector3.ZERO, false, 10, 0.03)
	CityGeo.box(props, "CornerCrate", Vector3(32.5, 0.36, -6.7), Vector3(0.7, 0.4, 0.5), "wood_light")
	CityGeo.box(props, "CornerCrate2", Vector3(33.2, 0.56, -6.7), Vector3(0.55, 0.4, 0.45), "wood_light", Vector3(0, 22, 0))


func _people(city: Node) -> void:
	var people := Node3D.new()
	people.name = "People"
	city.add_child(people)
	CityGeo.own(people)
	var red := "res://art/people/2895f962-5d8e-430d-bd2e-f68a47ba36e9/character.tscn"
	var teen := "res://art/people/2efdeeb8-2874-4697-b833-43f443097048/character.tscn"
	var adel := "res://art/people/3840e192-5d0d-4a12-8d72-c3add8d6e789/character.tscn"
	var parkour := "res://art/people_extra/aa4945ef-9ff6-435d-9056-4478d2de9574/character.tscn"
	var walker_a := CityGeo.person(people, "VecinoRojo", red, Vector3(-16.0, WALK_TOP, -5.9), 90.0, "", "", "Walk", 1.0, 1.1, PackedVector3Array([Vector3(0, 0, 0), Vector3(40, 0, 0)]))
	walker_a.set("target_height", 1.78)
	var walker_b := CityGeo.person(people, "VecinoAzul", teen, Vector3(8.0, WALK_TOP, 5.9), -90.0, "", "", "Run", 0.45, 1.25, PackedVector3Array([Vector3(0, 0, 0), Vector3(-38, 0, 0)]))
	walker_b.set("target_height", 1.7)
	var walker_c := CityGeo.person(people, "VecinoVerde", parkour, Vector3(6.0, WALK_TOP, -5.4), 90.0, "", "", "Walk", 1.0, 1.0, PackedVector3Array([Vector3(0, 0, 0), Vector3(11, 0, 0), Vector3(10, 0, 2.0)]))
	walker_c.set("target_height", 1.75)
	var idle := CityGeo.person(people, "DonIsma", adel, Vector3(-21.6, WALK_TOP, 6.3), 200.0, "", "", "Idle", 1.0)
	idle.set("target_height", 1.72)


func _boundaries(city: Node) -> void:
	for x in [-40.0, 40.0]:
		var body := StaticBody3D.new()
		body.name = "Boundary"
		body.position = Vector3(float(x), 3.0, 0)
		city.add_child(body)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(1.0, 6.0, 24.0)
		shape.shape = box
		body.add_child(shape)
		CityGeo.own(body)
		CityGeo.own(shape)


