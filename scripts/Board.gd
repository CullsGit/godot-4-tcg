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


@warning_ignore("INTEGER_DIVISION")
func move_card(current_slot, direction_string):
	var slot_index = slots.find(current_slot)
	if slot_index == -1:
		return

	var moving_card = current_slot.placed_card
	if moving_card == null:
		return
	if !moving_card.is_activated:
		return

	var direction_map = get_direction_map(moving_card)

	# If the direction is not valid, block the move
	if not direction_string in direction_map:
		return

	var dir = direction_map[direction_string]
	var col = slot_index % 3
	var row = slot_index / 3


	var new_col = col + int(dir.x)
	var new_row = row + int(dir.y)

	if new_col < 0 or new_col > 2 or new_row < 0 or new_row > 2:
		return  # Out of bounds

	var target_index = new_row * 3 + new_col

	if target_index < 0 or target_index >= slots.size():
		return

	var target_slot = slots[target_index]
	if target_slot.is_empty():
		current_slot.placed_card = null
		if moving_card.get_parent():
			moving_card.get_parent().remove_child(moving_card)

		target_slot.add_child(moving_card)
		target_slot.placed_card = moving_card
		moving_card.position = Vector2.ZERO
		var game_manager = %GameManager
		game_manager.deselect_all_cards()
		var action_manager = %ActionManager
		action_manager.use_action()

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

# Board.gd

# … anywhere below your player*_lanes definitions …

func has_clear_lane(from_slot: Node) -> bool:
	# 1. Find this slot’s index
	var slot_index = slots.find(from_slot)
	if slot_index == -1:
		return false

	# 2. Pick the right lanes array
	var is_p1 = from_slot.is_player1
	var my_lanes = player1_lanes if is_p1 else player2_lanes

	# 3. Locate which lane it’s in
	for lane in my_lanes:
		if slot_index in lane:
			var pos_in_lane = lane.find(slot_index)
			# 4. Check _all_ slots _before_ this one in the lane
			#    (these are between attacker and the opponent)
			for i in range(0, pos_in_lane):
				var idx = lane[i]
				if not slots[idx].is_empty():
					return false
			# 5. No blockers found
			return true

	# (shouldn’t happen if your lanes cover every slot)
	return false


func get_valid_target_slots(from_slot: Node, card: Node) -> Array:
	var valid_slots := []
	var slot_index = slots.find(from_slot)
	if slot_index == -1 or card == null:
		return valid_slots

	var direction_map = get_direction_map(card)
	var col = slot_index % 3
	var row = slot_index / 3

	for dir in direction_map.values():
		var new_col = col + int(dir.x)
		var new_row = row + int(dir.y)

		if new_col < 0 or new_col > 2 or new_row < 0 or new_row > 2:
			continue

		var target_index = new_row * 3 + new_col
		if target_index < 0 or target_index >= slots.size():
			continue

		var target_slot = slots[target_index]
		if target_slot.is_empty():
			valid_slots.append(target_slot)

	return valid_slots


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
	var opponent_lane = get_opponent_lane(slot.slot_index, slot.is_player1)
	
	var cards_in_range = []
	
	# Find first occupied slot in lane
	for opp_index in opponent_lane:
		var opp_slot = opponent_board.slots[opp_index]
		if opp_slot and opp_slot.placed_card:
			cards_in_range.append(opp_slot.placed_card)
			break  # Only return the first card in lane
	
	return cards_in_range

func get_direction_map(card) -> Dictionary:
	var direction_map = {
		"left": Vector2(-1, 0),
		"right": Vector2(1, 0),
		"up": Vector2(0, -1),
		"down": Vector2(0, 1),
	}

	if card.card_ability == "Strafe":
		direction_map.merge({
			"up_left": Vector2(-1, -1),
			"up_right": Vector2(1, -1),
			"down_left": Vector2(-1, 1),
			"down_right": Vector2(1, 1),
		})

	if card.card_ability == "Dash":
		direction_map.merge({
			"back_to_front": Vector2(0, -2),
			"front_to_back": Vector2(0, 2)
		})

	return direction_map

func find_empty_slots():
	var empty_slots = []
	for slot in slots:
		if slot.is_empty():
			empty_slots.append(slot)

	highlight_slots(empty_slots)


func highlight_slots(slot_list: Array = []):
	for slot in slots:
		slot.unhighlight()

	for slot in slot_list:
		slot.highlight()

func clear_all_slot_highlights():
	for slot in slots:
		slot.unhighlight()
