extends Control

var placed_card: Card = null  # The card inside the slot

@export var slot_index: int  # Set this in the editor
@export var is_player1: bool  # True for P1 slots, False for P2 slots


func is_empty():
	return placed_card == null  # Returns true if no card is placed

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var game_manager = %GameManager
		var current_board = game_manager.get_current_board()
		var board = self.get_parent().get_parent()  # Assuming slot is inside a board container

		# Ensure the slot belongs to the current board
		if board.get_instance_id() != current_board.get_instance_id():
			return
			
		var selected_hand_card = game_manager.selected_hand_card
		var selected_board_card = game_manager.selected_board_card

		if is_empty() and selected_hand_card:
			selected_hand_card.get_parent().remove_card(selected_hand_card)
			game_manager.selected_hand_card = null  # Clear hand selection
			place_card(selected_hand_card)
		elif selected_board_card and selected_board_card.get_parent().is_in_group("BoardSlot"):
			var current_slot = selected_board_card.get_parent()
			if board:
				board.move_card(current_slot, get_slot_direction(current_slot, self))
				#game_manager.selected_board_card = null  # Clear board selection after moving

func place_card(card):
	var board = get_parent().get_parent()  # Get Board node
	# Remove the card from the previous parent safely
	if card.get_parent():
		card.get_parent().remove_child(card)

	add_child(card)  # Add to the slot
	card.position = Vector2.ZERO  # Align properly
	board.check_opponent_cards_in_range(self)
	# Use an action
	var action_manager = %ActionManager
	if action_manager:
		action_manager.use_action()
	else:
		print("Error: ActionManager not found.")

	# Ensure card is deselected after placement
	if card.has_method("toggle_selection"):
		card.toggle_selection()  # Deselect if highlighting is handled in `toggle_selection()`

	# Store the placed card reference
	placed_card = card

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
