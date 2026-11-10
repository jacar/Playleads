extends SummerProbeBase


func _first(node: Node, klass: StringName) -> Node:
	if node.is_class(klass):
		return node
	for child in node.get_children():
		var found := _first(child, klass)
		if found != null:
			return found
	return null


func _ready() -> void:
	await super._ready()
	await settle(24)
	var scene := get_tree().current_scene
	report("scene", scene.name if scene != null else "none")
	report("paused", get_tree().paused)
	var player := scene.get_node_or_null("Player")
	var ap := _first(player, &"AnimationPlayer") as AnimationPlayer
	var ui := scene.get_node_or_null("UI")
	report("anim_exists", ap != null)
	if ap != null:
		report("anim_list", ap.get_animation_list())
		report("anim_current", ap.current_animation)
		report("anim_playing", ap.is_playing())
		report("anim_root", ap.root_node)
		report("anim_libs", ap.get_animation_library_list())
	if player != null:
		report("debug", player.debug_state())
	if ui != null:
		report("intro_visible", ui.get("_intro").visible)
		report("intro_alpha", ui.get("_intro").modulate.a)
		report("dialogue_visible", ui.get("_dialogue").visible)
		var prompt := ui.get("_prompt") as Control
		report("prompt_visible", prompt.visible if prompt != null else false)
	await save_frame("state-probe")
	finish()
