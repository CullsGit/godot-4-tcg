extends Control

var placed_card = null  # Stores the card placed in this slot

func is_empty():
	return placed_card == null  # Returns true if no card is placed

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var hand = get_tree().get_root().find_child("Hand", true, false)  # Find Hand globally
		if is_empty() and hand and hand.selected_card:
			place_card(hand.selected_card)
			hand.remove_card(hand.selected_card)

func place_card(card):
	placed_card = card  # Store the placed card
	var hand = get_tree().get_root().find_child("Hand", true, false)  # Find Hand globally

	if hand:
		hand.selected_card = null  # Deselect after placing
		hand.remove_card(card)  # Remove the card from the hand list

	# 🔹 Check if the card still has a parent before removing it
	if card.get_parent():
		card.get_parent().remove_child(card)  # Remove from hand safely
	
	add_child(card)  # Add to the slot
	card.position = Vector2.ZERO  # Align properly

func remove_card():
	if placed_card:
		placed_card = null  # Clear the slot reference, but do NOT delete the card
