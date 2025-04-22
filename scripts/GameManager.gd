extends Node

@onready var board1: Control = %Board1
@onready var board2: Control = %Board2
@onready var hand1: Control = board1.get_node("Hand")
@onready var hand2: Control = board2.get_node("Hand")
@onready var deck1: Control = board2.get_node("Deck")
@onready var deck2: Control = board2.get_node("Deck")
@export var action_manager: Node

var selected_hand_card: Card = null
var selected_board_card: Card = null
var current_player = 1


const COMBAT_RULES = {
	"Damage": {
		"beats": "Magic",
		"action_cost": {
			"Magic": 1,
			"Damage": 2
		}
	},
	"Magic": {
		"beats": "Tank",
		"action_cost": {
			"Tank": 1,
			"Magic": 2
		}
	},
	"Tank": {
		"beats": "Damage",
		"action_cost": {
			"Damage": 1,
			"Tank": 2
		}
	}
}

func _ready():
	action_manager.actions_updated.connect(_on_actions_updated)
	update_board_interactivity()
	update_hand_interactivity()  # Ensure correct hand is active

func select_card(card: Card):
	var hand = get_current_hand()
	var parent = card.get_parent()
	var current_board = get_current_board()
	#current_board.clear_all_slot_highlights()
	# Handle selecting a card from the hand
	if parent == hand:
		# Deselect any board card when selecting from the hand
		if selected_board_card:
			deselect_all_cards()

		if selected_hand_card == card:
			deselect_all_cards()
		else:
			if selected_hand_card:
				selected_hand_card.toggle_selection()

			selected_hand_card = card
			current_board.find_empty_slots()
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
			deselect_all_cards()

		if selected_board_card == card:
			deselect_all_cards()
		else:
			if selected_board_card:
				selected_board_card.toggle_selection()

			selected_board_card = card
			card.toggle_selection()
			var current_slot = card.get_parent()
			var valid_slots = current_board.get_valid_target_slots(current_slot, card)
			if card.is_activated:
				current_board.highlight_slots(valid_slots)

func deselect_all_cards():
	var current_board = get_current_board()
	current_board.clear_all_slot_highlights()

	if selected_hand_card:
		selected_hand_card.toggle_selection()
		selected_hand_card = null

	if selected_board_card:
		selected_board_card.toggle_selection()
		selected_board_card = null

func can_attack(attacker: Card, target: Card) -> bool:
	# Basic checks (activation, actions, etc.)
	if not attacker.is_activated:
		return false
		
	var attacker_slot = attacker.get_parent()
	if not attacker_slot:
		return false
	
	# Get closest target only
	var board = get_current_board()
	var valid_targets = board.check_opponent_cards_in_range(attacker_slot)
	
	# Can only attack if target is the first in lane
	if not target in valid_targets:
		print("Can't attack - not the closest target in lane")
		return false
	
	# Rest of your combat rules (action costs, etc.)
	var attacker_type = attacker.card_type
	var target_type = target.card_type
	
	if COMBAT_RULES[target_type]["beats"] == attacker_type:
		return false
		
	var required_actions = get_action_cost(attacker, target)
	if action_manager.current_actions < required_actions:
		return false
	
	return true

func attack_card(attacker: Card, target: Card):
	var required_actions = get_action_cost(attacker, target)
	var was_selected = attacker.is_selected
	var opponent_player = 2 if current_player == 1 else 1

	target.get_parent().remove_card()

	if was_selected:
		attacker.toggle_selection()
	if selected_board_card == attacker:
		selected_board_card = null
		deselect_all_cards()
	for i in range(required_actions):
		check_opponent_defeated(opponent_player)
		action_manager.use_action()  # This may trigger turn switch

func get_action_cost(attacker: Card, target: Card) -> int:
	var attacker_type = attacker.card_type
	var target_type = target.card_type
	
	if attacker_type in COMBAT_RULES:
		var type_rules = COMBAT_RULES[attacker_type]
		var cost = type_rules.action_cost.get(target_type, 2)

		# Overpower rule: if same type, cost is 1 instead of 2
		if attacker.card_ability == "Overpower" and attacker_type == target_type:
			return 1

		return cost
	
	return 2  # fallback

func _on_actions_updated(actions_left):
	if actions_left == 0:
		switch_turns()

func switch_turns():
	deselect_all_cards()

	# Activate all cards for the player whose turn just ended
	var deactivating_player = current_player
	var deactivating_board = board1 if deactivating_player == 1 else board2
	
	for slot in deactivating_board.slots:
		if slot and slot.placed_card:
			slot.placed_card.set_activated(true)
	
	# Switch turns
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
	update_board_view()
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
		return %Board2
	else:
		return %Board1

func check_opponent_defeated(opponent_player: int):
	var opponent_board = board1 if opponent_player == 1 else board2
	var opponent_hand = hand1 if opponent_player == 1 else hand2
	var opponent_deck = deck1 if opponent_player == 1 else deck2
	
	# Check board slots
	var has_board_cards = false
	for slot in opponent_board.slots:
		if slot.placed_card:
			has_board_cards = true
			break
	
	# Check hand cards
	var has_hand_cards = opponent_hand.get_child_count() > 0
	
	# Check deck
	var has_deck_cards = opponent_deck.deck.size() > 0
	
	# If all empty, player wins
	if not has_board_cards and not has_hand_cards and not has_deck_cards:
		print(current_player, " WINS!")

func update_board_view():
	var board_container = %BoardContainer
	
	if current_player == 1:
		board_container.rotation_degrees = 0
	else:
		board_container.rotation_degrees = 180
