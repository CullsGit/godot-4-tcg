extends RefCounted
class_name DrawGenerator

func legal_draws(player: Player) -> Array:
	var options: Array = []
	if not can_draw_now(player):
		options.append("DRAW")
	return options

func can_draw_now(player: Player) -> bool:
	if ActionManager.current_actions <= 0:
		return false
	if player != TurnManager.get_current_player():
		return false
	if player.deck == null or player.deck.is_empty():
		return false
	if player.hand == null:
		return false
	return player.hand.cards_in_hand.size() < player.hand.MAX_HAND_SIZE
