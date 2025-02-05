extends Control

var placed_card = null  # Store the card in this slot

# Function to check if the slot is empty
func is_empty() -> bool:
	return placed_card == null

# Function to place a card in this slot
func place_card(card):
	if is_empty():
		placed_card = card
		add_child(card)  # Add card as a child of the slot
		card.position = Vector2.ZERO
		return true
	return false

# Function to remove a card from this slot
func remove_card():
	if placed_card:
		placed_card = null  # Only clear the slot, don't delete the card
