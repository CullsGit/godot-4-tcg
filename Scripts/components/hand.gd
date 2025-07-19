extends HBoxContainer

var cards_in_hand: Array = []
const MAX_HAND_SIZE = 5

func add_card(card: Card) -> void:
	if cards_in_hand.size() < MAX_HAND_SIZE:
		cards_in_hand.append(card)
		add_child(card)

func remove_card(card):
	if card in cards_in_hand:
		cards_in_hand.erase(card)  # Remove from the list
		remove_child(card)  # Remove from UI
