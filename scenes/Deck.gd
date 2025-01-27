extends Node

enum CardType { RED, BLUE, GREEN, PURPLE }

var deck = []
var hand = []

func _ready():
	# Initialize the deck with 5 cards of each type
	for i in range(5):
		deck.append({ "type": CardType.RED })
		deck.append({ "type": CardType.BLUE })
		deck.append({ "type": CardType.GREEN })
		deck.append({ "type": CardType.PURPLE })


	# Shuffle the deck
	shuffle_deck()
	
	# Draw 5 cards for the player's hand
	draw_initial_hand()

func shuffle_deck():
	# Godot's shuffle method randomizes the array
	deck.shuffle()

func draw_initial_hand():
	for i in range(5):
		hand.append(deck.pop_front())
