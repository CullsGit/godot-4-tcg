extends HBoxContainer

var hand_cards: Array = []
const MAX_HAND_SIZE = 5
var selected_card: Card = null  # Stores the currently selected card

func add_card(card: Card):
	if hand_cards.size() < MAX_HAND_SIZE:
		hand_cards.append(card)
		add_child(card)  # Add visually

		# Connect the card's selection signal
		card.card_selected.connect(_on_card_selected)

func _on_card_selected(card: Card):
	var game_manager = %GameManager
	game_manager.select_card(card)  # Only selects hand card


func remove_card(card):
	if card in hand_cards:
		print("Removing card from hand:", card.card_type)
		hand_cards.erase(card)  # Remove from the list
		remove_child(card)  # Remove from UI
