extends Node

const ATTACKER_LANES := [
	[0, 3, 6],  # Lane 1
	[1, 4, 7],  # Lane 2
	[2, 5, 8],  # Lane 3
]

const TARGET_LANES := [
	[2, 5, 8],  # Lane 1
	[1, 4, 7],  # Lane 2
	[0, 3, 6],  # Lane 3
]

var current_player : Player = null

func _on_turn_started(current_player):
	current_player = current_player
	# only flip on local‐vs‐local: you could guard with a `if is_multiplayer: return`
	var flip = $Tween  # or your AnimationPlayer
	flip.interpolate_property( $Board, "rotation_degrees", 0, 180, 0.5 )
	flip.start()


func get_slots() -> Array:
	var board_node = TurnManager.get_current_player().board
	var grid       = board_node.get_node("Grid") as GridContainer
	var slots: Array = []
	for child in grid.get_children():
		# If you’ve given Slot.gd a `class_name Slot`, use `if child is Slot:` instead.
		# Otherwise, assume every grid‐child is a slot:
		slots.append(child)
	return slots

func place_from_hand(card: Card, slot: Slot, shroud := false) -> void:
	if not slot.is_empty():
		return

	# 1) Reparent
	card.get_parent().remove_child(card)
	slot.add_child(card)
	card.position = Vector2.ZERO
	slot.placed_card = card

	# 3) Spend action & clear UI
	ActionManager.use_action()
	UIManager.deselect_all_cards()

func move_card(from_slot: Slot, to_slot: Slot) -> void:
	# 1) Find and validate both slots in the grid
	var board_node  = TurnManager.get_current_player().board
	var grid        = board_node.get_node("Grid") as GridContainer
	var slots       = grid.get_children().filter(c -> c is Slot) as Array
	var from_index  = slots.find(from_slot)
	var to_index    = slots.find(to_slot)
	if from_index == -1 or to_index == -1:
		return

	# 2) Check the card’s state
	var card = from_slot.placed_card
	if card == null or card.bulwarked or card.shrouding or card.is_shrouded:
		return

	# 3) Enforce directional rules
	var cols = grid.columns
	var from_col = from_index % cols
	var from_row = from_index / cols
	var to_col   = to_index   % cols
	var to_row   = to_index   / cols
	var delta    = Vector2(to_col - from_col, to_row - from_row)
	var dir_map  = get_direction_map(card)
	if not dir_map.values().has(delta):
		return

	# 4) Ensure destination is empty
	if not to_slot.is_empty():
		return

	# 5) Perform the move
	from_slot.placed_card = null
	card.get_parent().remove_child(card)
	to_slot.add_child(card)
	card.position = Vector2.ZERO
	to_slot.placed_card = card

	# 6) Spend the action and clear UI
	ActionManager.use_action()
	UIManager.deselect_all_cards()


# Returns true if `attacker` may attack a card in `target_slot`
func can_attack(attacker: Card, target_slot: Node) -> bool:
	# Slot must actually have a Card
	if not target_slot.has_node("Card"):
		return false
	var defender: Card = target_slot.get_node("Card")
	# Cannot attack your own cards
	if defender.get_owner() == attacker.get_owner():
		return false
	# Attacker must be active and not status‐locked
	if not attacker.is_activated or attacker.bulwarked or attacker.shrouding or attacker.is_shrouded:
		return false
	return true

# In BoardManager.gd

func get_valid_moves(attacker: Card) -> Array:
	var valid_slots: Array = []
	# 1) Gather the slots and layout info
	var slots = get_slots()
	var board = TurnManager.get_current_player().board
	var grid  = board.get_node("Grid") as GridContainer
	var cols  = grid.columns
	# Compute rows just so we can bounds-check dynamically
	var rows = int(ceil(slots.size() / float(cols)))

	# 2) Find the attacker’s current slot
	var from_slot  = attacker.get_parent()
	var from_index = slots.find(from_slot)
	if from_index == -1:
		return valid_slots

	var col = from_index % cols
	var row = from_index / cols

	# 3) Ask the card which directions it can move
	var dir_map = get_direction_map(attacker)

	# 4) For each direction, see if that neighbor is on-board and empty
	for dir in dir_map.values():
		var new_col = col + int(dir.x)
		var new_row = row + int(dir.y)
		if new_col < 0 or new_col >= cols or new_row < 0 or new_row >= rows:
			continue
		var to_index = new_row * cols + new_col
		if to_index < 0 or to_index >= slots.size():
			continue
		var to_slot = slots[to_index]
		if to_slot.is_empty():
			valid_slots.append(to_slot)
	return valid_slots

# Helper: find which lane index a slot belongs to
func _get_lane_index(slot_idx: int) -> int:
	for i in ATTACKER_LANES.size():
		if slot_idx in ATTACKER_LANES[i]:
			return i
	return -1

# Returns up to two valid attack slots for this attacker
func get_valid_attacks(attacker: Card, allow_overstrike := false) -> Array:
	var slots        = get_slots()  # current player’s slots
	var from_slot    = attacker.get_parent() as Slot
	var from_index   = slots.find(from_slot)
	if from_index == -1:
		return []

	# 1) Figure out which attacker‐lane we’re in
	var lane_idx = _get_lane_index(from_index)
	if lane_idx == -1:
		return []

	# 2) Grab the matching target‐lane for the opponent
	var target_lane = TARGET_LANES[lane_idx]

	# 3) Pull the opponent’s slots array
	var opp_slots = TurnManager.get_current_opponent().board.get_node("Grid").get_children()

	# 4) Collect up to 1 or 2 cards in that lane
	var valid: Array = []
	for idx in target_lane:
		var s = opp_slots[idx] as Slot
		if s.placed_card:
			valid.append(s)
			if not allow_overstrike:
				break
	return valid


func allied_blockers_in_lane(attacker_slot: Slot) -> int:
	# 1. Grab the board this slot lives in
	var board = attacker_slot.get_parent()
	var slots = board.get_children()  # Array of Slot

	# 2. Find which lane this slot sits in
	var idx = slots.find(attacker_slot)
	if idx == -1:
		return 0

	for lane in ATTACKER_LANES:
		if idx in lane:
			# 3. Count any non‐empty slots before `idx` in that lane
			var blockers = 0
			for j in lane:
				if j == idx:
					break
				if not slots[j].is_empty():
					blockers += 1
			return blockers

	return 0


func get_direction_map(card: Card) -> Dictionary:
	var direction_map = {
		"left":  Vector2(-1,  0),
		"right": Vector2( 1,  0),
		"up":    Vector2( 0, -1),
		"down":  Vector2( 0,  1),
	}
	if card.ability == "Strafe":
		direction_map.merge({
			"up_left":    Vector2(-1, -1),
			"up_right":   Vector2( 1, -1),
			"down_left":  Vector2(-1,  1),
			"down_right": Vector2( 1,  1),
		})
	if card.ability == "Dash":
		direction_map.merge({
			"back_to_front": Vector2( 0, -2),
			"front_to_back": Vector2( 0,  2),
		})
	return direction_map

# Tint a list of slots with the given color
func highlight_slots(slots: Array, tint: Color) -> void:
	for slot in slots:
		slot.modulate = tint

# Clear all slot tints across every board
func clear_all_slot_highlights() -> void:
	for player in TurnManager.players:
		for slot in player.board.get_children():
			slot.modulate = Color(1, 1, 1, 1)
