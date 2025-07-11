extends Node

# (retain whatever signals you need for match_ended)
signal match_ended(winner_index: int)

#func _ready() -> void:
	# … your other wiring …

	# Instead of checking on turn start, listen for defeated cards
	# (Assumes you emit `card_defeated(defeated_card)` in your combat resolution)

# This runs whenever a card dies
func _on_card_defeated(defeated_card: Card) -> void:
	var loser = defeated_card.get_owner()
	if _check_loss(loser):
		# Whoever’s *not* the loser is the winner
		var winner = TurnManager.players.find_all(lambda p: p != loser)[0]
		var wi = TurnManager.players.find(winner)
		emit_signal("match_ended", wi)

# Returns true if the given player has *no* cards in hand, deck, or on their board
func _check_loss(player: Node) -> bool:
	# 1) Hand
	var has_hand = player.hand.hand_cards.size() > 0
	# 2) Deck
	var has_deck = not player.deck.is_empty()
	# 3) Board
	var has_board = false
	for slot in player.board.get_children():
		if slot.has_node("Card"):
			has_board = true
			break
	# If they have none of these, they’ve lost
	return not (has_hand or has_deck or has_board)
