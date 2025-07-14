extends Node

signal match_ended(winner_index: int)

func _ready() -> void:
	AttackManager.card_defeated.connect(_on_card_defeated)

func _on_card_defeated(defeated_card: Card) -> void:
	var loser = defeated_card.card_owner
	if _check_loss(loser):
		# Find loser’s index, then the other player is +1 mod 2
		var idx = TurnManager.players.find(loser)
		var winner_index = (idx + 1) % TurnManager.players.size()
		emit_signal("match_ended", winner_index)


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
