extends Node

@onready var board1: Control = $Board1
@onready var board2: Control = $Board2
@onready var hand1: Control = board1.get_node("Hand")
@onready var hand2: Control = board2.get_node("Hand")
@export var action_manager: Node

var selected_hand_card: Card = null
var selected_board_card: Card = null
var current_player = 1

func _ready():
	action_manager.actions_updated.connect(_on_actions_updated)
	update_board_interactivity()
	update_hand_interactivity()  # Ensure correct hand is active

func select_card(card: Card):
	var hand = get_current_hand()
	var parent = card.get_parent()
	var current_board = get_current_board()

	# Handle selecting a card from the hand
	if parent == hand:
		# Deselect any board card when selecting from the hand
		if selected_board_card:
			selected_board_card.toggle_selection()
			selected_board_card = null

		if selected_hand_card == card:
			card.toggle_selection()
			selected_hand_card = null
		else:
			if selected_hand_card:
				selected_hand_card.toggle_selection()

			selected_hand_card = card
			card.toggle_selection()
		return

	# Handle selecting a card from the board
	if parent.is_in_group("BoardSlot"):
		var card_board = parent.get_parent().get_parent()
		if card_board != current_board:  # This is opponent's card
			if selected_board_card:  # Only interact if we have a card selected
				if can_attack(selected_board_card, card):
					attack_card(selected_board_card, card)
				return
			return   # Exit early to avoid selecting the opponent's card

		# Deselect any hand card when selecting from the board
		if selected_hand_card:
			selected_hand_card.toggle_selection()
			selected_hand_card = null

		if selected_board_card == card:
			card.toggle_selection()
			selected_board_card = null
		else:
			if selected_board_card:
				selected_board_card.toggle_selection()

			selected_board_card = card
			card.toggle_selection()

func can_attack(attacker: Card, target: Card) -> bool:
	# Check if the target is in range of the attacker
	var attacker_slot = attacker.get_parent()
	var target_slot = target.get_parent()
	
	if not attacker_slot or not target_slot:
		return false
	
	var board = get_current_board()
	
	# Check if the target is in range of the attacker
	var in_range = board.check_opponent_cards_in_range(attacker_slot)
	return target in in_range

func attack_card(attacker: Card, target: Card):
	if can_attack(attacker, target):
		# Defeat the opponent's card
		print("Defeating opponent's card: ", target.card_type)
		
		# Remove the target card from the board
		var target_slot = target.get_parent()
		if target_slot:
			target_slot.remove_card()  # Remove the card from the slot
		
		# Use an action
		action_manager.use_action()
		
		# Deselect cards after attack
		if selected_hand_card:
			selected_hand_card.toggle_selection()
			selected_hand_card = null
		if selected_board_card:
			selected_board_card.toggle_selection()
			selected_board_card = null
	else:
		print("Target is not in range or invalid attack")

func _on_actions_updated(actions_left):
	if actions_left == 0:
		switch_turns()

func switch_turns():
	if selected_hand_card:
		selected_hand_card.toggle_selection()
		selected_hand_card = null
	if selected_board_card:
		selected_board_card.toggle_selection()
		selected_board_card = null

	current_player = 2 if current_player == 1 else 1
	action_manager.reset_actions()
	update_board_interactivity()
	update_hand_interactivity()  # Update the active hand
	print("Switched to Player %d" % current_player)

func update_board_interactivity():
	board1.set_process(current_player == 1)
	board2.set_process(current_player == 2)
	board1.set_physics_process(current_player == 1)
	board2.set_physics_process(current_player == 2)
	board1.visible = true  # Keep visible, but could later hide opponent’s view
	board2.visible = true

func update_hand_interactivity():
	hand1.set_process(current_player == 1)
	hand2.set_process(current_player == 2)
	hand1.set_physics_process(current_player == 1)
	hand2.set_physics_process(current_player == 2)
	hand1.visible = current_player == 1  # Hide inactive hand
	hand2.visible = current_player == 2

func get_current_board():
	return board1 if current_player == 1 else board2

func get_current_hand():
	return hand1 if current_player == 1 else hand2


func get_opponent_board():
	if current_player == 1:
		return $Board2
	else:
		return $Board1
