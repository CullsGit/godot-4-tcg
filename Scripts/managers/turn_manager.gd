extends Node

signal turn_started(current_player : Node)

@export var players: Array[Player] = []
var current_player_index : int = 0

func start_turn() -> void:
	# Emit the actual Player node directly
	emit_signal("turn_started", players[current_player_index])

func next_turn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	start_turn()
