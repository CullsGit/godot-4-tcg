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
	if selected_card == card:
		card.toggle_selection()  # Unhighlight
		selected_card = null
	else:
		if selected_card:
			selected_card.toggle_selection()  # Unhighlight previous selection

		selected_card = card
		card.toggle_selection()  # Highlight new selection


func remove_card(card):
	if card in hand_cards:
		print("Removing card from hand:", card.card_type)
		hand_cards.erase(card)  # Remove from the list
		remove_child(card)  # Remove from UI
