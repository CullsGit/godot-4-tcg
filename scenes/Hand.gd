extends HBoxContainer

var hand_cards: Array = []  # Stores drawn cards
const MAX_HAND_SIZE = 5  # Max cards allowed in hand

# 🔹 Adds a drawn card to the player's hand
func add_card(card):
	if hand_cards.size() < MAX_HAND_SIZE:
		hand_cards.append(card)  # Store reference in hand
		add_child(card)  # Add to UI
		print("Card added to hand:", card.card_type)
	else:
		print("Hand is full!")
