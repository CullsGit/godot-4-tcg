extends Node
class_name AIController

# Called once at the very start of the AI's turn:
func take_turn(player: Player) -> void:
	await get_tree().create_timer(2).timeout
	#_draw_phase(player)
	_play_phase(player)

	#_move_phase(player)
	#_attack_phase(player)

func _play_phase(player: Player) -> void:
	while ActionManager.current_actions > 0 \
	  and player.hand.cards_in_hand.size() > 0:
		# 1) Pick the first card in hand
		var card = player.hand.cards_in_hand[0]
		# 2) Find the first empty slot on THIS player’s board
		var chosen_slot: Slot = null
		for slot in BoardManager.get_slots(player):
			if slot.is_empty():
				chosen_slot = slot
				break
		if chosen_slot == null:
			break
		BoardManager.place_from_hand(card, chosen_slot)
		var delay = randf_range(2, 3)
		await get_tree().create_timer(delay).timeout
