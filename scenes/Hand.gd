extends HBoxContainer

var hand_cards: Array = []
const MAX_HAND_SIZE = 5
var selected_card = null  # Store the currently selected card

func add_card(card):
	if hand_cards.size() < MAX_HAND_SIZE:
		hand_cards.append(card)
		add_child(card)  # Add visually
		card.connect("gui_input", Callable(self, "_on_card_clicked").bind(card))  # Handle clicks

func _on_card_clicked(event, card):
	if event is InputEventMouseButton and event.pressed:
		selected_card = card
		print("Selected card:", selected_card.card_type)

func remove_card(card):
	if card in hand_cards:
		hand_cards.erase(card)  # Remove from the list
		remove_child(card)  # Remove from UI
