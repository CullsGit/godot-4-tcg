extends Node

var current_player : Player = null

func _on_turn_started(current_player):
	current_player = current_player
	# only flip on local‐vs‐local: you could guard with a `if is_multiplayer: return`
	var flip = $Tween  # or your AnimationPlayer
	flip.interpolate_property( $Board, "rotation_degrees", 0, 180, 0.5 )
	flip.start()

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

# Movement = any empty slot on your own board
func get_valid_moves(attacker: Card) -> Array:
	var valid_slots := []
	for slot in current_player.board.get_children():
		if not slot.has_node("Card"):
			valid_slots.append(slot)
	return valid_slots

# Returns all slots on the *opponent’s* board that this card can attack
func get_valid_attacks(attacker: Card) -> Array:
	var valid_slots := []
	# Assume 2‐player; swap index
	var opponent = TurnManager.get_current_opponent()
	for slot in opponent.board.get_children():
		if can_attack(attacker, slot):
			valid_slots.append(slot)
	return valid_slots


# Tint a list of slots with the given color
func highlight_slots(slots: Array, tint: Color) -> void:
	for slot in slots:
		slot.modulate = tint

# Clear all slot tints across every board
func clear_all_slot_highlights() -> void:
	for player in TurnManager.players:
		for slot in player.board.get_children():
			slot.modulate = Color(1, 1, 1, 1)
