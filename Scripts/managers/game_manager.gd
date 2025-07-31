extends Node

func _ready() -> void:
	# 1. Assign your players into the TurnManager singleton
	TurnManager.players = [ %Player1, %Player2 ]
	await get_tree().process_frame
	# 2. Kick off the very first turn
	TurnManager.start_turn()
