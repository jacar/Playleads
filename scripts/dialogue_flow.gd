extends Node


var active: bool = false
var _main: Node
var _hud: Node
var _rng := RandomNumberGenerator.new()
var _shop_id: String = ""
var _who: String = ""
var _actions: Array = []
var _last_line: Dictionary = {}


func _ready() -> void:
	add_to_group("dialogue_flow")
	_rng.randomize()


func setup(main_node: Node, hud_node: Node) -> void:
	_main = main_node
	_hud = hud_node
	_hud.choice_chosen.connect(_on_choice)
	_hud.dialogue_cancelled.connect(close)


func start(shop_id: String, who: String) -> void:
	_shop_id = shop_id
	_who = who
	active = true
	var shop: Dictionary = GameData.SHOPS[shop_id]
	var base_key := _key() + ":hello"
	var speaker := str(shop["owner"] if who == "owner" else shop["customer"])
	var role := str(shop["owner_role"] if who == "owner" else shop["customer_role"])
	var lines: Array = shop["owner_lines"] if who == "owner" else shop["customer_lines"]
	var line := _pick_line(base_key, lines)
	_actions = ["offer", "chat", "leave"]
	_hud.show_dialogue(speaker, role, str(shop["name"]), line, [
		"Ofrecerle mis mandados",
		"Preguntar por el barrio",
		"Seguir recorriendo",
	])


func _show(text: String, actions: Array, labels: Array) -> void:
	_actions = actions
	_hud.update_dialogue(text, labels)


func _post(text: String, action: String, label: String) -> void:
	var actions := [action]
	var labels := [label]
	if action != "chat" and not GameState.has_chatted(_key()):
		actions.append("chat")
		labels.append("Preguntar por el barrio")
	actions.append("leave")
	labels.append("Despedirse")
	_show(text, actions, labels)


func _on_choice(index: int) -> void:
	if not active:
		return
	if index < 0 or index >= _actions.size():
		return
	match str(_actions[index]):
		"offer":
			_offer()
		"chat":
			_chat()
		"leave":
			close()


func _offer() -> void:
	var key := _key()
	if GameState.given.has(key):
		var existing: Dictionary = GameState.client_for(key)
		var text := _pick_line(key + ":repeat", GameData.REPEAT_LINES).format({
			"client": str(existing.get("name", "su cliente")),
			"trade": str(existing.get("trade", "")),
		})
		GameState.add_reputation(2)
		_post(text, "chat", "Preguntar por el barrio")
		return
	var client := GameState.give_client(key)
	if client.is_empty():
		_show("Hoy no me queda a quién recomendarle. Vuelva en un rato, que el barrio no se acaba.", ["leave"], ["Despedirse"])
		return
	var success := _pick_line(key + ":success", GameData.SUCCESS_LINES).format({
		"client": str(client.get("name", "")),
		"trade": str(client.get("trade", "")),
	})
	GameState.add_reputation(8)
	_hud.toast("Nuevo cliente", "%s · %s" % [str(client.get("name", "")), str(client.get("trade", ""))], Color(0.85, 0.62, 0.25))
	if GameState.clients.size() == 1:
		_hud.toast("Primer cliente", "Ya tienes a quién llevarle encargos. El barrio empieza a saber tu nombre.", Color(0.72, 0.33, 0.19))
	_post(success, "chat", "Preguntar por el barrio")
	_check_goal()


func _chat() -> void:
	var key := _key()
	var shop: Dictionary = GameData.SHOPS[_shop_id]
	if GameState.has_chatted(key):
		var small := _pick_line(key + ":again", [
			"Eso ya se lo conté. Pregúntele a otro, que cada uno ve la cuadra distinto.",
			"Ya le dije lo que sabía. Vaya y muéstrese, que aquí lo que cuenta es aparecer.",
			"Le repito lo mismo: camine despacio, salude, y no se pierda el pan caliente de las cinco.",
		])
		_post(small, "offer", "Ofrecerle mis mandados")
		return
	GameState.mark_chatted(key)
	GameState.add_reputation(3)
	var info: Array = shop["info"]
	var line := _pick_line(key + ":info", info)
	var closer := _pick_line(key + ":closer", GameData.INFO_REPLIES)
	_post(line + "\n\n" + closer, "offer", "Ofrecerle mis mandados")


func _check_goal() -> void:
	if GameState.clients.size() >= GameData.GOAL_CLIENTS and not GameState.goal_announced:
		GameState.goal_announced = true


func close() -> void:
	if not active:
		return
	active = false
	_hud.hide_dialogue()
	_actions = []


func _key() -> String:
	return _shop_id + "/" + _who


func _pick_line(key: String, lines: Array) -> String:
	if lines.is_empty():
		return ""
	var index := _rng.randi_range(0, lines.size() - 1)
	if lines.size() > 1 and int(_last_line.get(key, -1)) == index:
		index = (index + 1) % lines.size()
	_last_line[key] = index
	return str(lines[index])
