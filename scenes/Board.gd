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

func place_test_cards():
	var test_card1 = card_scene.instantiate()
	test_card1.card_type = "Tank"
	test_card1.card_color = Color.BLUE  # Blue for Tank

	var test_card2 = card_scene.instantiate()
	test_card2.card_type = "Damage"
	test_card2.card_color = Color.RED  # Red for Damage

	# Place them in specific slots
	slots[0].place_card(test_card1)  # Top-left slot
	slots[4].place_card(test_card2)  # Center slot
