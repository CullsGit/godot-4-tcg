extends Node2D

var player_deck
var opponent_deck


# Called when the node enters the scene tree for the first time.
func _ready():
	player_deck = $PlayerDeck
	opponent_deck = $OpponentDeck
	print(player_deck.deck)
	
	var player_hand_node = $PlayerHand
	for card_data in player_deck.hand:
		var card = preload("res://scenes/Card.tscn").instantiate()
		card.set_type(card_data["type"])
		player_hand_node.add_child(card)
		
	var opponent_hand_node = $OpponentHand
	for card_data in opponent_deck.hand:
		var card = preload("res://scenes/Card.tscn").instantiate()
		card.set_type(card_data["type"])
		opponent_hand_node.add_child(card)
	
	for i in range(9):
		var slot = $PlayerBoard.get_child(i)
		var empty_card = preload("res://scenes/Card.tscn").instantiate()
		slot.add_child(empty_card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
