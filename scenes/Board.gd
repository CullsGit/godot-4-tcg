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

		var action_manager = %ActionManager
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

# Corrected Lanes for Player 1 and Player 2
var player1_lanes = [
	[0, 3, 6],  # Lane 1
	[1, 4, 7],  # Lane 2
	[2, 5, 8]   # Lane 3
]

var player2_lanes = [
	[2, 5, 8],  # Lane 1
	[1, 4, 7],  # Lane 2
	[0, 3, 6]   # Lane 3
]

func get_opponent_lane(slot_idx, player1_flag):
	# Determine which set of lanes to use
	var player_lanes = player1_lanes if player1_flag else player2_lanes
	var opponent_lanes = player2_lanes if player1_flag else player1_lanes

	for i in range(3):  # Loop through each lane
		if slot_idx in player_lanes[i]:
			var index_in_lane = player_lanes[i].find(slot_idx)
			match index_in_lane:
				0: return opponent_lanes[i].slice(0, 3)  # Target indexes 0-2
				1: return opponent_lanes[i].slice(0, 2)  # Target indexes 0-1
				2: return [opponent_lanes[i][0]]  # Target only index 0
	print("Error: Slot not found in any lane.")
	return []


func get_lane_position(slot_idx):
	for lane in player1_lanes + player2_lanes:  # Loop through all lanes
		if slot_idx in lane:
			return lane.find(slot_idx)  # Return the index within the lane
	print("Error: Slot not found in any lane.")
	return -1  # Invalid

func check_opponent_cards_in_range(slot):
	var game_manager = %GameManager
	var opponent_board = game_manager.get_opponent_board()
	
	# Get the opponent's lane corresponding to this slot
	var opponent_lane = get_opponent_lane(slot.slot_index, slot.is_player1)
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
