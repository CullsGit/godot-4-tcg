extends Control

var placed_card = null  # Stores the card placed in this slot

@export var slot_index: int  # Set this in the editor
@export var is_player1: bool  # True for P1 slots, False for P2 slots

func _ready():
	print("Slot ", slot_index, " initialized. Player 1:", is_player1)

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
			print("❌ Invalid move: You cannot place cards on the opponent's board!")
			return
		print("✅ Correct board detected, proceeding...")

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
	var game_manager = get_tree().get_root().find_child("GameManager", true, false)
	if not game_manager:
		print("Error: GameManager not found.")
		return

	# Remove the card from the previous parent safely
	if card.get_parent():
		card.get_parent().remove_child(card)

	add_child(card)  # Add to the slot
	card.position = Vector2.ZERO  # Align properly

	# Get opponent's lane
	var opponent_lane = get_opponent_lane(slot_index, is_player1)
	print("Opponent’s matching lane for slot", slot_index, ":", opponent_lane)

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

# Corrected Lanes for Player 1 and Player 2
var player1_lanes = [
	[0, 3, 6],  # Lane 1: P1 (1, 4, 7) -> P2 (2, 5, 8)
	[1, 4, 7],  # Lane 2: P1 (2, 5, 8) -> P2 (1, 4, 7)
	[2, 5, 8]   # Lane 3: P1 (3, 6, 9) -> P2 (0, 3, 6)
]

var player2_lanes = [
	[2, 5, 8],  # Lane 1: P2 (3, 6, 9) -> P1 (0, 3, 6)
	[1, 4, 7],  # Lane 2: P2 (2, 5, 8) -> P1 (1, 4, 7)
	[0, 3, 6]   # Lane 3: P2 (1, 4, 7) -> P1 (2, 5, 8)
]

func get_opponent_lane(slot_idx, player1_flag):
	# Determine which set of lanes to use
	var player_lanes = player1_lanes if player1_flag else player2_lanes
	var opponent_lanes = player2_lanes if player1_flag else player1_lanes

	for i in range(3):  # Loop through each lane
		if slot_idx in player_lanes[i]:
			print("Opponent's lane: ", opponent_lanes[i])
			return opponent_lanes[i]

	print("Error: Slot not found in any lane.")
	return []
