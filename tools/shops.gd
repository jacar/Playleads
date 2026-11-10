class_name CityShops
extends RefCounted


const FRONT_Z := -7.5
const HALF_W := 4.3
const CEIL_Y := 3.2

const MODEL_OWNER_FERRETERIA := "res://art/people_extra/aa4945ef-9ff6-435d-9056-4478d2de9574/character.tscn"
const MODEL_OWNER_PAPELERIA := "res://art/people/32650f14-c4a5-40c7-9ac8-d9fcfe93c180/character.tscn"
const MODEL_OWNER_CAFETERIA := "res://art/people/741de2f9-18ec-43c9-888b-907035ad0223/character.tscn"
const MODEL_CUSTOMER_FERRETERIA := "res://art/people/1de1a862-55b7-4f93-8be8-c9654818b95c/3d_1de1a86255b74f938be8c965_1794186194798.glb"
const MODEL_CUSTOMER_PAPELERIA := "res://art/people_extra/ab54cc3a-780c-424a-acb8-0f33597781a3/3d_ab54cc3a780c424aacb80f33_1792407967071.glb"
const MODEL_CUSTOMER_CAFETERIA := "res://art/people/e75521b6-3cde-46d8-8a3c-dd1747140890/3d_e75521b63cde46d88a3cdd17_1790011510637.glb"


static func build(parent: Node, shop_id: String, cx: float, pal: Dictionary) -> void:
	var root := Node3D.new()
	root.name = shop_id.capitalize()
	parent.add_child(root)
	CityGeo.own(root)
	_shell(root, cx, pal)
	_upper(root, cx, pal)
	_front(root, cx, shop_id, pal)
	_interior_shell(root, cx, pal)
	match shop_id:
		"ferreteria":
			_ferreteria(root, cx, pal)
		"papeleria":
			_papeleria(root, cx, pal)
		"cafeteria":
			_cafeteria(root, cx, pal)
	_people(root, shop_id, cx)
	_doorways(root, shop_id, cx)


static func _shell(root: Node, cx: float, pal: Dictionary) -> void:
	var wall: String = pal["wall"]
	CityGeo.box(root, "SideL", Vector3(cx - 3.95, 1.6, -10.65), Vector3(0.3, 3.2, 6.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "SideR", Vector3(cx + 3.95, 1.6, -10.65), Vector3(0.3, 3.2, 6.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "BackWall", Vector3(cx, 1.6, -13.95), Vector3(8.6, 3.2, 0.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "Floor", Vector3(cx, 0.0, -10.75), Vector3(7.9, 0.32, 6.4), "stucco_sand", Vector3.ZERO, true)
	CityGeo.box(root, "Ceiling", Vector3(cx, 3.19, -10.75), Vector3(7.9, 0.10, 6.4), "ceiling")
	for i in 6:
		var z := -8.2 - float(i) * 0.9
		CityGeo.box(root, "FloorSeam", Vector3(cx, 0.165, z), Vector3(7.7, 0.006, 0.03), "trim_dark")
	CityGeo.box(root, "Threshold", Vector3(cx + 1.9, 0.17, -7.6), Vector3(1.85, 0.03, 0.9), "trim_dark")


static func _upper(root: Node, cx: float, pal: Dictionary) -> void:
	var upper: String = pal["upper"]
	CityGeo.box(root, "UpperBlock", Vector3(cx, 5.1, -10.65), Vector3(8.6, 3.4, 6.5), upper, Vector3.ZERO, true)
	CityGeo.box(root, "RoofSlab", Vector3(cx, 6.82, -10.65), Vector3(8.9, 0.16, 6.8), "trim_cream")
	CityGeo.box(root, "ParapetF", Vector3(cx, 7.1, -7.36), Vector3(8.9, 0.55, 0.22), "trim_cream")
	CityGeo.box(root, "ParapetB", Vector3(cx, 7.1, -13.94), Vector3(8.9, 0.55, 0.22), "trim_cream")
	CityGeo.box(root, "ParapetL", Vector3(cx - 4.35, 7.1, -10.65), Vector3(0.22, 0.55, 6.6), "trim_cream")
	CityGeo.box(root, "ParapetR", Vector3(cx + 4.35, 7.1, -10.65), Vector3(0.22, 0.55, 6.6), "trim_cream")
	CityGeo.box(root, "Cornice", Vector3(cx, 3.28, -7.36), Vector3(8.9, 0.18, 0.36), "trim_cream")
	CityGeo.box(root, "PilasterL", Vector3(cx - 4.18, 1.6, -7.34), Vector3(0.26, 3.2, 0.36), "trim_cream")
	CityGeo.box(root, "PilasterR", Vector3(cx + 4.18, 1.6, -7.34), Vector3(0.26, 3.2, 0.36), "trim_cream")
	CityGeo.window_unit(root, "WinUpL", Vector3(cx - 2.1, 4.75, -7.42), 0.0, 1.15, 1.5, false, true)
	CityGeo.window_unit(root, "WinUpR", Vector3(cx + 2.0, 4.75, -7.42), 0.0, 1.15, 1.5, false, true)
	CityGeo.ac_unit(root, Vector3(cx + 3.4, 5.9, -7.22), 0.0)
	CityGeo.box(root, "DrainPipe", Vector3(cx - 4.3, 3.3, -7.3), Vector3(0.1, 6.4, 0.1), "metal_dark")
	CityGeo.roof_tank(root, Vector3(cx - 2.1, 6.88, -11.4))
	CityGeo.tube(root, Vector3(cx + 2.6, 7.4, -12.6), Vector3(cx + 2.6, 9.1, -12.6), 0.03, "metal_dark")
	CityGeo.tube(root, Vector3(cx + 2.3, 8.7, -12.6), Vector3(cx + 2.9, 8.7, -12.6), 0.02, "metal_dark")
	if pal.get("balcony", false):
		CityGeo.balcony(root, "Balcony", Vector3(cx + 0.4, 4.0, -7.5), 0.0, 3.4, true)


static func _front(root: Node, cx: float, shop_id: String, pal: Dictionary) -> void:
	var wall: String = pal["wall"]
	var door_x := cx + 1.9
	CityGeo.box(root, "PierL", Vector3(cx - 3.9, 1.6, -7.65), Vector3(0.8, 3.2, 0.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "PierM", Vector3(cx + 0.275, 1.6, -7.65), Vector3(1.55, 3.2, 0.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "PierR", Vector3(cx + 3.525, 1.6, -7.65), Vector3(1.55, 3.2, 0.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "BelowWindow", Vector3(cx - 2.0, 0.5, -7.65), Vector3(3.0, 1.0, 0.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "WindowHeader", Vector3(cx - 2.0, 2.85, -7.65), Vector3(3.0, 0.7, 0.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "DoorHeader", Vector3(door_x, 2.85, -7.65), Vector3(1.7, 0.7, 0.3), wall, Vector3.ZERO, true)
	CityGeo.box(root, "WindowGlass", Vector3(cx - 2.0, 1.75, -7.47), Vector3(2.9, 1.4, 0.03), "glass_shop")
	CityGeo.box(root, "WinFrameL", Vector3(cx - 3.45, 1.75, -7.44), Vector3(0.09, 1.5, 0.1), "trim_dark")
	CityGeo.box(root, "WinFrameR", Vector3(cx - 0.55, 1.75, -7.44), Vector3(0.09, 1.5, 0.1), "trim_dark")
	CityGeo.box(root, "WinFrameT", Vector3(cx - 2.0, 2.48, -7.44), Vector3(3.0, 0.09, 0.1), "trim_dark")
	CityGeo.box(root, "WinSill", Vector3(cx - 2.0, 1.04, -7.34), Vector3(3.12, 0.12, 0.3), "trim_cream")
	CityGeo.box(root, "WinMullion", Vector3(cx - 2.0, 1.75, -7.44), Vector3(0.06, 1.4, 0.08), "trim_dark")
	CityGeo.box(root, "DoorFrameL", Vector3(cx + 1.0, 1.25, -7.62), Vector3(0.12, 2.5, 0.34), "wood")
	CityGeo.box(root, "DoorFrameR", Vector3(cx + 2.8, 1.25, -7.62), Vector3(0.12, 2.5, 0.34), "wood")
	CityGeo.box(root, "DoorFrameT", Vector3(door_x, 2.52, -7.62), Vector3(1.92, 0.12, 0.34), "wood")
	CityGeo.box(root, "DoorLeaf", Vector3(cx + 2.78, 1.28, -8.32), Vector3(0.06, 2.42, 0.88), pal["door"], Vector3(0, 0, 0), false)
	CityGeo.box(root, "DoorGlass", Vector3(cx + 2.75, 1.72, -8.32), Vector3(0.03, 1.0, 0.56), "glass_shop")
	CityGeo.sphere(root, "Knob", Vector3(cx + 2.72, 1.05, -8.72), 0.045, "brass")
	CityGeo.awning(root, "Awning", Vector3(cx - 2.0, 2.62, -7.4), 0.0, 3.5, 1.15, pal["awning_a"], pal["awning_b"])
	var shop: Dictionary = GameData.SHOPS[shop_id]
	CityGeo.sign(root, "ShopSign", Vector3(cx, 3.62, -7.36), 0.0, 6.5, 0.78, pal["sign"], str(shop["name"]), pal["text"], "display", 0.30)
	CityGeo.label3d(root, str(pal.get("tagline", "ABIERTO DESDE 1987")), Vector3(cx, 3.22, -7.34), 0.12, Color(0.94, 0.88, 0.74), Vector3.ZERO, "display")
	CityGeo.sign(root, "Hanging", Vector3(cx - 4.42, 2.62, -7.0), 90.0, 1.15, 0.62, pal["sign"], str(shop["short"]).to_upper(), pal["text"], "display", 0.115)
	CityGeo.label3d(root, str(pal.get("number", "27-43")), Vector3(cx + 2.95, 2.15, -7.36), 0.12, Color(0.15, 0.12, 0.09), Vector3.ZERO, "display")
	CityGeo.label3d(root, "ABIERTO", Vector3(cx + 1.9, 1.95, -8.29), 0.1, Color(0.93, 0.86, 0.7), Vector3(0, 180, 0), "display")
	CityGeo.plant(root, Vector3(cx + 3.55, 0.16, -6.9), 0.9)
	CityGeo.crate(root, Vector3(cx - 3.9, 0.16, -6.95), Vector3(0.55, 0.4, 0.45), "wood_light")


static func _interior_shell(root: Node, cx: float, pal: Dictionary) -> void:
	CityGeo.box(root, "IntWallL", Vector3(cx - 3.72, 1.6, -10.65), Vector3(0.12, 3.0, 6.2), "stucco_cream")
	CityGeo.box(root, "IntWallR", Vector3(cx + 3.72, 1.6, -10.65), Vector3(0.12, 3.0, 6.2), "stucco_cream")
	CityGeo.box(root, "IntWallB", Vector3(cx, 1.6, -13.66), Vector3(7.4, 3.0, 0.12), "stucco_cream")
	CityGeo.box(root, "SkirtingL", Vector3(cx - 3.66, 0.28, -10.65), Vector3(0.06, 0.24, 6.2), "wood")
	CityGeo.box(root, "SkirtingB", Vector3(cx, 0.28, -13.6), Vector3(7.4, 0.24, 0.06), "wood")
	var lamp_pos := Vector3(cx - 0.2, 2.6, -10.4)
	CityGeo.tube(root, Vector3(cx - 0.2, 3.2, -10.4), lamp_pos + Vector3(0, 0.2, 0), 0.012, "trim_dark")
	CityGeo.cylinder(root, "LampShade", lamp_pos + Vector3(0, 0.12, 0), 0.26, 0.18, "brass", Vector3.ZERO, false, 16, 0.09)
	CityGeo.sphere(root, "LampBulb", lamp_pos, 0.09, "lamp_glow")
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.79, 0.56)
	light.light_energy = 1.75
	light.omni_range = 7.5
	light.position = lamp_pos + Vector3(0, -0.05, 0)
	light.shadow_enabled = false
	light.name = "ShopLight"
	root.add_child(light)
	CityGeo.own(light)


static func _counter(root: Node, cx: float, z: float, width: float, key: String = "counter_wood") -> void:
	CityGeo.box(root, "CounterBody", Vector3(cx, 0.66, z), Vector3(width, 1.0, 0.66), "wood", Vector3.ZERO, true)
	CityGeo.box(root, "CounterTop", Vector3(cx, 1.18, z), Vector3(width + 0.12, 0.07, 0.8), key)
	CityGeo.box(root, "CounterKick", Vector3(cx, 0.14, z + 0.3), Vector3(width - 0.1, 0.12, 0.06), "trim_dark")


static func _register(root: Node, pos: Vector3) -> void:
	CityGeo.box(root, "Register", pos, Vector3(0.42, 0.28, 0.36), "metal_dark")
	CityGeo.box(root, "RegisterTop", pos + Vector3(0, 0.18, -0.05), Vector3(0.36, 0.12, 0.08), "metal", Vector3(-18, 0, 0))
	CityGeo.label3d(root, "$", pos + Vector3(0, 0.23, 0.14), 0.07, Color(0.7, 0.9, 0.7), Vector3.ZERO, "display")


static func _ferreteria(root: Node, cx: float, pal: Dictionary) -> void:
	var z_back := -13.5
	CityGeo.box(root, "ShelfBack", Vector3(cx - 0.9, 1.25, z_back), Vector3(4.2, 2.3, 0.38), "wood", Vector3.ZERO, true)
	for i in 4:
		CityGeo.box(root, "ShelfBoard", Vector3(cx - 0.9, 0.4 + float(i) * 0.55, z_back + 0.26), Vector3(4.2, 0.05, 0.5), "wood_light")
	var box_colors := ["plastic_red", "metal", "awning_green", "white", "brass"]
	for i in 14:
		var row := i / 5
		var col := i % 5
		var key: String = box_colors[(i + row) % box_colors.size()]
		CityGeo.box(root, "Goods", Vector3(cx - 2.7 + float(col) * 0.8, 0.58 + float(row) * 0.55, z_back + 0.33), Vector3(0.38, 0.28, 0.28), key)
	CityGeo.box(root, "Pegboard", Vector3(cx - 3.63, 1.75, -10.2), Vector3(0.06, 1.5, 2.5), "wood_light")
	for i in 5:
		CityGeo.box(root, "Tool", Vector3(cx - 3.56, 1.3 + float(i % 3) * 0.38, -11.1 + float(i) * 0.45), Vector3(0.05, 0.36, 0.08), "metal", Vector3(0, 0, 18))
	CityGeo.torus(root, "CableCoil", Vector3(cx - 3.5, 1.65, -8.9), 0.28, 0.18, "metal_dark", Vector3(0, 0, 0))
	_counter(root, cx - 0.7, -11.85, 3.3)
	_register(root, Vector3(cx + 0.35, 1.36, -11.8))
	for i in 4:
		CityGeo.cylinder(root, "PaintCan", Vector3(cx + 3.05, 0.34, -10.8 - float(i) * 0.34), 0.18, 0.36, ["plastic_green", "white", "plastic_red", "metal"][i], Vector3.ZERO, false, 14)
		CityGeo.cylinder(root, "PaintLid", Vector3(cx + 3.05, 0.54, -10.8 - float(i) * 0.34), 0.185, 0.045, "metal", Vector3.ZERO, false, 14)
	CityGeo.tube(root, Vector3(cx + 3.45, 0.16, -9.2), Vector3(cx + 2.85, 2.5, -9.55), 0.035, "wood_light")
	for i in 5:
		CityGeo.tube(root, Vector3(cx + 3.4, 0.45 + float(i) * 0.4, -9.25), Vector3(cx + 2.9, 0.45 + float(i) * 0.4, -9.55), 0.028, "wood_light")
	CityGeo.box(root, "BinA", Vector3(cx - 3.0, 0.35, -8.15), Vector3(0.55, 0.38, 0.45), "plastic_green")
	CityGeo.box(root, "BinB", Vector3(cx - 2.35, 0.35, -8.15), Vector3(0.55, 0.38, 0.45), "plastic_red")
	CityGeo.box(root, "Workbench", Vector3(cx + 2.7, 0.55, -10.6), Vector3(1.5, 0.9, 0.75), "wood", Vector3.ZERO, true)
	CityGeo.box(root, "WorkTop", Vector3(cx + 2.7, 1.02, -10.6), Vector3(1.62, 0.07, 0.85), "wood_light")
	CityGeo.box(root, "Vise", Vector3(cx + 2.75, 1.14, -10.35), Vector3(0.28, 0.18, 0.22), "metal")
	CityGeo.box(root, "ToolBox", Vector3(cx + 2.55, 1.28, -10.85), Vector3(0.6, 0.3, 0.3), "plastic_red")
	for i in 3:
		CityGeo.cylinder(root, "BoltBin", Vector3(cx + 3.2, 1.05 + float(i) * 0.0, -10.2 + float(i) * 0.28), 0.11, 0.16, ["metal", "brass", "metal_dark"][i], Vector3.ZERO, false, 10)
	CityGeo.label3d(root, "TODO PARA LA CASA", Vector3(cx - 0.9, 2.1, -13.44), 0.18, Color(0.9, 0.82, 0.64), Vector3.ZERO, "display")
	CityGeo.label3d(root, "TORNILLOS · BISAGRAS · PINTURA", Vector3(cx - 0.9, 1.92, -13.43), 0.075, Color(0.78, 0.7, 0.55), Vector3.ZERO, "body")


static func _papeleria(root: Node, cx: float, pal: Dictionary) -> void:
	var z_back := -13.5
	CityGeo.box(root, "ShelfBack", Vector3(cx - 0.2, 1.3, z_back), Vector3(5.0, 2.4, 0.36), "wood", Vector3.ZERO, true)
	for i in 4:
		CityGeo.box(root, "ShelfBoard", Vector3(cx - 0.2, 0.35 + float(i) * 0.58, z_back + 0.25), Vector3(5.0, 0.05, 0.48), "wood_light")
	var paper_colors := ["paper_blue", "paper_rose", "paper_white", "fabric_yellow"]
	for i in 16:
		var row := i / 4
		var col := i % 4
		var key: String = paper_colors[(row + col) % paper_colors.size()]
		CityGeo.box(root, "Ream", Vector3(cx - 2.4 + float(col) * 0.7, 0.48 + float(row) * 0.58, z_back + 0.3), Vector3(0.5, 0.16, 0.34), key)
	CityGeo.box(root, "PosterWall", Vector3(cx - 3.63, 1.8, -10.1), Vector3(0.06, 1.8, 2.3), "paper_white")
	for i in 6:
		var key: String = paper_colors[i % paper_colors.size()]
		CityGeo.box(root, "Poster", Vector3(cx - 3.57, 1.35 + float(i % 2) * 0.75, -10.95 + float(i / 2) * 0.65), Vector3(0.03, 0.5, 0.42), key, Vector3(0, 0, 3 * float(i % 3) - 3))
		CityGeo.box(root, "PosterInner", Vector3(cx - 3.55, 1.35 + float(i % 2) * 0.75, -10.95 + float(i / 2) * 0.65), Vector3(0.02, 0.3, 0.26), "trim_dark")
	_counter(root, cx - 0.5, -11.85, 3.2)
	CityGeo.box(root, "Printer", Vector3(cx - 1.0, 1.38, -11.8), Vector3(0.75, 0.36, 0.55), "white")
	CityGeo.box(root, "PrinterSlot", Vector3(cx - 1.0, 1.2, -11.52), Vector3(0.42, 0.03, 0.08), "trim_dark")
	CityGeo.box(root, "PrinterPaper", Vector3(cx - 1.0, 1.56, -11.76), Vector3(0.5, 0.06, 0.36), "paper_white")
	_register(root, Vector3(cx + 0.7, 1.36, -11.8))
	CityGeo.cylinder(root, "PaperRollA", Vector3(cx + 3.1, 0.5, -12.6), 0.16, 0.9, "paper_white", Vector3(90, 0, 0), false, 14)
	CityGeo.cylinder(root, "PaperRollB", Vector3(cx + 3.1, 0.5, -12.2), 0.13, 0.85, "paper_blue", Vector3(90, 0, 0), false, 14)
	for i in 3:
		CityGeo.box(root, "DisplayPoster", Vector3(cx - 3.0 + float(i) * 0.8, 1.65, -7.95), Vector3(0.55, 0.72, 0.02), paper_colors[(i + 1) % paper_colors.size()], Vector3(0, 0, 2 * float(i) - 2))
	CityGeo.label3d(root, "IMPRESIONES · FOTOCOPIAS", Vector3(cx - 0.2, 2.3, -13.44), 0.14, Color(0.96, 0.9, 0.76), Vector3.ZERO, "display")
	CityGeo.label3d(root, "Papel & Tinta", Vector3(cx - 0.2, 2.08, -13.43), 0.13, Color(0.8, 0.72, 0.58), Vector3.ZERO, "serif_italic")
	CityGeo.plant(root, Vector3(cx + 3.2, 0.16, -8.3), 0.8)


static func _cafeteria(root: Node, cx: float, pal: Dictionary) -> void:
	var z_bar := -12.25
	CityGeo.box(root, "BarBody", Vector3(cx - 0.3, 0.66, z_bar), Vector3(4.6, 1.0, 0.7), "wood", Vector3.ZERO, true)
	CityGeo.box(root, "BarTop", Vector3(cx - 0.3, 1.18, z_bar), Vector3(4.8, 0.08, 0.86), "counter_wood")
	CityGeo.box(root, "BarKick", Vector3(cx - 0.3, 0.15, z_bar + 0.33), Vector3(4.4, 0.14, 0.08), "trim_dark")
	CityGeo.box(root, "Espresso", Vector3(cx - 1.1, 1.4, z_bar - 0.05), Vector3(0.85, 0.42, 0.5), "metal")
	CityGeo.box(root, "EspressoTop", Vector3(cx - 1.1, 1.64, z_bar - 0.05), Vector3(0.75, 0.08, 0.42), "metal_dark")
	for i in 2:
		CityGeo.cylinder(root, "Portafilter", Vector3(cx - 1.35 + float(i) * 0.45, 1.3, z_bar + 0.24), 0.05, 0.16, "metal_dark", Vector3(90, 0, 0), false, 10)
		CityGeo.cylinder(root, "Cup", Vector3(cx - 1.35 + float(i) * 0.45, 1.26, z_bar + 0.42), 0.055, 0.09, "white", Vector3.ZERO, false, 10)
	CityGeo.box(root, "PastryCase", Vector3(cx + 1.2, 1.35, z_bar + 0.02), Vector3(1.3, 0.34, 0.55), "glass_shop")
	CityGeo.box(root, "PastryBase", Vector3(cx + 1.2, 1.2, z_bar + 0.02), Vector3(1.3, 0.05, 0.55), "metal_dark")
	for i in 4:
		CityGeo.box(root, "Pastry", Vector3(cx + 0.75 + float(i) * 0.3, 1.26, z_bar + 0.02), Vector3(0.2, 0.1, 0.18), "wood_light")
	CityGeo.box(root, "BackShelf", Vector3(cx - 0.3, 1.65, -13.55), Vector3(3.8, 1.8, 0.3), "wood")
	for i in 3:
		CityGeo.box(root, "ShelfBoard", Vector3(cx - 0.3, 1.0 + float(i) * 0.55, -13.38), Vector3(3.8, 0.05, 0.4), "wood_light")
	for i in 8:
		CityGeo.cylinder(root, "Jar", Vector3(cx - 1.85 + float(i) * 0.45, 1.2 + float(i % 2) * 0.55, -13.35), 0.07, 0.22, ["white", "brass", "plastic_green", "wood_light"][i % 4], Vector3.ZERO, false, 10)
	CityGeo.table(root, Vector3(cx - 2.35, 0.16, -9.4))
	CityGeo.chair(root, Vector3(cx - 3.0, 0.16, -9.4), 90.0)
	CityGeo.chair(root, Vector3(cx - 1.7, 0.16, -9.4), -90.0)
	CityGeo.table(root, Vector3(cx + 2.75, 0.16, -10.6), "wood")
	CityGeo.chair(root, Vector3(cx + 2.75, 0.16, -11.35), 0.0)
	CityGeo.chair(root, Vector3(cx + 2.75, 0.16, -9.85), 180.0)
	CityGeo.box(root, "Chalkboard", Vector3(cx + 3.62, 1.72, -11.0), Vector3(0.05, 1.5, 1.0), "chalk")
	CityGeo.label3d(root, "MENÚ", Vector3(cx + 3.56, 2.24, -11.0), 0.13, Color(0.94, 0.88, 0.7), Vector3(0, -90, 0), "chalk")
	CityGeo.label3d(root, "TINTO  2.000\nAROMÁTICA  2.500\nEMPANADA  3.000", Vector3(cx + 3.56, 1.72, -11.0), 0.085, Color(0.9, 0.85, 0.68), Vector3(0, -90, 0), "chalk")
	CityGeo.box(root, "WindowBar", Vector3(cx - 2.0, 1.0, -8.05), Vector3(2.8, 0.07, 0.34), "wood_light")
	for i in 3:
		CityGeo.cylinder(root, "StoolSeat", Vector3(cx - 3.0 + float(i) * 1.0, 0.63, -8.3), 0.19, 0.07, "fabric_red", Vector3.ZERO, false, 14)
		CityGeo.cylinder(root, "StoolLeg", Vector3(cx - 3.0 + float(i) * 1.0, 0.3, -8.3), 0.035, 0.6, "metal_dark", Vector3.ZERO, false, 8)
	CityGeo.plant(root, Vector3(cx - 3.4, 0.16, -8.3), 0.85)
	CityGeo.plant(root, Vector3(cx + 3.35, 0.16, -8.0), 0.7)
	for i in 2:
		var bulb := Vector3(cx - 2.3 + float(i) * 2.6, 2.35, -9.45)
		CityGeo.tube(root, bulb + Vector3(0, 0.85, 0), bulb, 0.01, "metal_dark")
		CityGeo.sphere(root, "Bulb", bulb, 0.075, "lamp_glow")
		var light := OmniLight3D.new()
		light.light_color = Color(1.0, 0.7, 0.4)
		light.light_energy = 1.6
		light.omni_range = 5.0
		light.position = bulb
		light.shadow_enabled = false
		root.add_child(light)
		CityGeo.own(light)
	CityGeo.label3d(root, "Café La Esquina", Vector3(cx - 0.3, 2.35, -13.44), 0.26, Color(0.96, 0.88, 0.7), Vector3.ZERO, "serif_italic")
	CityGeo.label3d(root, "tinto de la casa · desde 1994", Vector3(cx - 0.3, 2.08, -13.43), 0.085, Color(0.8, 0.72, 0.58), Vector3.ZERO, "body")


static func _people(root: Node, shop_id: String, cx: float) -> void:
	var owner_model := ""
	var customer_model := ""
	var customer_pos := Vector3(cx - 2.6, 0.16, -9.7)
	var customer_yaw := 90.0
	var customer_height := 1.75
	match shop_id:
		"ferreteria":
			owner_model = MODEL_OWNER_FERRETERIA
			customer_model = MODEL_CUSTOMER_FERRETERIA
			customer_pos = Vector3(cx - 2.65, 0.16, -9.6)
			customer_yaw = 90.0
		"papeleria":
			owner_model = MODEL_OWNER_PAPELERIA
			customer_model = MODEL_CUSTOMER_PAPELERIA
			customer_pos = Vector3(cx + 2.45, 0.16, -9.95)
			customer_yaw = 48.0
		"cafeteria":
			owner_model = MODEL_OWNER_CAFETERIA
			customer_model = MODEL_CUSTOMER_CAFETERIA
			customer_pos = Vector3(cx + 2.75, 0.16, -9.95)
			customer_yaw = 168.0
			customer_height = 1.8
	var owner_pos := Vector3(cx - 0.7, 0.16, -12.75) if shop_id != "cafeteria" else Vector3(cx - 0.5, 0.16, -13.1)
	var owner := CityGeo.person(root, "Owner", owner_model, owner_pos, 180.0, shop_id, "owner", "Idle", 1.0)
	owner.set("target_height", 1.8)
	var customer := CityGeo.person(root, "Customer", customer_model, customer_pos, customer_yaw, shop_id, "customer", "Idle", 1.0)
	customer.set("target_height", customer_height)
	customer.set("yaw_offset", 180.0)


static func _doorways(root: Node, shop_id: String, cx: float) -> void:
	var shop: Dictionary = GameData.SHOPS[shop_id]
	var outside := Node3D.new()
	outside.name = "DoorOutside"
	outside.position = Vector3(cx + 1.9, 0.16, -6.45)
	outside.set_script(load("res://scripts/doorway.gd"))
	outside.set("prompt", "Entrar a " + str(shop["short"]))
	outside.set("to_pos", Vector3(cx + 1.9, 0.18, -9.4))
	outside.set("to_yaw", 0.0)
	outside.set("radius", 2.0)
	root.add_child(outside)
	CityGeo.own(outside)
	var inside := Node3D.new()
	inside.name = "DoorInside"
	inside.position = Vector3(cx + 1.9, 0.16, -8.1)
	inside.set_script(load("res://scripts/doorway.gd"))
	inside.set("prompt", "Salir a la calle")
	inside.set("to_pos", Vector3(cx + 1.9, 0.18, -6.2))
	inside.set("to_yaw", 180.0)
	inside.set("radius", 1.5)
	inside.set("inside", true)
	root.add_child(inside)
	CityGeo.own(inside)

