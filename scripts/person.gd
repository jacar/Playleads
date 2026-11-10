extends Node3D


@export var shop_id: String = ""
@export var who: String = ""
@export var display_name: String = ""
@export var anim_name: String = "Idle"
@export var anim_speed: float = 1.0
@export var walk_speed: float = 0.0
@export var path_points: PackedVector3Array = PackedVector3Array()
@export var talk_radius: float = 2.5
@export var target_height: float = 1.8
@export var yaw_offset: float = 0.0
@export var turn_to_player: bool = true

var _player: Node3D
var _anim: AnimationPlayer
var _world_path: PackedVector3Array = PackedVector3Array()
var _target: int = 1
var _direction: int = 1
var _pause: float = 0.0
var _yaw_base: float = 0.0


func _ready() -> void:
	add_to_group("person")
	_yaw_base = rotation.y
	if shop_id != "":
		add_to_group("talkable")
		if display_name == "":
			var shop: Dictionary = GameData.SHOPS.get(shop_id, {})
			display_name = str(shop.get(who, "Alguien"))
	var model := get_node_or_null("Model")
	if model != null:
		_normalize_model(model)
		_start_anim.call_deferred()
	if walk_speed > 0.0 and path_points.size() > 1:
		add_to_group("walker")
		for point in path_points:
			_world_path.append(global_position + point)
		_target = 1
	_player = get_tree().get_first_node_in_group("player")


func _start_anim() -> void:
	var model := get_node_or_null("Model")
	if model == null:
		return
	_anim = _find_anim(model)
	if _anim == null or _anim.get_animation_list().is_empty():
		return
	var clip := anim_name
	if not _anim.has_animation(clip):
		clip = "Walk" if _anim.has_animation("Walk") else str(_anim.get_animation_list()[0])
	_anim.play(clip)
	_anim.speed_scale = anim_speed


func _process(delta: float) -> void:
	if _anim == null or _anim.get_animation_list().is_empty():
		_start_anim()
	elif _anim.current_animation == "":
		_start_anim()
	if walk_speed <= 0.0 or _world_path.size() < 2:
		if turn_to_player and _player != null and shop_id != "":
			_face_player(delta)
		return
	if _pause > 0.0:
		_pause -= delta
		return
	var goal: Vector3 = _world_path[_target]
	var to_goal := goal - global_position
	to_goal.y = 0.0
	if to_goal.length() < 0.08:
		_pause = 1.2
		_target += _direction
		if _target >= _world_path.size():
			_direction = -1
			_target = _world_path.size() - 2
		elif _target < 0:
			_direction = 1
			_target = 1
		return
	to_goal = to_goal.normalized()
	var new_pos := global_position + to_goal * walk_speed * delta
	global_position = Vector3(new_pos.x, global_position.y, new_pos.z)
	look_at(global_position + to_goal, Vector3.UP)


func get_prompt() -> String:
	var role := ""
	var shop: Dictionary = GameData.SHOPS.get(shop_id, {})
	if who == "owner":
		role = str(shop.get("owner_role", ""))
	elif who == "customer":
		role = str(shop.get("customer_role", ""))
	if role != "":
		return "Hablar con " + display_name + " · " + role
	return "Hablar con " + display_name


func get_speaker_name() -> String:
	return display_name


func interact() -> void:
	var main := get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("open_dialogue"):
		main.open_dialogue(shop_id, who)


func _face_player(delta: float) -> void:
	if _player == null:
		return
	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() < 0.4 or to_player.length() > 5.0:
		return
	var wanted := atan2(-to_player.x, -to_player.z)
	rotation.y = lerp_angle(rotation.y, wanted, clampf(delta * 2.2, 0.0, 1.0))


func _normalize_model(model: Node3D) -> void:
	if yaw_offset != 0.0:
		model.rotation_degrees.y += yaw_offset
	var box := _model_aabb(model)
	if box.size.y < 0.2:
		return
	var factor := target_height / box.size.y
	model.scale = model.scale * factor
	var center := box.get_center()
	model.position.x -= center.x * factor
	model.position.z -= center.z * factor
	model.position.y -= box.position.y * factor


func _model_aabb(model: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var stack: Array = [[model, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var entry: Array = stack.pop_back()
		var node: Node = entry[0]
		var xform: Transform3D = entry[1]
		if node is MeshInstance3D and node.mesh != null:
			var box: AABB = xform * node.get_aabb()
			if first:
				result = box
				first = false
			else:
				result = result.merge(box)
		for child in node.get_children():
			if child is Node3D:
				stack.append([child, xform * child.transform])
	return result


func _find_anim(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_anim(child)
		if found != null:
			return found
	return null



