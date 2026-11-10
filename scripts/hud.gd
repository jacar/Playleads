extends CanvasLayer


signal choice_chosen(index: int)
signal dialogue_cancelled
signal ending_dismissed

const INK := Color(0.16, 0.13, 0.10)
const CREAM := Color(0.96, 0.92, 0.83)
const CREAM_WARM := Color(0.97, 0.91, 0.80)
const TERRA := Color(0.72, 0.33, 0.19)
const OCHRE := Color(0.85, 0.62, 0.25)
const DIM := Color(0.42, 0.35, 0.28)
const DARK := Color(0.08, 0.065, 0.05)

var font_body: SystemFont
var font_display: SystemFont
var font_serif: SystemFont

var _root: Control
var _vignette: ColorRect
var _fade: ColorRect
var _intro: Control
var _intro_time: float = 0.0
var _card: PanelContainer
var _count_label: Label
var _rep_bar: ProgressBar
var _rep_title: Label
var _goal_label: Label
var _client_panel: PanelContainer
var _client_list: VBoxContainer
var _toast_box: VBoxContainer
var _prompt: PanelContainer
var _prompt_label: Label
var _prompt_row: HBoxContainer

var _dialogue: PanelContainer
var _speaker_label: Label
var _role_label: Label
var _shop_label: Label
var _body: RichTextLabel
var _options_box: VBoxContainer
var _hint: Label
var _type_speed: float = 48.0
var _revealed: float = 0.0
var _full_text: String = ""
var _typing: bool = false
var _option_buttons: Array = []
var _options_ready: bool = false
var _dialogue_open: bool = false
var _prompt_visible: bool = false
var _ending: Control
var _ending_open: bool = false
var _ending_ready: bool = false
var _ending_count: Label
var _ending_rep: Label
var _ending_list: VBoxContainer


func _ready() -> void:
	add_to_group("hud")
	layer = 10
	font_body = SystemFont.new()
	font_body.font_names = PackedStringArray(["Segoe UI", "Arial"])
	font_display = SystemFont.new()
	font_display.font_names = PackedStringArray(["Bahnschrift SemiBold", "Bahnschrift", "Arial Narrow", "Arial"])
	font_display.font_weight = 600
	font_serif = SystemFont.new()
	font_serif.font_names = PackedStringArray(["Georgia", "Times New Roman"])
	font_serif.font_italic = true
	_build()


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_vignette = ColorRect.new()
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform vec4 tint_color : source_color = vec4(0.075, 0.05, 0.03, 1.0);
void fragment() {
	vec2 uv = UV;
	float d = distance(uv, vec2(0.5, 0.5));
	float vig = smoothstep(0.34, 0.88, d);
	float grain = fract(sin(dot(uv * vec2(1280.0, 720.0) + vec2(TIME * 41.0), vec2(12.9898, 78.233))) * 43758.5453);
	COLOR = vec4(tint_color.rgb + vec3((grain - 0.5) * 0.05), vig * 0.34);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	_vignette.material = mat
	_root.add_child(_vignette)

	_build_top_left()
	_toast_box = VBoxContainer.new()
	_toast_box.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast_box.position = Vector2(-240, 84)
	_toast_box.custom_minimum_size = Vector2(480, 0)
	_toast_box.add_theme_constant_override("separation", 8)
	_toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_toast_box)

	_prompt = PanelContainer.new()
	_prompt.add_theme_stylebox_override("panel", _box(Color(0.09, 0.07, 0.055, 0.86), 24, 18, Color(0.95, 0.84, 0.65, 0.35), 1))
	_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.position = Vector2(-180, -108)
	_prompt.custom_minimum_size = Vector2(360, 48)
	_prompt.visible = false
	_root.add_child(_prompt)
	_prompt_row = HBoxContainer.new()
	_prompt_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_prompt_row.add_theme_constant_override("separation", 12)
	_prompt.add_child(_prompt_row)
	var key := PanelContainer.new()
	key.add_theme_stylebox_override("panel", _box(CREAM, 6, 6, Color(0.2, 0.16, 0.12, 0.4), 1))
	key.custom_minimum_size = Vector2(28, 28)
	_prompt_row.add_child(key)
	var key_label := _label("E", 15, INK, "display")
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	key.add_child(key_label)
	_prompt_label = _label("", 15, CREAM, "body")
	_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_row.add_child(_prompt_label)

	_build_dialogue()
	_build_intro()

	_fade = ColorRect.new()
	_fade.color = Color(0.03, 0.02, 0.015, 1.0)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	_fade.visible = false
	_root.add_child(_fade)


func _build_top_left() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.offset_left = 26
	margin.offset_top = 22
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	margin.add_child(col)
	var title_card := PanelContainer.new()
	title_card.add_theme_stylebox_override("panel", _box(Color(0.06, 0.05, 0.04, 0.55), 10, 12, Color(0.9, 0.75, 0.52, 0.16), 1))
	col.add_child(title_card)
	var title_col := VBoxContainer.new()
	title_col.add_theme_constant_override("separation", 3)
	title_card.add_child(title_col)
	var title := _label("CIUDAD VIVA", 26, CREAM, "display")
	title.add_theme_constant_override("outline_size", 0)
	title_col.add_child(title)
	var line := ColorRect.new()
	line.color = OCHRE
	line.custom_minimum_size = Vector2(46, 2)
	line.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	title_col.add_child(line)
	var sub := _label("CALLE 27  ·  6:40 P.M.", 11, Color(CREAM.r, CREAM.g, CREAM.b, 0.68), "display")
	title_col.add_child(sub)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	col.add_child(spacer)

	_card = PanelContainer.new()
	_card.add_theme_stylebox_override("panel", _box(Color(0.07, 0.055, 0.045, 0.78), 11, 14, Color(0.9, 0.75, 0.52, 0.22), 1))
	_card.custom_minimum_size = Vector2(308, 0)
	col.add_child(_card)
	var card_col := VBoxContainer.new()
	card_col.add_theme_constant_override("separation", 7)
	_card.add_child(card_col)
	var row := HBoxContainer.new()
	card_col.add_child(row)
	var kicker := _label("CLIENTELA", 11, Color(CREAM.r, CREAM.g, CREAM.b, 0.65), "display")
	kicker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(kicker)
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)
	_count_label = _label("0 / 5", 24, OCHRE, "display")
	row.add_child(_count_label)
	_rep_bar = ProgressBar.new()
	_rep_bar.show_percentage = false
	_rep_bar.custom_minimum_size = Vector2(0, 5)
	_rep_bar.max_value = 100.0
	_rep_bar.value = 0.0
	_rep_bar.add_theme_stylebox_override("background", _box(Color(1, 1, 1, 0.13), 3, 0, Color.TRANSPARENT, 0))
	_rep_bar.add_theme_stylebox_override("fill", _box(OCHRE, 3, 0, Color.TRANSPARENT, 0))
	card_col.add_child(_rep_bar)
	var rep_row := HBoxContainer.new()
	card_col.add_child(rep_row)
	var rep_label := _label("Reputación del barrio", 10, Color(CREAM.r, CREAM.g, CREAM.b, 0.58), "body")
	rep_row.add_child(rep_label)
	var pad2 := Control.new()
	pad2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rep_row.add_child(pad2)
	_rep_title = _label("Recién llegado", 10, Color(CREAM.r, CREAM.g, CREAM.b, 0.82), "display")
	rep_row.add_child(_rep_title)
	var divider := ColorRect.new()
	divider.color = Color(1, 1, 1, 0.10)
	divider.custom_minimum_size = Vector2(0, 1)
	card_col.add_child(divider)
	_goal_label = _label("Objetivo · consigue 5 clientes", 10, Color(CREAM.r, CREAM.g, CREAM.b, 0.72), "body")
	card_col.add_child(_goal_label)

	_client_panel = PanelContainer.new()
	_client_panel.add_theme_stylebox_override("panel", _box(Color(0.07, 0.055, 0.045, 0.62), 10, 12, Color(0.9, 0.75, 0.52, 0.16), 1))
	_client_panel.visible = false
	col.add_child(_client_panel)
	var ccol := VBoxContainer.new()
	ccol.add_theme_constant_override("separation", 4)
	_client_panel.add_child(ccol)
	var clabel := _label("TU CLIENTELA", 9, Color(OCHRE.r, OCHRE.g, OCHRE.b, 0.85), "display")
	ccol.add_child(clabel)
	_client_list = VBoxContainer.new()
	_client_list.add_theme_constant_override("separation", 2)
	ccol.add_child(_client_list)


func _build_dialogue() -> void:
	_dialogue = PanelContainer.new()
	_dialogue.add_theme_stylebox_override("panel", _box(CREAM_WARM, 12, 22, Color(0.25, 0.17, 0.10, 0.35), 0))
	_dialogue.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_dialogue.position = Vector2(-380, -300)
	_dialogue.custom_minimum_size = Vector2(760, 0)
	_dialogue.visible = false
	_root.add_child(_dialogue)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	_dialogue.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	_speaker_label = _label("", 19, TERRA, "display")
	head.add_child(_speaker_label)
	_role_label = _label("", 11, DIM, "body")
	_role_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(_role_label)
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(pad)
	_shop_label = _label("", 10, Color(DIM.r, DIM.g, DIM.b, 0.8), "display")
	head.add_child(_shop_label)
	var divider := ColorRect.new()
	divider.color = Color(0.25, 0.17, 0.10, 0.18)
	divider.custom_minimum_size = Vector2(0, 1)
	box.add_child(divider)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = false
	_body.fit_content = false
	_body.scroll_active = false
	_body.custom_minimum_size = Vector2(0, 74)
	_body.add_theme_font_override("normal_font", font_body)
	_body.add_theme_font_size_override("normal_font_size", 17)
	_body.add_theme_color_override("default_color", INK)
	_body.add_theme_constant_override("line_separation", 4)
	box.add_child(_body)
	_options_box = VBoxContainer.new()
	_options_box.add_theme_constant_override("separation", 4)
	box.add_child(_options_box)
	_hint = _label("1-3 elegir  ·  espacio completar  ·  esc salir", 10, Color(DIM.r, DIM.g, DIM.b, 0.72), "body")
	box.add_child(_hint)
	_dialogue.gui_input.connect(_on_dialogue_input)


func _build_intro() -> void:
	_intro = Control.new()
	_intro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_intro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_intro)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.04, 0.03, 0.58)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro.add_child(center)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 8)
	center.add_child(col)
	var kicker := _label("UN BARRIO QUE NO ESPERA", 12, OCHRE, "display")
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(kicker)
	var title := _label("Ciudad Viva", 76, CREAM, "serif")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var line := ColorRect.new()
	line.color = Color(OCHRE.r, OCHRE.g, OCHRE.b, 0.75)
	line.custom_minimum_size = Vector2(90, 2)
	line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(line)
	var sub := _label("Conoce el barrio. Haz que tu nombre circule.", 17, Color(CREAM.r, CREAM.g, CREAM.b, 0.9), "body")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sub)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 18)
	col.add_child(gap)
	var controls := HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 10)
	col.add_child(controls)
	controls.add_child(_pill("WASD / flechas  ·  caminar"))
	controls.add_child(_pill("ratón  ·  cámara"))
	controls.add_child(_pill("E  ·  hablar y entrar"))
	var start := _label("camina y saluda", 11, Color(CREAM.r, CREAM.g, CREAM.b, 0.55), "display")
	start.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(start)
	_intro_time = 0.0


func _pill(text: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _box(Color(0.08, 0.06, 0.05, 0.72), 16, 12, Color(0.9, 0.8, 0.62, 0.22), 1))
	var l := _label(text, 11, Color(CREAM.r, CREAM.g, CREAM.b, 0.86), "body")
	p.add_child(l)
	return p


func _dismiss_intro() -> void:
	if _intro == null or not _intro.visible:
		return
	var tw := create_tween()
	tw.tween_property(_intro, "modulate:a", 0.0, 0.8)
	tw.tween_callback(func(): _intro.visible = false)


func _input(event: InputEvent) -> void:
	if _intro != null and _intro.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			_dismiss_intro()
	if _ending_open:
		_ending_input(event)
		return
	if not _dialogue_open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE:
			dialogue_cancelled.emit()
			get_viewport().set_input_as_handled()
			return
		if _typing and (key.keycode == KEY_SPACE or key.keycode == KEY_ENTER):
			_complete_typing()
			get_viewport().set_input_as_handled()
			return
		if _options_ready:
			var index := -1
			if key.keycode >= KEY_1 and key.keycode <= KEY_9:
				index = int(key.keycode - KEY_1)
			if index >= 0 and index < _option_buttons.size():
				_choose(index)
				get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _intro != null and _intro.visible:
		_intro_time += delta
		if _intro_time > 6.5:
			_dismiss_intro()
	if _typing:
		_revealed += _type_speed * delta
		var chars := int(_revealed)
		if chars >= _full_text.length():
			_complete_typing()
		else:
			_body.visible_characters = chars


func show_dialogue(speaker: String, role: String, shop_name: String, text: String, options: Array) -> void:
	_dialogue_open = true
	_dialogue.visible = true
	_prompt.visible = false
	_prompt_visible = false
	set_prompt("")
	_speaker_label.text = speaker.to_upper()
	_role_label.text = "· " + role
	_shop_label.text = shop_name.to_upper()
	_set_body(text)
	_set_options(options)


func update_dialogue(text: String, options: Array) -> void:
	_set_body(text)
	_set_options(options)


func _set_body(text: String) -> void:
	_full_text = text
	_revealed = 0.0
	_typing = true
	_body.text = text
	_body.visible_characters = 0
	_clear_options()
	_options_ready = false


func _set_options(options: Array) -> void:
	_clear_options()
	_pending_options = options


var _pending_options: Array = []


func _clear_options() -> void:
	_option_buttons.clear()
	_options_ready = false
	for child in _options_box.get_children():
		child.queue_free()


func _complete_typing() -> void:
	_typing = false
	_body.visible_characters = -1
	_show_options()


func _show_options() -> void:
	if _options_ready:
		return
	_options_ready = true
	var idx := 0
	for option in _pending_options:
		var btn := Button.new()
		btn.text = "%d.  %s" % [idx + 1, str(option)]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(0, 30)
		btn.add_theme_font_override("font", font_body)
		btn.add_theme_font_size_override("font_size", 15)
		btn.add_theme_color_override("font_color", Color(0.26, 0.20, 0.15))
		btn.add_theme_color_override("font_hover_color", Color(0.10, 0.08, 0.06))
		btn.add_theme_stylebox_override("normal", _box(Color(1, 1, 1, 0.0), 5, 8, Color(0, 0, 0, 0), 0))
		btn.add_theme_stylebox_override("hover", _box(Color(0.85, 0.76, 0.62, 0.75), 5, 8, Color(0, 0, 0, 0), 0))
		btn.add_theme_stylebox_override("pressed", _box(Color(0.78, 0.67, 0.52, 0.9), 5, 8, Color(0, 0, 0, 0), 0))
		btn.pressed.connect(_choose.bind(idx))
		_options_box.add_child(btn)
		_option_buttons.append(btn)
		idx += 1


func _choose(index: int) -> void:
	if not _dialogue_open:
		return
	choice_chosen.emit(index)


func hide_dialogue() -> void:
	_dialogue_open = false
	_typing = false
	_dialogue.visible = false
	_clear_options()
	_pending_options = []
	_full_text = ""
	_revealed = 0.0


func dialogue_is_open() -> bool:
	return _dialogue_open


func show_ending(clients: Array, reputation: int, title: String) -> void:
	if _ending == null:
		_build_ending()
	if _ending_open:
		return
	_ending_open = true
	_ending_ready = false
	_ending.visible = true
	_ending.modulate.a = 0.0
	_ending_count.text = str(clients.size())
	_ending_rep.text = "%s · %d" % [title, reputation]
	for child in _ending_list.get_children():
		child.queue_free()
	for entry in clients:
		var item: Dictionary = entry
		_ending_list.add_child(_label("· %s — %s" % [str(item.get("name", "")), str(item.get("trade", ""))], 15, Color(0.24, 0.19, 0.14), "body"))
	_dialogue_open = false
	_dialogue.visible = false
	_prompt.visible = false
	_prompt_visible = false
	var tw := create_tween()
	tw.tween_property(_ending, "modulate:a", 1.0, 0.55)
	tw.tween_callback(func(): _ending_ready = true)


func hide_ending() -> void:
	if not _ending_open:
		return
	_ending_open = false
	_ending_ready = false
	var tw := create_tween()
	tw.tween_property(_ending, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): _ending.visible = false)
	ending_dismissed.emit()


func ending_is_open() -> bool:
	return _ending_open


func _ending_input(event: InputEvent) -> void:
	if not _ending_ready:
		return
	var pressed_key := false
	var clicked := false
	if event is InputEventKey:
		var key := event as InputEventKey
		pressed_key = key.pressed and not key.echo
	elif event is InputEventMouseButton:
		clicked = (event as InputEventMouseButton).pressed
	if pressed_key or clicked:
		hide_ending()
		get_viewport().set_input_as_handled()


func _build_ending() -> void:
	_ending = Control.new()
	_ending.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ending.mouse_filter = Control.MOUSE_FILTER_STOP
	_ending.visible = false
	_root.add_child(_ending)
	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.05, 0.035, 0.025, 0.66)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ending.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ending.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _box(CREAM_WARM, 14, 30, Color(0.28, 0.19, 0.12, 0.4), 1))
	card.custom_minimum_size = Vector2(560, 0)
	center.add_child(card)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	card.add_child(col)
	var kicker := _label("PRIMER DÍA EN LA CALLE 27", 11, OCHRE, "display")
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(kicker)
	var title := _label("El barrio ya te conoce", 42, TERRA, "serif")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var divider := ColorRect.new()
	divider.color = Color(0.25, 0.17, 0.10, 0.18)
	divider.custom_minimum_size = Vector2(0, 1)
	col.add_child(divider)
	var stats := HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 26)
	col.add_child(stats)
	var count_col := VBoxContainer.new()
	count_col.add_theme_constant_override("separation", 0)
	stats.add_child(count_col)
	_ending_count = _label("0", 34, OCHRE, "display")
	_ending_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_col.add_child(_ending_count)
	var count_sub := _label("CLIENTES", 9, DIM, "display")
	count_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_col.add_child(count_sub)
	var rep_col := VBoxContainer.new()
	rep_col.add_theme_constant_override("separation", 0)
	stats.add_child(rep_col)
	_ending_rep = _label("", 17, TERRA, "display")
	_ending_rep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ending_rep.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ending_rep.custom_minimum_size = Vector2(0, 34)
	rep_col.add_child(_ending_rep)
	var rep_sub := _label("REPUTACIÓN DEL BARRIO", 9, DIM, "display")
	rep_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rep_col.add_child(rep_sub)
	var divider2 := ColorRect.new()
	divider2.color = Color(0.25, 0.17, 0.10, 0.18)
	divider2.custom_minimum_size = Vector2(0, 1)
	col.add_child(divider2)
	_ending_list = VBoxContainer.new()
	_ending_list.add_theme_constant_override("separation", 3)
	col.add_child(_ending_list)
	var closing := _label("Mañana la cuadra amanece otra vez con afán. Saluda, escucha y deja que te recomienden.", 13, Color(0.32, 0.26, 0.20), "body")
	closing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	closing.custom_minimum_size = Vector2(500, 0)
	col.add_child(closing)
	var hint := _label("cualquier tecla  ·  seguir caminando", 10, Color(DIM.r, DIM.g, DIM.b, 0.8), "body")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)


func set_prompt(text: String) -> void:
	if text == "":
		if _prompt_visible:
			_prompt.visible = false
			_prompt_visible = false
		return
	_prompt_label.text = text
	if not _prompt_visible:
		_prompt.visible = true
		_prompt_visible = true
		_prompt.modulate.a = 0.0
		_prompt.scale = Vector2(0.96, 0.96)
		_prompt.pivot_offset = _prompt.size * 0.5
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(_prompt, "modulate:a", 1.0, 0.18)
		tw.tween_property(_prompt, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_prompt_highlight(is_person: bool) -> void:
	if _prompt_row.get_child_count() > 0:
		var key := _prompt_row.get_child(0) as PanelContainer
		if key != null:
			key.visible = not is_person


func set_progress(clients: int, goal: int, reputation: int, title: String) -> void:
	_count_label.text = "%d / %d" % [clients, goal]
	_rep_bar.value = float(reputation)
	_rep_title.text = title
	if clients >= goal:
		_goal_label.text = "El barrio ya te conoce."
	else:
		_goal_label.text = "Objetivo · consigue %d clientes" % goal


func set_client_list(clients: Array) -> void:
	if clients.is_empty():
		_client_panel.visible = false
		return
	_client_panel.visible = true
	for child in _client_list.get_children():
		child.queue_free()
	var start := maxi(0, clients.size() - 4)
	for i in range(start, clients.size()):
		var entry: Dictionary = clients[i]
		var line := _label("%s · %s" % [str(entry.get("name", "")), str(entry.get("trade", ""))], 10, Color(CREAM.r, CREAM.g, CREAM.b, 0.8), "body")
		_client_list.add_child(line)


func toast(title: String, body: String, accent: Color = OCHRE) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(Color(0.985, 0.95, 0.88, 0.97), 9, 12, Color(0.32, 0.22, 0.14, 0.25), 1))
	panel.custom_minimum_size = Vector2(430, 0)
	panel.modulate.a = 0.0
	_toast_box.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	var bar := ColorRect.new()
	bar.color = accent
	bar.custom_minimum_size = Vector2(3, 0)
	row.add_child(bar)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	row.add_child(col)
	var t := _label(title, 12, TERRA, "display")
	col.add_child(t)
	var b := _label(body, 13, INK, "body")
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size = Vector2(380, 0)
	col.add_child(b)
	panel.position = Vector2(0, -10)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.28)
	tw.tween_property(panel, "position:y", 0.0, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.chain().tween_interval(4.2)
	tw.chain().tween_property(panel, "modulate:a", 0.0, 0.55)
	tw.chain().tween_callback(panel.queue_free)


func fade_out(duration: float = 0.22) -> void:
	_fade.visible = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", 1.0, duration)
	await tw.finished


func fade_in(duration: float = 0.32) -> void:
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", 0.0, duration)
	await tw.finished
	_fade.visible = false
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_dialogue_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and _typing:
		_complete_typing()


func _label(text: String, size: int, color: Color, kind: String = "body") -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font_for(kind))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func font_for(kind: String) -> Font:
	if kind == "display":
		return font_display
	if kind == "serif":
		return font_serif
	return font_body


func _box(bg: Color, radius: int, pad: int, border: Color = Color.TRANSPARENT, border_width: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = pad
	style.content_margin_right = pad
	style.content_margin_top = maxi(pad - 4, 6)
	style.content_margin_bottom = maxi(pad - 4, 6)
	if border_width > 0:
		style.border_width_left = border_width
		style.border_width_right = border_width
		style.border_width_top = border_width
		style.border_width_bottom = border_width
		style.border_color = border
	return style



