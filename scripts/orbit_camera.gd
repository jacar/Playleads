extends Node3D


@export var target_path: NodePath
@export var yaw: float = 1.5708
@export var pitch: float = -0.28
@export var distance: float = 5.6
@export var min_distance: float = 2.4
@export var max_distance: float = 10.0
@export var follow_lag: float = 8.0
@export var auto_align_delay: float = 1.4

var _target: Node3D
var _arm: SpringArm3D
var _camera: Camera3D
var _last_drag: float = 0.0
var _dragging: bool = false
var _desired_distance: float = 5.6


func _ready() -> void:
	add_to_group("camera_rig")
	set_process_unhandled_input(true)
	_target = get_node_or_null(target_path) as Node3D
	_arm = get_node_or_null("SpringArm3D") as SpringArm3D
	_camera = get_node_or_null("SpringArm3D/Camera3D") as Camera3D
	if _arm != null:
		_arm.spring_length = distance
		_arm.collision_mask = 1
		_arm.margin = 0.28
	if _camera != null:
		_camera.fov = 60.0
		_camera.near = 0.08
		_camera.far = 180.0
		var attrs := CameraAttributesPractical.new()
		attrs.dof_blur_far_enabled = true
		attrs.dof_blur_far_distance = 26.0
		attrs.dof_blur_far_transition = 20.0
		attrs.dof_blur_amount = 0.045
		_camera.attributes = attrs
	_desired_distance = distance
	snap()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT or mb.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = mb.pressed
			if mb.pressed:
				_last_drag = 0.0
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_desired_distance = clampf(_desired_distance - 0.5, min_distance, max_distance)
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_desired_distance = clampf(_desired_distance + 0.5, min_distance, max_distance)
	elif event is InputEventMouseMotion and _dragging:
		var mm := event as InputEventMouseMotion
		yaw -= mm.relative.x * 0.006
		pitch = clampf(pitch - mm.relative.y * 0.004, -0.95, 0.16)
		_last_drag = 0.0


func _process(delta: float) -> void:
	if _target == null:
		return
	var wanted := _target.global_position + Vector3(0, 1.42, 0)
	global_position = global_position.lerp(wanted, clampf(follow_lag * delta, 0.0, 1.0))
	_last_drag += delta
	if _last_drag > auto_align_delay and _is_target_moving():
		var to_facing := _target.rotation.y
		yaw = lerp_angle(yaw, to_facing, clampf(delta * 0.55, 0.0, 1.0))
	rotation = Vector3(pitch, yaw, 0.0)
	if _arm != null:
		_arm.spring_length = lerpf(_arm.spring_length, _desired_distance, clampf(delta * 6.0, 0.0, 1.0))


func snap() -> void:
	if _target == null:
		return
	global_position = _target.global_position + Vector3(0, 1.42, 0)
	rotation = Vector3(pitch, yaw, 0.0)


func _is_target_moving() -> bool:
	if _target is CharacterBody3D:
		return Vector2(_target.velocity.x, _target.velocity.z).length() > 0.4
	return false

