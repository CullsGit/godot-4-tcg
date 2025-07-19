# Scripts/managers/BoardManager.gd
extends Node

var current_player : Player = null
var slots: Array[Slot] = []

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

const BOARD_WIDTH := 3

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)

func _on_turn_started(new_player: Player) -> void:
	current_player = new_player
	for slot in get_tree().get_nodes_in_group("BoardSlot"):
		if slot.get_board() == current_player.board:
			slots.append(slot)
	clear_all_slot_highlights()


# Place a card from hand onto the board
func place_from_hand(card: Card, slot: Slot, shroud := false) -> void:
	if not slot.is_empty():
		return

	current_player.hand.remove_card(card)
	slot.add_child(card)
	card.position = Vector2.ZERO
	slot.placed_card = card
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

	var legal_moves = get_valid_moves(card)

	if to_slot not in legal_moves:
		return

	from_slot.placed_card = null
	card.get_parent().remove_child(card)
	to_slot.add_child(card)
	card.position = Vector2.ZERO
	to_slot.placed_card = card

	ActionManager.use_action()
	UIManager.deselect_all_cards()


func get_valid_moves(attacker: Card) -> Array:
	var valid_moves := []
	var from_slot = attacker.get_parent() as Slot
	if from_slot == null:
		return valid_moves

	const COLS = BOARD_WIDTH  # e.g. 3
	var from_idx = from_slot.slot_index
	var from_col = from_idx % COLS
	var from_row = from_idx / COLS


	# 3) Loop each allowed direction
	for dir_vec in get_direction_map(attacker).values():
		var dx = int(dir_vec.x)
		var dy = int(dir_vec.y)
		var new_col = from_col + dx
		var new_row = from_row + dy

		# 4) Reject anything off‑grid
		if new_col < 0 or new_col >= COLS or new_row < 0 or new_row >= COLS:
			continue

		# 5) Compute the target slot index
		var target_idx = new_row * COLS + new_col

		# 6) Find the slot with that index and see if it’s empty
		for slot in slots:
			if slot.slot_index == target_idx and slot.is_empty():
				valid_moves.append(slot)
				break
		# note: we don’t add non‐empty slots here because you can’t move into them
	return valid_moves


func get_valid_attacks(attacker: Card, allow_overstrike := false) -> Array:
	var from_slot = attacker.get_parent() as Slot
	var lane_idx = _get_lane_index(from_slot.slot_index)
	if lane_idx == -1:
		return []

	var targets := []
	var opp_slots := []
	# pull only the opponent’s slots
	for slot in get_tree().get_nodes_in_group("BoardSlot"):
		if slot.get_board() == TurnManager.get_current_opponent().board:
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
		var slot = get_slot_by_index(idx, slots)
		if slot and not slot.is_empty():
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
func highlight_slots(tinted_slots: Array, tint: Color) -> void:
	for slot in tinted_slots:
		slot.modulate = tint

func clear_all_slot_highlights() -> void:
	for slot in slots:
		slot.modulate = Color(1,1,1,1)
