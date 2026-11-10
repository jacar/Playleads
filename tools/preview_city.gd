extends SceneTree


func _initialize() -> void:
	var root := Node3D.new()
	root.name = "Preview"
	get_root().add_child(root)
	var gh: PackedScene = load("res://library/lighting/golden-hour/golden_hour.tscn")
	var envi := gh.instantiate()
	root.add_child(envi)
	envi.owner = root
	var sun := envi.get_node_or_null("Sun") as DirectionalLight3D
	if sun != null:
		sun.rotation_degrees = Vector3(-20, -48, 0)
		sun.light_energy = 1.55
		sun.light_color = Color(1.0, 0.72, 0.44)
	var city: PackedScene = load("res://world/city.tscn")
	var city_inst := city.instantiate()
	root.add_child(city_inst)
	city_inst.owner = root
	var cam := Camera3D.new()
	cam.name = "PreviewCamera"
	cam.fov = 60.0
	root.add_child(cam)
	cam.owner = root
	cam.look_at_from_position(Vector3(-29.0, 2.4, 1.0), Vector3(4.0, 2.2, -1.5), Vector3.UP)
	cam.current = true
	var packed := PackedScene.new()
	packed.pack(root)
	print("save: ", ResourceSaver.save(packed, "res://world/preview.tscn"))
	root.free()
	quit()
