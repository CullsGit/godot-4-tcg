# Scripts/managers/BoardManager.gd
extends Node

var current_player : Player = null

const ATTACKER_LANES := [
	[0, 3, 6],
	[1, 4, 7],
	[2, 5, 8],
]

const TARGET_LANES := [
	[2, 5, 8],
	[1, 4, 7],
	[0, 3, 6],
]

const BOARD_WIDTH := 3  # fixed for 3×3

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)

func _on_turn_started(new_player: Player) -> void:
	current_player = new_player
	clear_all_slot_highlights()


# Returns all slots belonging to the current player
func get_slots() -> Array:
	var slots := []
	for slot in get_tree().get_nodes_in_group("BoardSlot"):
		# slot.parent is GridContainer, its parent is the Player node
		if slot.get_parent().get_parent() == current_player.board:
			slots.append(slot)
	return slots


# Place a card from hand onto the board
func place_from_hand(card: Card, slot: Slot, shroud := false) -> void:
	if not slot.is_empty():
		return
	# reparent
	card.get_parent().remove_child(card)
	slot.add_child(card)
	card.position = Vector2.ZERO
	slot.placed_card = card
	card.owner_player = current_player
	card.set_activated(not shroud)
	if shroud:
		card.toggle_shrouded()

	ActionManager.use_action()
	UIManager.deselect_all_cards()


# Move a card one allowed step
func move_card(from_slot: Slot, to_slot: Slot) -> void:
	var card = from_slot.placed_card
	if card == null or not card.is_activated:
		return

	# compute delta index via slot_index and BOARD_WIDTH
	var delta = to_slot.slot_index - from_slot.slot_index
	# build allowed offsets
	var allowed_offsets := []
	for dir_vec in get_direction_map(card).values():
		allowed_offsets.append(int(dir_vec.y) * BOARD_WIDTH + int(dir_vec.x))

	if delta not in allowed_offsets or not to_slot.is_empty():
		return

	# do the move
	from_slot.placed_card = null
	card.get_parent().remove_child(card)
	to_slot.add_child(card)
	card.position = Vector2.ZERO
	to_slot.placed_card = card

	ActionManager.use_action()
	UIManager.deselect_all_cards()


# Highlight moves: one-step, empty neighbors
func get_valid_moves(attacker: Card) -> Array:
	var moves := []
	var from_slot = attacker.get_parent() as Slot
	if from_slot == null:
		return moves

	for dir_vec in get_direction_map(attacker).values():
		var target_idx = from_slot.slot_index + int(dir_vec.y) * BOARD_WIDTH + int(dir_vec.x)
		var target_slot = get_slot_by_index(target_idx, get_slots())
		if target_slot and target_slot.is_empty():
			moves.append(target_slot)
	return moves


# RPS‐range attacks: first 1 or 2 enemies in your lane
func get_valid_attacks(attacker: Card, allow_overstrike := false) -> Array:
	var from_slot = attacker.get_parent() as Slot
	var lane_idx = _get_lane_index(from_slot.slot_index)
	if lane_idx == -1:
		return []

	var targets := []
	var opp_slots := []
	# pull only the opponent’s slots
	for slot in get_tree().get_nodes_in_group("BoardSlot"):
		if slot.get_parent().get_parent() == TurnManager.get_current_opponent().board:
			opp_slots.append(slot)

	for idx in TARGET_LANES[lane_idx]:
		var s = get_slot_by_index(idx, opp_slots)
		if s and s.placed_card:
			targets.append(s)
			if not allow_overstrike:
				break
	return targets


# Count allied blockers before you in your lane
func allied_blockers_in_lane(attacker_slot: Slot) -> int:
	var lane_idx = _get_lane_index(attacker_slot.slot_index)
	if lane_idx == -1:
		return 0
	var blockers = 0
	for idx in ATTACKER_LANES[lane_idx]:
		if idx == attacker_slot.slot_index:
			break
		var s = get_slot_by_index(idx, get_slots())
		if s and not s.is_empty():
			blockers += 1
	return blockers


# Helpers

func get_slot_by_index(idx: int, pool: Array) -> Slot:
	for slot in pool:
		if slot.slot_index == idx:
			return slot
	return null

func _get_lane_index(slot_idx: int) -> int:
	for i in ATTACKER_LANES.size():
		if slot_idx in ATTACKER_LANES[i]:
			return i
	return -1

func get_direction_map(card: Card) -> Dictionary:
	var movement = {
		"left":  Vector2(-1,  0),
		"right": Vector2( 1,  0),
		"up":    Vector2( 0, -1),
		"down":  Vector2( 0,  1),
	}
	if card.card_ability == "Strafe":
		movement.merge({
			"up_left":    Vector2(-1, -1),
			"up_right":   Vector2( 1, -1),
			"down_left":  Vector2(-1,  1),
			"down_right": Vector2( 1,  1),
		})
	if card.card_ability == "Dash":
		movement.merge({
			"back_to_front": Vector2( 0, -2),
			"front_to_back": Vector2( 0,  2),
		})
	return movement

# Visual helpers
func highlight_slots(slots: Array, tint: Color) -> void:
	for s in slots:
		s.modulate = tint

func clear_all_slot_highlights() -> void:
	for s in get_slots():
		s.modulate = Color(1,1,1,1)
