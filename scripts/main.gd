extends Node3D


var player: CharacterBody3D
var hud: CanvasLayer
var flow: Node
var _transitioning: bool = false
var _street_audio: AudioStreamPlayer
var _inside_audio: AudioStreamPlayer
var _sfx: AudioStreamPlayer
var _inside_target: float = 1.0
var _ending_shown: bool = false


func _ready() -> void:
	add_to_group("main")
	player = get_node("Player")
	hud = get_node("UI")
	flow = get_node("DialogueFlow")
	flow.setup(self, hud)
	var sun := get_node_or_null("GoldenHour/Sun") as DirectionalLight3D
	if sun != null:
		sun.rotation_degrees = Vector3(-21, -47, 0)
		sun.light_energy = 2.15
		sun.light_color = Color(1.0, 0.72, 0.44)
		sun.directional_shadow_max_distance = 150.0
	var env_node := get_node_or_null("GoldenHour/WorldEnvironment") as WorldEnvironment
	if env_node != null and env_node.environment != null:
		var env := env_node.environment
		env.fog_enabled = true
		env.fog_light_color = Color(0.95, 0.72, 0.51)
		env.fog_density = 0.0062
		env.fog_sky_affect = 0.35
		env.ambient_light_energy = 1.15
		env.adjustment_enabled = true
		env.adjustment_saturation = 1.1
		env.adjustment_contrast = 1.03
		env.glow_intensity = 0.45
		env.glow_bloom = 0.06
	var fill := DirectionalLight3D.new()
	fill.name = "SkyFill"
	fill.rotation_degrees = Vector3(-52, 138, 0)
	fill.light_color = Color(0.55, 0.66, 0.82)
	fill.light_energy = 0.32
	fill.shadow_enabled = false
	add_child(fill)
	GameState.clients_changed.connect(_on_clients_changed)
	GameState.reputation_changed.connect(_on_reputation_changed)
	hud.ending_dismissed.connect(_on_ending_dismissed)
	_on_clients_changed(GameState.clients)
	_on_reputation_changed(GameState.reputation, GameData.rep_title(GameState.reputation))
	_setup_audio()


func _setup_audio() -> void:
	_street_audio = AudioStreamPlayer.new()
	_street_audio.name = "StreetAmbience"
	var street_path := "res://audio/calle_ambiente.wav"
	if not ResourceLoader.exists(street_path):
		street_path = "res://audio/ambience_calle.res"
	if ResourceLoader.exists(street_path):
		_street_audio.stream = load(street_path)
	add_child(_street_audio)
	_inside_audio = AudioStreamPlayer.new()
	_inside_audio.name = "InsideAmbience"
	var inside_path := "res://audio/interior_ambiente.wav"
	if not ResourceLoader.exists(inside_path):
		inside_path = "res://audio/ambience_interior.res"
	if ResourceLoader.exists(inside_path):
		_inside_audio.stream = load(inside_path)
	add_child(_inside_audio)
	_sfx = AudioStreamPlayer.new()
	_sfx.name = "Sfx"
	add_child(_sfx)
	if _street_audio.stream != null:
		_street_audio.volume_db = -8.0
		_street_audio.play()
	if _inside_audio.stream != null:
		_inside_audio.volume_db = -80.0
		_inside_audio.play()


func _process(delta: float) -> void:
	var indoors := _is_indoors()
	var target := 0.0 if indoors else 1.0
	_inside_target = move_toward(_inside_target, target, delta * 1.8)
	if _street_audio != null:
		_street_audio.volume_db = lerpf(-8.0, -24.0, _inside_target)
	if _inside_audio != null:
		_inside_audio.volume_db = lerpf(-26.0, -9.0, _inside_target)
	if not _ending_shown and not _transitioning and GameState.clients.size() >= GameData.GOAL_CLIENTS:
		if not bool(flow.get("active")):
			_begin_ending()


func _begin_ending() -> void:
	_ending_shown = true
	player.controls_enabled = false
	hud.set_prompt("")
	if _sfx != null:
		var stream := load("res://library/sounds/rpg-sound-effects/confirmation_002.ogg")
		if stream != null:
			_sfx.stream = stream
			_sfx.volume_db = -9.0
			_sfx.play()
	hud.show_ending(GameState.clients, GameState.reputation, GameData.rep_title(GameState.reputation))


func _on_ending_dismissed() -> void:
	player.controls_enabled = true


func _is_indoors() -> bool:
	if player == null:
		return false
	if player.global_position.z > -7.7:
		return false
	for cx in [-15.0, 0.0, 15.0]:
		if absf(player.global_position.x - float(cx)) < 4.0:
			return true
	return false


func open_dialogue(shop_id: String, who: String) -> void:
	if _transitioning:
		return
	flow.start(shop_id, who)


func use_door(door: Node) -> void:
	if _transitioning:
		return
	_transitioning = true
	player.controls_enabled = false
	hud.set_prompt("")
	if _sfx != null:
		var stream := load("res://library/sounds/rpg-sound-effects/doorOpen_2.ogg")
		if stream != null:
			_sfx.stream = stream
			_sfx.volume_db = -6.0
			_sfx.play()
	await hud.fade_out(0.24)
	player.teleport(door.get("to_pos"), float(door.get("to_yaw")))
	await get_tree().create_timer(0.12).timeout
	await hud.fade_in(0.34)
	player.controls_enabled = true
	_transitioning = false


func _on_clients_changed(clients: Array) -> void:
	if hud == null:
		return
	hud.set_progress(clients.size(), GameData.GOAL_CLIENTS, GameState.reputation, GameData.rep_title(GameState.reputation))
	hud.set_client_list(clients)


func _on_reputation_changed(reputation: int, title: String) -> void:
	if hud == null:
		return
	hud.set_progress(GameState.clients.size(), GameData.GOAL_CLIENTS, reputation, title)


