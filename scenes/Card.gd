extends Control

# Card properties
@export var card_type: String  # "Tank", "Damage", "Magic", "Healer"
@export var card_color: Color  # The color representing the card

func _ready():
	modulate = card_color  # Change card color dynamically
