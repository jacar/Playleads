extends CharacterBody3D


@export var walk_speed: float = 3.3
@export var run_speed: float = 5.7
@export var acceleration: float = 16.0
@export var deceleration: float = 20.0
@export var turn_speed: float = 12.0
@export var camera_rig_path: NodePath

var controls_enabled: bool = true
var _anim: AnimationPlayer
var _current_clip: String = ""
var _interactable: Node = null
var _scan_timer: float = 0.0
var _anim_names: Array = []


func _ready() -> void:
	add_to_group("player")
	_init_animation.call_deferred()


func _init_animation() -> void:
	_find_animation()
	_play_clip("Idle")


func debug_state() -> Dictionary:
	return {
		"anim_found": _anim != null,
		"anim_names": _anim_names,
		"clip": _current_clip,
	}


func _physics_process(delta: float) -> void:
	if _anim == null or _anim.get_animation_list().is_empty():
		_init_animation()
	elif _anim.current_animation == "" and _current_clip == "":
		_play_clip("Idle")
	var hud := get_tree().get_first_node_in_group("hud")
	var dialogue_active: bool = false
	var flow := get_tree().get_first_node_in_group("dialogue_flow")
	if flow != null:
		dialogue_active = bool(flow.get("active"))
	if not controls_enabled or dialogue_active:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta * 2.0)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta * 2.0)
		velocity.y -= 22.0 * delta * 0.0
		_play_clip("Idle")
		if hud != null and hud.has_method("set_prompt"):
			hud.set_prompt("")
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var rig := get_node_or_null(camera_rig_path)
	var yaw := 0.0
	if rig != null:
		yaw = float(rig.get("yaw"))
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var dir := right * input.x - forward * input.y
	if dir.length() > 1.0:
		dir = dir.normalized()
	var running := Input.is_action_pressed("run")
	var speed := run_speed if running else walk_speed
	var target := dir * speed
	var rate := acceleration if dir.length() > 0.01 else deceleration
	velocity.x = move_toward(velocity.x, target.x, rate * delta)
	velocity.z = move_toward(velocity.z, target.z, rate * delta)
	velocity.y = 0.0
	move_and_slide()
	if dir.length() > 0.02:
		var wanted := atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, wanted, clampf(turn_speed * delta, 0.0, 1.0))
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	if planar_speed < 0.25:
		_play_clip("Idle")
	elif planar_speed < 4.4:
		_play_clip("Walk")
	else:
		_play_clip("Run")
	_update_interaction(delta, hud)
	if hud != null:
		var prompt := ""
		if _interactable != null and _interactable.has_method("get_prompt"):
			prompt = str(_interactable.get_prompt())
		hud.set_prompt(prompt)


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled:
		return
	if event.is_action_pressed("interact") and _interactable != null and _interactable.has_method("interact"):
		_interactable.interact()
		get_viewport().set_input_as_handled()


func _update_interaction(delta: float, hud: Node) -> void:
	_scan_timer -= delta
	if _scan_timer > 0.0:
		return
	_scan_timer = 0.15
	var best: Node = null
	var best_dist := 9999.0
	for node in get_tree().get_nodes_in_group("talkable"):
		var person := node as Node3D
		if person == null:
			continue
		var radius := float(person.get("talk_radius"))
		var dist := global_position.distance_to(person.global_position)
		if dist <= radius and dist < best_dist:
			best = person
			best_dist = dist
	for node in get_tree().get_nodes_in_group("doorway"):
		var door := node as Node3D
		if door == null:
			continue
		var radius := float(door.get("radius"))
		var dist := global_position.distance_to(door.global_position)
		if dist <= radius and dist < best_dist - 0.6:
			best = door
			best_dist = dist
	_interactable = best
	if best != null and best.has_method("get_prompt") and hud != null and hud.has_method("set_prompt_highlight"):
		hud.set_prompt_highlight(best is Node3D and best.is_in_group("talkable"))


func teleport(pos: Vector3, yaw: float) -> void:
	global_position = pos
	rotation.y = yaw
	velocity = Vector3.ZERO
	var rig := get_node_or_null(camera_rig_path)
	if rig != null and rig.has_method("snap"):
		rig.snap()


func _find_animation() -> void:
	var model := get_node_or_null("Model")
	if model == null:
		return
	_anim = _search_anim(model)
	if _anim != null:
		_anim_names = _anim.get_animation_list()


func _search_anim(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _search_anim(child)
		if found != null:
			return found
	return null


func _play_clip(clip: String) -> void:
	if _anim == null or _current_clip == clip:
		return
	if not _anim.has_animation(clip):
		return
	_current_clip = clip
	_anim.play(clip, 0.22)
	_anim.speed_scale = 1.0


