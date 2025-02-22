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
	

func move_card(current_slot, direction):

	var slot_index = slots.find(current_slot)

	if slot_index == -1:
		return  # Slot not found

	var target_index = get_target_index(slot_index, direction)

	if target_index == -1:
		return  # No valid move

	var target_slot = slots[target_index]

	if target_slot.is_empty():
		var moving_card = current_slot.placed_card
		if moving_card == null:
			return  # No card to move
			
		current_slot.placed_card = null  # Clear the old slot's reference
		if moving_card.get_parent():
			moving_card.get_parent().remove_child(moving_card)  # Remove card from old slot

		target_slot.add_child(moving_card)  # Move to new slot
		target_slot.placed_card = moving_card  # Update new slot reference
		moving_card.position = Vector2.ZERO  # Reset position after moving

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
