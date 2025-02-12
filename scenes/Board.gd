extends Control

@onready var grid = $Grid  # Reference to GridContainer

@export var slot_scene: PackedScene  # Assign `Slot.tscn` in Inspector
@export var card_scene: PackedScene  # Assign `Card.tscn` in Inspector

var slots = []  # List of all slots on the board

func _ready():
	# Store slot references
	for child in grid.get_children():
		if child is Control:
			slots.append(child)
	
	# Manually place cards for testing
	place_test_cards()

func move_card(current_slot, direction):
	var slot_index = slots.find(current_slot)

	if slot_index == -1:
		return  # Slot not found

	var target_index = get_target_index(slot_index, direction)

	if target_index == -1:
		return  # No valid move

	var target_slot = slots[target_index]

	if target_slot.is_empty():
		# Move the card correctly
		var moving_card = current_slot.placed_card
		if moving_card == null:
			return  # No card to move
			
		current_slot.remove_card()
		
		if moving_card.get_parent():
			moving_card.get_parent().remove_child(moving_card)
		# Reparent the card to the new slot
		target_slot.add_child(moving_card)
		target_slot.placed_card = moving_card

func get_target_index(slot_index, direction):
	var row = slot_index / 3  # Get row index
	var col = slot_index % 3  # Get column index

	match direction:
		"left":
			if col > 0:
				return slot_index - 1
		"right":
			if col < 2:
				return slot_index + 1
		"up":
			if row > 0:
				return slot_index - 3
		"down":
			if row < 2:
				return slot_index + 3
	
	return -1  # Invalid move

func place_test_cards():
	var test_card1 = card_scene.instantiate()
	test_card1.card_type = "Tank"
	grid.get_child(0).place_card(test_card1)  # Blue for Tank
	
	slots[0].place_card(test_card1)  # Top-left slot

	# Move the card to the right after 2 seconds
	await get_tree().create_timer(2.0).timeout
	move_card(slots[0], "right")
