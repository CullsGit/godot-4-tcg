extends Node

var current_player       : Player = null
var selected_hand_card   : Card   = null
var selected_board_card  : Card   = null


func _ready() -> void:
	await get_tree().process_frame

	for slot in get_tree().get_nodes_in_group("BoardSlot"):
		slot.slot_clicked.connect(_on_slot_clicked)

	TurnManager.turn_started.connect(_on_turn_started)

func _on_turn_started(new_current_player: Player) -> void:
	current_player = new_current_player
	print(current_player)
	deselect_all_cards()
	BoardManager.clear_all_slot_highlights()

func _on_match_ended(winner_id):
	get_tree().paused = true
	$UI/WinPopup.show("Player %d Wins!" % (winner_id + 1))

func on_card_selected(card: Card) -> void:
	if current_player == null or card.card_owner != current_player:
		return

	# Clear previous selections/highlights
	deselect_all_cards()
	BoardManager.clear_all_slot_highlights()

	# Toggle this card’s selection
	card.toggle_selection()

	# Track which card is selected and highlight options
	if card.get_parent() == current_player.hand:
		selected_hand_card = card
	elif card.get_parent() == current_player.board:
		selected_board_card = card
		var move_slots   = BoardManager.get_valid_moves(card)
		BoardManager.highlight_slots(move_slots, Color(0, 1, 0, 0.5))
		var attack_slots = BoardManager.get_valid_attacks(card)
		BoardManager.highlight_slots(attack_slots, Color(1, 0, 0, 0.5))


func _on_slot_clicked(slot: Slot) -> void:
	# 1) Placing a hand card onto an empty slot
	if selected_hand_card and slot.is_empty():
		BoardManager.place_from_hand(selected_hand_card, slot)
		return

	# 2) Moving or attacking with a board card
	if selected_board_card:
		if slot.placed_card:
			# Attack!
			AttackManager.resolve_attack(selected_board_card, slot.placed_card)
		else:
			# Move
			BoardManager.move_card(selected_board_card.get_parent(), slot)
		return


func deselect_all_cards() -> void:
	if selected_hand_card:
		selected_hand_card.toggle_selection()
		selected_hand_card = null
	if selected_board_card:
		selected_board_card.toggle_selection()
		selected_board_card = null
	# clear any highlights
	BoardManager.clear_all_slot_highlights()
