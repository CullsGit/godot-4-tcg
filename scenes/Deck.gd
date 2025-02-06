extends Node

# Holds the deck of cards
var deck: Array = []

# Card types with associated colors
const CARD_TYPES = {
	"Tank": Color.BLUE,
	"Damage": Color.RED,
	"Magic": Color.GREEN,
	"Healer": Color.PURPLE
}

# Reference to the card scene
@export var card_scene: PackedScene  

func _ready():
	generate_deck()
	shuffle_deck()

# 🔹 Generates 5 cards of each type
func generate_deck():
	deck.clear()  # Reset deck

	for type in CARD_TYPES.keys():
		for i in range(5):  # Add 5 of each type
			var card = card_scene.instantiate()
			card.card_type = type
			card.card_color = CARD_TYPES[type]
			deck.append(card)

# 🔹 Shuffles the deck randomly
func shuffle_deck():
	deck.shuffle()
