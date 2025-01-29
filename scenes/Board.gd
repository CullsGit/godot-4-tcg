extends Node2D

var player_deck
var opponent_deck

var selected_card = null


# Called when the node enters the scene tree for the first time.
func _ready():
	player_deck = $PlayerDeck
	opponent_deck = $OpponentDeck


	var player_hand_node = $PlayerHand
	for card_data in player_deck.hand:
		var card = preload("res://scenes/Card.tscn").instantiate()
		card.set_type(card_data["type"])
		card.connect("gui_input", Callable(self, "_on_card_gui_input").bind(card))
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

func _on_card_gui_input(event, card):
	if event is InputEventMouseButton and event.pressed:
		print("Card clicked:", card)
		if selected_card and selected_card != card:
			selected_card.reset_selection()
		selected_card = card
		selected_card._on_card_pressed()
		print("Selected Card Type:", selected_card.type)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
