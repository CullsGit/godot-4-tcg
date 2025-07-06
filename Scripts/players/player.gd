class_name Player
extends Node2D

@export var controller: Node = null
@onready var board = $Board
@onready var hand  = $Hand
@onready var deck  = $Deck

func _on_turn_started(current_player) -> void:
	if controller is AIController:
		var slot_idx = controller.decide_move(self)
		if slot_idx >= 0:
			var card = hand.play_card(slot_idx)
			board.place_card(card, slot_idx)
			emit_signal("card_played", card, slot_idx)
		# end the AI’s turn
		%TurnManager.next_turn()
	# else: wait for human input…

func play_card(slot_index):
	var card = hand.play_card(slot_index)
	board.place_card(card, slot_index)
	emit_signal("card_played", card, slot_index)
