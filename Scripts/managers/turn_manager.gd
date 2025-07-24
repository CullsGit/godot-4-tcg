extends Node

signal turn_started(current_player : Player)

@export var players: Array[Player] = []
var current_player_index : int = 0


func _ready() -> void:
	ActionManager.actions_updated.connect(_on_actions_updated)

func start_turn() -> void:
	turn_started.emit(players[current_player_index])

func next_turn() -> void:
	var old_player = players[current_player_index]
	_clear_deactivated(old_player)          # unlock "just placed" cards

	current_player_index = (current_player_index + 1) % players.size()
	var new_player = players[current_player_index]

	_clear_shrouded(new_player)
	UIManager.deselect_all_cards()
	start_turn()

func get_current_player() -> Player:
	return players[current_player_index]

func get_current_opponent() -> Player:
	return players[(current_player_index + 1) % players.size()]

func _on_actions_updated(actions_remaining: int):
	if actions_remaining < 1:
		next_turn()

func _clear_deactivated(player: Player) -> void:
	for slot in BoardManager.get_slots(player):
		var card: Card = slot.placed_card
		if card:
			card.deactivated = false
			card.update_highlight()

func _clear_shrouded(player: Player) -> void:
	for slot in BoardManager.get_slots(player):
		var card: Card = slot.placed_card
		if card:
			card.shrouded = false
