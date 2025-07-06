extends Node

@onready var turn_label = $UI/TurnLabel
@onready var end_turn_button = $UI/EndTurnButton

func _on_turn_started(current_player):
	turn_label.text = "Player %d's Turn" % (current_player + 1)

func _on_match_ended(winner_id):
	get_tree().paused = true
	$UI/WinPopup.show("Player %d Wins!" % (winner_id + 1))
