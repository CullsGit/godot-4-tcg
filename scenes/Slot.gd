extends Control

var placed_card = null  # Stores the card placed in this slot

func is_empty():
	return placed_card == null  # Returns true if no card is placed

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		
		var hand = get_tree().get_root().find_child("Hand", true, false)  # Find Hand globally
		if is_empty() and hand and hand.selected_card:
			var card_to_place = hand.selected_card
			if card_to_place.get_parent() == hand:
				hand.remove_card(card_to_place)
				hand.selected_card = null  # Deselect first
				place_card(card_to_place)
			elif card_to_place.get_parent().is_in_group("BoardSlot"):
				var current_slot = card_to_place.get_parent()
				var board = get_tree().get_root().find_child("Board", true, false)
				if board:
					board.move_card(current_slot, get_slot_direction(current_slot, self))
			else:
				print("This card can't be placed or moved.")


func place_card(card):
	placed_card = card  # Store the placed card

	# Remove card from previous parent safely
	if card.get_parent():
		card.get_parent().remove_child(card)

	add_child(card)  # Add to the slot
	card.position = Vector2.ZERO  # Align properly

	var action_manager = get_tree().get_root().find_child("ActionManager", true, false)
	action_manager.use_action()


	# 🔹 Ensure it is not highlighted anymore
	if card.has_method("toggle_selection"):
		card.toggle_selection()  # Deselect if highlighting is handled in `toggle_selection()`

func remove_card():
	if placed_card:
		if placed_card.get_parent():  # Ensure it has a parent before removing
			placed_card.get_parent().remove_child(placed_card)  # Properly remove from scene
		placed_card = null  # Clear reference

func get_slot_direction(from_slot, to_slot):
	var from_index = from_slot.get_index()
	var to_index = to_slot.get_index()

	var diff = to_index - from_index

	match diff:
		-1:
			return "left"
		1:
			return "right"
		-3:
			return "up"
		3:
			return "down"
		_:
			return ""  # Invalid move
