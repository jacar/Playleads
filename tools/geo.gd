class_name CityGeo
extends RefCounted


static var owner_root: Node
static var _box_mesh: BoxMesh
static var _sphere_mesh: SphereMesh
static var _cyl_cache: Dictionary = {}
static var _shape_cache: Dictionary = {}
static var _fonts: Dictionary = {}


static func setup(root: Node) -> void:
	owner_root = root


static func own(node: Node) -> Node:
	node.owner = owner_root
	return node


static func box(parent: Node, node_name: String, pos: Vector3, size: Vector3, mat_key: String, rot_deg: Vector3 = Vector3.ZERO, solid: bool = false) -> Node3D:
	var holder: Node3D
	if solid:
		var body := StaticBody3D.new()
		holder = body
		parent.add_child(body)
		var mesh := MeshInstance3D.new()
		mesh.mesh = _unit_box()
		mesh.material_override = CityMats.m(mat_key)
		mesh.scale = size
		body.add_child(mesh)
		own(mesh)
		var col := CollisionShape3D.new()
		col.shape = box_shape(size)
		body.add_child(col)
		own(col)
	else:
		var mesh := MeshInstance3D.new()
		mesh.mesh = _unit_box()
		mesh.material_override = CityMats.m(mat_key)
		mesh.scale = size
		parent.add_child(mesh)
		holder = mesh
	holder.name = node_name
	holder.position = pos
	holder.rotation_degrees = rot_deg
	own(holder)
	return holder


static func cylinder(parent: Node, node_name: String, pos: Vector3, radius: float, height: float, mat_key: String, rot_deg: Vector3 = Vector3.ZERO, solid: bool = false, sides: int = 16, top_radius: float = -1.0) -> Node3D:
	var top := radius if top_radius < 0.0 else top_radius
	var holder: Node3D
	if solid:
		var body := StaticBody3D.new()
		holder = body
		parent.add_child(body)
		var mesh := MeshInstance3D.new()
		mesh.mesh = _cyl_mesh(radius, top, height, sides)
		mesh.material_override = CityMats.m(mat_key)
		body.add_child(mesh)
		own(mesh)
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = maxf(radius, top)
		shape.height = height
		col.shape = shape
		body.add_child(col)
		own(col)
	else:
		var mesh := MeshInstance3D.new()
		mesh.mesh = _cyl_mesh(radius, top, height, sides)
		mesh.material_override = CityMats.m(mat_key)
		parent.add_child(mesh)
		holder = mesh
	holder.name = node_name
	holder.position = pos
	holder.rotation_degrees = rot_deg
	own(holder)
	return holder


static func sphere(parent: Node, node_name: String, pos: Vector3, radius: float, mat_key: String, squash: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.mesh = _unit_sphere()
	mesh.material_override = CityMats.m(mat_key)
	mesh.scale = Vector3.ONE * radius * squash
	mesh.position = pos
	mesh.name = node_name
	parent.add_child(mesh)
	own(mesh)
	return mesh


static func torus(parent: Node, node_name: String, pos: Vector3, outer: float, inner: float, mat_key: String, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var t := TorusMesh.new()
	t.outer_radius = outer
	t.inner_radius = inner
	t.rings = 24
	t.ring_segments = 8
	mesh.mesh = t
	mesh.material_override = CityMats.m(mat_key)
	mesh.position = pos
	mesh.rotation_degrees = rot_deg
	mesh.name = node_name
	parent.add_child(mesh)
	own(mesh)
	return mesh


static func tube(parent: Node, a: Vector3, b: Vector3, radius: float, mat_key: String, node_name: String = "Tube") -> MeshInstance3D:
	var dir := b - a
	var length := dir.length()
	var mesh := MeshInstance3D.new()
	mesh.mesh = _cyl_mesh(radius, radius, length, 6)
	mesh.material_override = CityMats.m(mat_key)
	var up := Vector3.UP
	if absf(dir.normalized().dot(up)) > 0.999:
		up = Vector3.RIGHT
	mesh.transform.basis = Basis(Quaternion(Vector3.UP, dir.normalized()))
	mesh.position = (a + b) * 0.5
	mesh.name = node_name
	parent.add_child(mesh)
	own(mesh)
	return mesh


static func cable(parent: Node, a: Vector3, b: Vector3, sag: float, radius: float = 0.018, mat_key: String = "metal_dark", segments: int = 9) -> void:
	var prev := a
	for i in range(1, segments + 1):
		var t := float(i) / float(segments)
		var point := a.lerp(b, t)
		point.y -= sin(t * PI) * sag
		tube(parent, prev, point, radius, mat_key, "Cable")
		prev = point


static func label3d(parent: Node, text: String, pos: Vector3, cap_height: float, color: Color, rot_deg: Vector3 = Vector3.ZERO, font_kind: String = "display", outline: int = 0) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font = font(font_kind)
	label.font_size = 96
	label.pixel_size = cap_height / 69.0
	label.modulate = color
	label.outline_size = outline
	label.outline_modulate = Color(0.06, 0.05, 0.04, 0.9)
	label.shaded = false
	label.render_priority = 1
	label.double_sided = true
	label.position = pos
	label.rotation_degrees = rot_deg
	label.alpha_cut = Label3D.ALPHA_CUT_DISABLED
	parent.add_child(label)
	own(label)
	return label


static func font(kind: String) -> Font:
	if _fonts.has(kind):
		return _fonts[kind]
	var f := SystemFont.new()
	match kind:
		"display":
			f.font_names = PackedStringArray(["Bahnschrift SemiBold", "Bahnschrift", "Arial Narrow", "Arial"])
			f.font_weight = 600
		"serif":
			f.font_names = PackedStringArray(["Georgia", "Times New Roman"])
		"serif_italic":
			f.font_names = PackedStringArray(["Georgia", "Times New Roman"])
			f.font_italic = true
		"chalk":
			f.font_names = PackedStringArray(["Segoe Print", "Comic Sans MS", "Georgia"])
		_:
			f.font_names = PackedStringArray(["Segoe UI", "Arial"])
	_fonts[kind] = f
	return f


static func sign(parent: Node, node_name: String, pos: Vector3, yaw_deg: float, width: float, height: float, board_key: String, text: String, text_color: Color, font_kind: String = "display", cap: float = 0.34) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	box(root, "Board", Vector3.ZERO, Vector3(width, height, 0.08), board_key)
	box(root, "FrameTop", Vector3(0, height * 0.5, 0.01), Vector3(width + 0.08, 0.06, 0.1), "trim_dark")
	box(root, "FrameBottom", Vector3(0, -height * 0.5, 0.01), Vector3(width + 0.08, 0.06, 0.1), "trim_dark")
	label3d(root, text, Vector3(0, 0, 0.06), cap, text_color, Vector3.ZERO, font_kind)
	own(root)
	return root


static func window_unit(parent: Node, node_name: String, pos: Vector3, yaw_deg: float, width: float, height: float, lit: bool = false, shutters: bool = true, sill: bool = true) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	box(root, "Glass", Vector3(0, 0, 0.02), Vector3(width, height, 0.04), "glass_warm" if lit else "glass")
	if sill:
		box(root, "Sill", Vector3(0, -height * 0.5 - 0.05, 0.08), Vector3(width + 0.22, 0.1, 0.24), "trim_cream")
	box(root, "FrameL", Vector3(-width * 0.5, 0, 0.05), Vector3(0.07, height, 0.09), "trim_dark")
	box(root, "FrameR", Vector3(width * 0.5, 0, 0.05), Vector3(0.07, height, 0.09), "trim_dark")
	box(root, "FrameT", Vector3(0, height * 0.5, 0.05), Vector3(width, 0.07, 0.09), "trim_dark")
	box(root, "FrameB", Vector3(0, -height * 0.5, 0.05), Vector3(width, 0.07, 0.09), "trim_dark")
	box(root, "MullionV", Vector3(0, 0, 0.05), Vector3(0.045, height, 0.07), "trim_dark")
	box(root, "MullionH", Vector3(0, height * 0.08, 0.05), Vector3(width, 0.04, 0.07), "trim_dark")
	if shutters:
		box(root, "ShutterL", Vector3(-width * 0.5 - 0.23, 0, 0.07), Vector3(0.4, height, 0.05), "awning_green")
		box(root, "ShutterR", Vector3(width * 0.5 + 0.23, 0, 0.07), Vector3(0.4, height, 0.05), "awning_green")
	own(root)
	return root


static func awning(parent: Node, node_name: String, pos: Vector3, yaw_deg: float, width: float, depth: float, key_a: String, key_b: String, trim_key: String = "awning_cream") -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	var count := 8
	var stripe := width / float(count)
	for i in count:
		var key := key_a if i % 2 == 0 else key_b
		var x := -width * 0.5 + stripe * (float(i) + 0.5)
		box(root, "Stripe%d" % i, Vector3(x, 0, depth * 0.5), Vector3(stripe, 0.035, depth), key, Vector3(-13, 0, 0))
		box(root, "Valance%d" % i, Vector3(x, -0.14, depth - 0.06), Vector3(stripe, 0.24, 0.03), key)
	box(root, "Rail", Vector3(0, 0.09, 0.02), Vector3(width, 0.07, 0.07), trim_key)
	own(root)
	return root


static func balcony(parent: Node, node_name: String, pos: Vector3, yaw_deg: float, width: float, laundry: bool = false) -> Node3D:
	var root := Node3D.new()
	root.name = node_name
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	box(root, "Slab", Vector3(0, 0, 0.45), Vector3(width, 0.18, 1.0), "stucco_cream")
	box(root, "RailTop", Vector3(0, 0.95, 0.95), Vector3(width, 0.06, 0.06), "metal_dark")
	box(root, "RailBottom", Vector3(0, 0.12, 0.95), Vector3(width, 0.05, 0.05), "metal_dark")
	var bars := int(width / 0.3)
	for i in bars:
		var x := -width * 0.5 + 0.15 + float(i) * 0.3
		box(root, "Bar%d" % i, Vector3(x, 0.52, 0.95), Vector3(0.03, 0.86, 0.03), "metal_dark")
	box(root, "SideL", Vector3(-width * 0.5, 0.52, 0.5), Vector3(0.03, 0.86, 0.9), "metal_dark")
	box(root, "SideR", Vector3(width * 0.5, 0.52, 0.5), Vector3(0.03, 0.86, 0.9), "metal_dark")
	if laundry:
		var a := Vector3(-width * 0.45, 1.6, 0.55)
		var b := Vector3(width * 0.45, 1.5, 0.55)
		cable(root, a, b, 0.08, 0.012, "metal_dark")
		var colors := ["fabric_red", "fabric_blue", "fabric_yellow", "fabric_white"]
		for i in 4:
			var t := 0.18 + float(i) * 0.21
			var p := a.lerp(b, t)
			p.y -= 0.55
			box(root, "Cloth%d" % i, p, Vector3(0.52, 0.85, 0.03), colors[i % colors.size()])
	plant(root, Vector3(-width * 0.32, 0.1, 0.6), 1.0)
	own(root)
	return root


static func plant(parent: Node, pos: Vector3, scale_mul: float = 1.0) -> void:
	var pot := cylinder(parent, "Pot", pos + Vector3(0, 0.24 * scale_mul, 0), 0.24 * scale_mul, 0.44 * scale_mul, "terracotta", Vector3.ZERO, false, 12, 0.29 * scale_mul)
	pot.name = "Pot"
	sphere(parent, "BushA", pos + Vector3(0, 0.72 * scale_mul, 0), 0.30 * scale_mul, "leaf", Vector3(1.0, 0.85, 1.0))
	sphere(parent, "BushB", pos + Vector3(0.18 * scale_mul, 0.9 * scale_mul, 0.1 * scale_mul), 0.24 * scale_mul, "leaf_light")
	sphere(parent, "BushC", pos + Vector3(-0.2 * scale_mul, 0.82 * scale_mul, -0.06 * scale_mul), 0.22 * scale_mul, "leaf")
	sphere(parent, "BushD", pos + Vector3(0.02 * scale_mul, 1.02 * scale_mul, -0.12 * scale_mul), 0.18 * scale_mul, "leaf_light")


static func chair(parent: Node, pos: Vector3, yaw_deg: float, key: String = "wood") -> Node3D:
	var root := Node3D.new()
	root.name = "Chair"
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	box(root, "Seat", Vector3(0, 0.45, 0), Vector3(0.44, 0.05, 0.44), key)
	box(root, "Back", Vector3(0, 0.77, -0.19), Vector3(0.42, 0.6, 0.05), key)
	for x in [-0.18, 0.18]:
		for z in [-0.18, 0.18]:
			box(root, "Leg", Vector3(x, 0.22, z), Vector3(0.04, 0.44, 0.04), "trim_dark")
	own(root)
	return root


static func table(parent: Node, pos: Vector3, top_key: String = "wood_light") -> void:
	cylinder(parent, "TableTop", pos + Vector3(0, 0.73, 0), 0.46, 0.05, top_key, Vector3.ZERO, false, 20)
	cylinder(parent, "TablePole", pos + Vector3(0, 0.38, 0), 0.045, 0.7, "metal_dark", Vector3.ZERO, false, 10)
	cylinder(parent, "TableBase", pos + Vector3(0, 0.03, 0), 0.24, 0.06, "metal_dark", Vector3.ZERO, false, 16)


static func crate(parent: Node, pos: Vector3, size: Vector3, key: String = "wood_light") -> void:
	box(parent, "Crate", pos + Vector3(0, size.y * 0.5, 0), size, key)
	box(parent, "CrateEdge", pos + Vector3(0, size.y - 0.02, 0), Vector3(size.x + 0.02, 0.05, size.z + 0.02), "wood")


static func bike(parent: Node, pos: Vector3, yaw_deg: float, frame_key: String = "plastic_red") -> void:
	var root := Node3D.new()
	root.name = "Bicycle"
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	torus(root, "WheelBack", Vector3(-0.55, 0.34, 0), 0.34, 0.31, "metal_dark", Vector3(0, 0, 90))
	torus(root, "WheelFront", Vector3(0.55, 0.34, 0), 0.34, 0.31, "metal_dark", Vector3(0, 0, 90))
	tube(root, Vector3(-0.55, 0.34, 0), Vector3(-0.1, 0.68, 0), 0.025, frame_key)
	tube(root, Vector3(-0.1, 0.68, 0), Vector3(0.35, 0.72, 0), 0.025, frame_key)
	tube(root, Vector3(-0.1, 0.68, 0), Vector3(0.1, 0.34, 0), 0.025, frame_key)
	tube(root, Vector3(0.1, 0.34, 0), Vector3(0.55, 0.34, 0), 0.025, frame_key)
	tube(root, Vector3(0.35, 0.72, 0), Vector3(0.55, 0.34, 0), 0.025, frame_key)
	tube(root, Vector3(0.35, 0.72, 0), Vector3(0.33, 0.98, 0), 0.02, "metal_dark")
	box(root, "Handlebar", Vector3(0.33, 1.0, 0), Vector3(0.06, 0.04, 0.42), "metal_dark")
	box(root, "Seat", Vector3(-0.14, 0.98, 0), Vector3(0.26, 0.06, 0.14), "trim_dark")
	own(root)


static func car(parent: Node, pos: Vector3, yaw_deg: float, key: String = "car_blue") -> void:
	var root := Node3D.new()
	root.name = "Car"
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	box(root, "Body", Vector3(0, 0.58, 0), Vector3(4.1, 0.62, 1.75), key)
	box(root, "Hood", Vector3(1.55, 0.72, 0), Vector3(1.1, 0.3, 1.68), key)
	box(root, "Cabin", Vector3(-0.25, 1.12, 0), Vector3(2.0, 0.52, 1.55), key)
	box(root, "GlassFront", Vector3(0.78, 1.14, 0), Vector3(0.06, 0.42, 1.42), "glass", Vector3(0, 0, -12))
	box(root, "GlassBack", Vector3(-1.3, 1.14, 0), Vector3(0.06, 0.42, 1.42), "glass", Vector3(0, 0, 10))
	box(root, "BumperF", Vector3(2.1, 0.36, 0), Vector3(0.14, 0.16, 1.78), "metal_dark")
	box(root, "BumperB", Vector3(-2.1, 0.36, 0), Vector3(0.14, 0.16, 1.78), "metal_dark")
	for x in [-1.35, 1.3]:
		for z in [-0.86, 0.86]:
			torus(root, "Wheel", Vector3(x, 0.34, z), 0.34, 0.24, "trim_dark", Vector3(90, 0, 0))
	box(root, "Plate", Vector3(-2.12, 0.55, 0), Vector3(0.03, 0.18, 0.42), "white")
	own(root)


static func street_lamp(parent: Node, pos: Vector3, yaw_deg: float) -> void:
	var root := Node3D.new()
	root.name = "StreetLamp"
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	cylinder(root, "Base", Vector3(0, 0.12, 0), 0.16, 0.24, "metal_dark", Vector3.ZERO, false, 12, 0.12)
	cylinder(root, "Pole", Vector3(0, 2.2, 0), 0.075, 4.3, "metal_dark", Vector3.ZERO, false, 10)
	box(root, "Arm", Vector3(0.45, 4.28, 0), Vector3(0.95, 0.06, 0.06), "metal_dark", Vector3(0, 0, -6))
	box(root, "Head", Vector3(0.92, 4.18, 0), Vector3(0.42, 0.1, 0.22), "metal_dark")
	sphere(root, "Bulb", Vector3(0.92, 4.1, 0), 0.1, "lamp_glow", Vector3(1, 0.7, 1))
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.72, 0.42)
	light.light_energy = 1.4
	light.omni_range = 7.0
	light.position = Vector3(0.92, 3.95, 0)
	light.shadow_enabled = false
	light.name = "Glow"
	root.add_child(light)
	own(light)
	own(root)


static func ac_unit(parent: Node, pos: Vector3, yaw_deg: float) -> void:
	var root := Node3D.new()
	root.name = "AC"
	root.position = pos
	root.rotation_degrees.y = yaw_deg
	parent.add_child(root)
	box(root, "Box", Vector3.ZERO, Vector3(0.75, 0.48, 0.34), "white")
	for i in 3:
		box(root, "Vent", Vector3(0, -0.12 + float(i) * 0.12, 0.18), Vector3(0.62, 0.035, 0.02), "trim_dark")
	box(root, "Bracket", Vector3(0, -0.34, -0.05), Vector3(0.6, 0.06, 0.28), "metal_dark")
	own(root)


static func roof_tank(parent: Node, pos: Vector3) -> void:
	cylinder(parent, "Tank", pos + Vector3(0, 0.85, 0), 0.65, 1.3, "white", Vector3.ZERO, false, 14)
	cylinder(parent, "TankTop", pos + Vector3(0, 1.52, 0), 0.68, 0.08, "metal", Vector3.ZERO, false, 14)
	box(parent, "TankBase", pos + Vector3(0, 0.2, 0), Vector3(1.1, 0.4, 1.1), "metal_dark")
	cylinder(parent, "TankPipe", pos + Vector3(0.5, 0.45, 0), 0.045, 0.9, "metal", Vector3.ZERO, false, 8)


static func person(parent: Node, node_name: String, scene_path: String, pos: Vector3, yaw_deg: float, shop_id: String = "", who: String = "", anim: String = "Idle", anim_speed: float = 1.0, walk_speed: float = 0.0, path_points: PackedVector3Array = PackedVector3Array()) -> Node3D:
	var wrapper := Node3D.new()
	wrapper.name = node_name
	wrapper.position = pos
	wrapper.rotation_degrees.y = yaw_deg
	wrapper.set_script(load("res://scripts/person.gd"))
	parent.add_child(wrapper)
	var packed: PackedScene = load(scene_path)
	if packed != null:
		var model := packed.instantiate()
		model.name = "Model"
		wrapper.add_child(model)
		own(model)
	wrapper.set("shop_id", shop_id)
	wrapper.set("who", who)
	wrapper.set("anim_name", anim)
	wrapper.set("anim_speed", anim_speed)
	wrapper.set("walk_speed", walk_speed)
	wrapper.set("path_points", path_points)
	own(wrapper)
	return wrapper


static func _unit_box() -> BoxMesh:
	if _box_mesh == null:
		_box_mesh = BoxMesh.new()
		_box_mesh.size = Vector3.ONE
	return _box_mesh


static func _unit_sphere() -> SphereMesh:
	if _sphere_mesh == null:
		_sphere_mesh = SphereMesh.new()
		_sphere_mesh.radius = 1.0
		_sphere_mesh.height = 2.0
		_sphere_mesh.radial_segments = 18
		_sphere_mesh.rings = 9
	return _sphere_mesh


static func _cyl_mesh(radius: float, top: float, height: float, sides: int) -> CylinderMesh:
	var key := "%.3f_%.3f_%.3f_%d" % [radius, top, height, sides]
	if _cyl_cache.has(key):
		return _cyl_cache[key]
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = radius
	mesh.top_radius = top
	mesh.height = height
	mesh.radial_segments = sides
	mesh.rings = 1
	_cyl_cache[key] = mesh
	return mesh


static func box_shape(size: Vector3) -> BoxShape3D:
	var key := "%.3f_%.3f_%.3f" % [size.x, size.y, size.z]
	if _shape_cache.has(key):
		return _shape_cache[key]
	var shape := BoxShape3D.new()
	shape.size = size
	_shape_cache[key] = shape
	return shape

