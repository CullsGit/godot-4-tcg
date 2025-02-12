extends Node

@export var card_scene: PackedScene  # Assign "Card.tscn"
@export var hand_node: Node  # Assign "Hand"

var deck = []  # Store 20 shuffled cards
const CARD_TYPES = ["Tank", "Damage", "Magic", "Healer"]

func _ready():
	generate_deck()
	shuffle_deck()
	draw_starting_hand()  # Start with 5 visible cards

# 🔹 Generates 5 cards of each type
func generate_deck():
	deck.clear()
	for type in CARD_TYPES:
		for i in range(5):
			var card = card_scene.instantiate()
			card.card_type = type  # Assign type
			deck.append(card)

# 🔹 Shuffle the deck
func shuffle_deck():
	deck.shuffle()

# 🔹 Draw a card if the hand isn't full
func draw_card():
	if deck.size() > 0 and hand_node.hand_cards.size() < 5:
		var drawn_card = deck.pop_front()
		hand_node.add_card(drawn_card)  # Add the card to the hand

# 🔹 Draw 5 cards at the start of the game
func draw_starting_hand():
	for i in range(5):
		draw_card()
