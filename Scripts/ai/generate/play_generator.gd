extends RefCounted
class_name PlayGenerator

func legal_plays(player: Player) -> Array:
	var pairs: Array = []
	if ActionManager.current_actions <= 0:
		return pairs
	if player.hand.cards_in_hand.is_empty():
		return pairs
	
	for slot: Slot in BoardManager.get_slots():
		if slot.is_empty():
			for card: Card in player.hand.cards_in_hand:
				pairs.append([card, slot])
	return pairs
