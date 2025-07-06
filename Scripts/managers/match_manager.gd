extends Node

signal match_ended(winner_index: int)

@onready var game_manager = %GameManager
@export var players: Array[Player] = []

func _ready() -> void:
	TurnManager.turn_started.connect(Callable(self, "_on_turn_started"))
	
func _on_turn_started(current_player) -> void:
	var loser = _check_loss(current_player)
	if loser != null:
		# find the other player
		var winner = null
		for p in players:
			if p != loser:
				winner = p
				break
		if winner != null:
			var wi = players.find(winner)
			emit_signal("match_ended", wi)

func _check_loss(current_player) -> Node:
	# replace this stub with your real “no moves / deck empty” logic
	if current_player._deck.size() == 0:
		return current_player
	return null


func _on_turn_manager_turn_started(player_id: int) -> void:
	game_manager.update_board_view()
