extends Node


signal clients_changed(clients: Array)
signal reputation_changed(reputation: int, title: String)

var clients: Array = []
var reputation: int = 0
var given: Dictionary = {}
var chatted: Dictionary = {}
var goal_announced: bool = false


func add_reputation(amount: int) -> void:
	reputation = clampi(reputation + amount, 0, 100)
	reputation_changed.emit(reputation, GameData.rep_title(reputation))


func give_client(key: String) -> Dictionary:
	if given.has(key):
		return {}
	if clients.size() >= GameData.CLIENTS.size():
		return {}
	var entry: Dictionary = (GameData.CLIENTS[clients.size()] as Dictionary).duplicate()
	entry["key"] = key
	clients.append(entry)
	given[key] = entry
	clients_changed.emit(clients)
	return entry


func client_for(key: String) -> Dictionary:
	return given.get(key, {})


func mark_chatted(key: String) -> void:
	chatted[key] = true


func has_chatted(key: String) -> bool:
	return chatted.has(key)


func reset() -> void:
	clients.clear()
	given.clear()
	chatted.clear()
	reputation = 0
	goal_announced = false
	clients_changed.emit(clients)
	reputation_changed.emit(reputation, GameData.rep_title(reputation))
