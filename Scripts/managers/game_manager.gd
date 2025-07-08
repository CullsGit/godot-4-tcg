extends Node

@onready var player1 = $Player1
@onready var player2 = $Player2

func _ready() -> void:
	# 1. Assign your players into the TurnManager singleton
	TurnManager.players = [ player1, player2 ]
	# 3. Kick off the very first turn
	TurnManager.start_turn()
