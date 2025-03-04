extends Control

@onready var grid = $Grid  # Reference to GridContainer

@export var slot_scene: PackedScene  # Assign `Slot.tscn` in Inspector
@export var card_scene: PackedScene  # Assign `Card.tscn` in Inspector

var slots = []  # List of all slots on the board



func _ready():
	# Store slot references
	for child in grid.get_children():
		if child is Control:
			slots.append(child)


func move_card(current_slot, direction):

	var slot_index = slots.find(current_slot)

	if slot_index == -1:
		return  # Slot not found

	var target_index = get_target_index(slot_index, direction)

	if target_index == -1:
		return  # No valid move

	var target_slot = slots[target_index]

	if target_slot.is_empty():
		var moving_card = current_slot.placed_card
		if moving_card == null:
			return  # No card to move
			
		current_slot.placed_card = null  # Clear the old slot's reference
		if moving_card.get_parent():
			moving_card.get_parent().remove_child(moving_card)  # Remove card from old slot

		target_slot.add_child(moving_card)  # Move to new slot
		target_slot.placed_card = moving_card  # Update new slot reference
		moving_card.position = Vector2.ZERO  # Reset position after moving

		var action_manager = get_tree().get_root().find_child("ActionManager", true, false)
		check_opponent_cards_in_range(target_slot)
		action_manager.use_action()

func get_target_index(slot_index, direction):
	var row = slot_index / 3  # Get row index
	var col = slot_index % 3  # Get column index

	match direction:
		"left":
			if col > 0:
				return slot_index - 1
		"right":
			if col < 2:
				return slot_index + 1
		"up":
			if row > 0:
				return slot_index - 3
		"down":
			if row < 2:
				return slot_index + 3
	
	return -1  # Invalid move

func check_opponent_cards_in_range(slot):
	# Find GameManager
	var game_manager = get_tree().get_root().find_child("GameManager", true, false)
	if not game_manager:
		print("Error: GameManager not found.")
		return

	# Get opponent's board
	var opponent_board = game_manager.get_opponent_board()
	if not opponent_board:
		print("Error: Opponent Board not found.")
		return
	
	# Get the opponent's lane corresponding to this slot
	var opponent_lane = slot.get_opponent_lane(slot.slot_index, slot.is_player1)
	print("Checking opponent cards in lane:", opponent_lane)

	var cards_in_range = []

	# Iterate through the opponent's slots in the lane
	for opp_index in opponent_lane:
		var opp_slot = opponent_board.slots[opp_index]
		if opp_slot and opp_slot.placed_card:
			cards_in_range.append(opp_slot.placed_card.card_type)

	# Print results
	if cards_in_range.size() > 0:
		print("Opponent cards in range:", cards_in_range)
	else:
		print("No opponent cards in range.")
