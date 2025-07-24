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
	deselect_all_cards()
	BoardManager.clear_all_slot_highlights()

func _on_match_ended(winner_id):
	get_tree().paused = true
	$UI/WinPopup.show("Player %d Wins!" % (winner_id + 1))

func on_card_selected(card: Card) -> void:
	if selected_board_card and card.card_owner != current_player:
		# enemy card clicked
		if AttackManager.can_attack(selected_board_card, card):
			AttackManager.resolve_attack(selected_board_card, card)
		else:
			print("Cannot attack:", selected_board_card.name, "→", card.name)
		return

	if current_player == null or card.card_owner != current_player or card.deactivated:
		return

	if card == selected_hand_card or card == selected_board_card:
		deselect_all_cards()
		BoardManager.clear_all_slot_highlights()
		return
	deselect_all_cards()

	# Toggle this card’s selection
	card.toggle_selection()
	var parent = card.get_parent()
	# Track which card is selected and highlight options
	if parent == current_player.hand:
		selected_hand_card = card
		var empties := []
		for slot in BoardManager.get_slots():
			if slot.is_empty():
				empties.append(slot)
		BoardManager.highlight_slots(empties, Color(0, 1, 0, 0.5))
	elif parent is Slot and not card.is_locked():
		selected_board_card = card
		var move_slots   = BoardManager.get_valid_moves(card)
		BoardManager.highlight_slots(move_slots, Color(0, 1, 0, 0.5))
		var attack_slots = BoardManager.get_valid_attacks(card)
		BoardManager.highlight_slots(attack_slots, Color(1, 0, 0, 0.5))


func _on_slot_clicked(slot: Slot) -> void:
	# 1) Placing a hand card onto an empty slot
	if selected_hand_card:
		if slot.get_board() == current_player.board and slot.is_empty():
			BoardManager.place_from_hand(selected_hand_card, slot)

	if selected_board_card:
		var from_slot = selected_board_card.get_parent()

		# 2a) Move: empty slot on my board
		if slot.get_board() == current_player.board and slot.is_empty():
			BoardManager.move_card(from_slot, slot)
			return

		return

func on_use_card_ability(card: Card, ability: String) -> void:
	# Can't fire abilities from hand
	if card.get_parent() == card.card_owner.hand:
		return

	match ability:
		"Bulwark": AbilityManager.bulwarked(card)
		"Shroud":  AbilityManager.shrouding(card)


func deselect_all_cards() -> void:
	if selected_hand_card:
		selected_hand_card.toggle_selection()
		selected_hand_card = null
	if selected_board_card:
		selected_board_card.toggle_selection()
		selected_board_card = null
	# clear any highlights
	BoardManager.clear_all_slot_highlights()
