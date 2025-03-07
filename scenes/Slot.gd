extends Control

var placed_card: Card = null  # The card inside the slot
var selected_card: Card = null 

@export var slot_index: int  # Set this in the editor
@export var is_player1: bool  # True for P1 slots, False for P2 slots


func set_card(card: Card):
	placed_card = card
	placed_card.connect("card_selected", _on_card_selected)

func _on_card_selected(card: Card):
	selected_card = card
	print("Selected card:", selected_card.card_type)  # ✅ Prints when a card is selected

func is_empty():
	return placed_card == null  # Returns true if no card is placed

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var game_manager = get_tree().get_root().find_child("GameManager", true, false)
		var current_board = game_manager.get_current_board()
		var current_hand = game_manager.get_current_hand()  # Find Hand globally

		var board = self.get_parent().get_parent()  # Assuming slot is inside a board container

		# Ensure the slot belongs to the current board
		if board.get_instance_id() != current_board.get_instance_id():
			return

		if is_empty() and current_hand and current_hand.selected_card:
			var card_to_place = current_hand.selected_card
			if card_to_place.get_parent() == current_hand:
				current_hand.remove_card(card_to_place)
				current_hand.selected_card = null  # Deselect first
				place_card(card_to_place)
			elif card_to_place.get_parent().is_in_group("BoardSlot"):
				var current_slot = card_to_place.get_parent()
				if board:
					board.move_card(current_slot, get_slot_direction(current_slot, self))

func place_card(card):
	var board = get_parent().get_parent()  # Get Board node
	# Remove the card from the previous parent safely
	if card.get_parent():
		card.get_parent().remove_child(card)

	add_child(card)  # Add to the slot
	card.position = Vector2.ZERO  # Align properly
	board.check_opponent_cards_in_range(self)
	# Use an action
	var action_manager = get_tree().get_root().find_child("ActionManager", true, false)
	if action_manager:
		action_manager.use_action()
	else:
		print("Error: ActionManager not found.")

	# Ensure card is deselected after placement
	if card.has_method("toggle_selection"):
		card.toggle_selection()  # Deselect if highlighting is handled in `toggle_selection()`
	
	# Store the placed card reference
	set_card(card)

func remove_card():
	if placed_card:
		placed_card.get_parent().remove_child(placed_card)  # Properly remove from scene
		placed_card = null  # Clear reference

func get_slot_direction(from_slot, to_slot):
	var from_index = from_slot.slot_index
	var to_index = to_slot.slot_index

	var diff = to_index - from_index

	match diff:
		-1: return "left"
		1: return "right"
		-3: return "up"
		3: return "down"
		_: return ""  # Invalid move
