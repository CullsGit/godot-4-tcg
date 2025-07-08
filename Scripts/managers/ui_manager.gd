extends Node

var current_player : Player = null
var selected_hand_card   : Card = null
var selected_board_card  : Card = null

func _on_turn_started(current_player):
	current_player = current_player
	deselect_all_cards()
	BoardManager.clear_all_slot_highlights()

func _on_match_ended(winner_id):
	get_tree().paused = true
	$UI/WinPopup.show("Player %d Wins!" % (winner_id + 1))

func on_card_selected(card: Card) -> void:
	if TurnManager.get_current_player() != card.get_owner():
		return
	var hand  = current_player.hand
	var board = current_player.board
	var parent = card.get_parent()

	# First, clear any existing selection/highlights
	deselect_all_cards()
	BoardManager.clear_all_slot_highlights()
	# Now toggle the clicked card
	card.toggle_selection()

	# Track it
	if parent == hand:
		selected_hand_card = card
	elif parent == board:
		selected_board_card = card
		var move_slots = BoardManager.get_valid_moves(card)
		BoardManager.highlight_slots(move_slots, Color(0, 1, 0, 0.5))
		# Highlight valid moves/attacks for this card
		var attack_slots = BoardManager.get_valid_attacks(card)
		BoardManager.highlight_slots(attack_slots, Color(1, 0, 0, 0.5))

func deselect_all_cards() -> void:
	if selected_hand_card:
		selected_hand_card.toggle_selection()
		selected_hand_card = null
	if selected_board_card:
		selected_board_card.toggle_selection()
		selected_board_card = null
	# clear any highlights
	BoardManager.clear_all_slot_highlights()
