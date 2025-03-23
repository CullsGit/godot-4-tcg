extends Control

@export var card_scene: PackedScene 
@export var hand_node: Node  


var deck = []
const CARD_TYPES = ["Tank", "Damage", "Magic"]

func _ready():
	generate_deck()
	shuffle_deck()
	draw_starting_hand()
	update_deck_counter()

func generate_deck():
	deck.clear()
	for type in CARD_TYPES:
		for i in range(5):
			var card = card_scene.instantiate()
			card.card_type = type
			deck.append(card)

func shuffle_deck():
	deck.shuffle()

func draw_starting_hand():
	for i in range(5):
		draw_card(true)

func draw_card(starting_hand := false):
	var game_manager = %GameManager
	var current_hand = game_manager.get_current_hand()

	# Allow drawing if it's the current player's turn OR if drawing the starting hand
	if deck.size() > 0 and (starting_hand or current_hand == hand_node) and hand_node.hand_cards.size() < 5:
		var drawn_card = deck.pop_front()
		hand_node.add_card(drawn_card)
		update_deck_counter()

		# Only consume an action if NOT drawing starting hand
		if not starting_hand:
			var action_manager = %ActionManager
			action_manager.use_action()
	else:
		print("❌ Cannot draw a card: Either the deck is empty, hand is full, or it's not your turn.")

func update_deck_counter():
	$DeckCounter.text = str(deck.size())

func _on_deck_visual_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		draw_card()
