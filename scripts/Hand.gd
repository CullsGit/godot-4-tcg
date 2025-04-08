extends HBoxContainer

var hand_cards: Array = []
const MAX_HAND_SIZE = 5

func add_card(card: Card):
	if hand_cards.size() < MAX_HAND_SIZE:
		hand_cards.append(card)
		add_child(card)  # Add visually

func remove_card(card):
	if card in hand_cards:
		hand_cards.erase(card)  # Remove from the list
		remove_child(card)  # Remove from UI
