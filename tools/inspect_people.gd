extends SceneTree


func _initialize() -> void:
	var paths := [
		"res://art/people/2895f962-5d8e-430d-bd2e-f68a47ba36e9/character.tscn",
		"res://art/people/741de2f9-18ec-43c9-888b-907035ad0223/character.tscn",
		"res://art/people/66cdf83d-7f66-413a-afa2-974ce85ab2da/character.tscn",
		"res://art/people/32650f14-c4a5-40c7-9ac8-d9fcfe93c180/character.tscn",
		"res://art/people/3840e192-5d0d-4a12-8d72-c3add8d6e789/character.tscn",
		"res://art/people/2efdeeb8-2874-4697-b833-43f443097048/character.tscn",
		"res://art/people/1de1a862-55b7-4f93-8be8-c9654818b95c/3d_1de1a86255b74f938be8c965_1794186194798.glb",
		"res://art/people/e75521b6-3cde-46d8-8a3c-dd1747140890/3d_e75521b63cde46d88a3cdd17_1790011510637.glb",
	]
	for path in paths:
		print("")
		print("=== ", path, " ===")
		var packed: PackedScene = load(path)
		if packed == null:
			print("  FAILED TO LOAD")
			continue
		var inst: Node = packed.instantiate()
		get_root().add_child(inst)
		var aabb := _aabb(inst)
		print("  AABB: pos=", aabb.position, " size=", aabb.size)
		for ap in _find_all(inst, "AnimationPlayer"):
			print("  ANIMS: ", ap.get_animation_list())
			for anim_name in ap.get_animation_list():
				var anim: Animation = ap.get_animation(anim_name)
				print("    ", anim_name, " len=", anim.length)
		for skel in _find_all(inst, "Skeleton3D"):
			print("  BONES: ", skel.get_bone_count())
		inst.queue_free()
	quit()


func _find_all(node: Node, cls: String) -> Array:
	var result := []
	if node.is_class(cls):
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_all(child, cls))
	return result


func _aabb(root_node: Node) -> AABB:
	var result := AABB()
	var first := true
	for mesh in _find_all(root_node, "MeshInstance3D"):
		if mesh.mesh == null:
			continue
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		if first:
			result = box
			first = false
		else:
			result = result.merge(box)
	return result

