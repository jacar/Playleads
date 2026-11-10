extends Node3D


@export var prompt: String = "Entrar"
@export var to_pos: Vector3 = Vector3.ZERO
@export var to_yaw: float = 0.0
@export var radius: float = 2.2
@export var inside: bool = false


func _ready() -> void:
	add_to_group("doorway")


func get_prompt() -> String:
	return prompt


func interact() -> void:
	var main := get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("use_door"):
		main.use_door(self)
