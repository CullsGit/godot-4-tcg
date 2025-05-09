extends Control

@export var card_scene: PackedScene 
@export var hand_node: Node  

var deck = []
const CARD_TYPES = ["Void", "Fury", "Aura"]

func _ready():
	generate_deck()
	shuffle_deck()
	draw_starting_hand()
	update_deck_counter()

func generate_deck():
	deck.clear()
	for type in CARD_TYPES:
		var cards_of_type = CardData.get_cards_by_type(type)
		cards_of_type.shuffle()

		for i in range(6):  # Adjust the number of each type
			var card_data = cards_of_type[i % cards_of_type.size()]
			var card = card_scene.instantiate()
			card.setup(card_data)  # New setup method in Card.gd
			card.card_selected.connect(%GameManager.select_card)
			card.use_bulwark_ability.connect(%GameManager.bulwarked)
			card.use_shroud_ability.connect(%GameManager.shrouding)
			deck.append(card)

func shuffle_deck():
	deck.shuffle()

func draw_starting_hand():
	for i in range(5):
		draw_card(true)

func draw_card(starting_hand := false):
	var game_manager = %GameManager
	var current_hand = game_manager.get_current_hand()
	var current_board = game_manager.get_current_board()

	# Allow drawing if it's the current player's turn OR if drawing the starting hand
	if deck.size() > 0 and (starting_hand or current_hand == hand_node) and hand_node.hand_cards.size() < 5:
		var drawn_card = deck.pop_front()
		hand_node.add_card(drawn_card)
		update_deck_counter()

		if not starting_hand:
			game_manager.deselect_all_cards()
			current_board.clear_all_slot_highlights()
			var action_manager = %ActionManager
			action_manager.use_action()

func update_deck_counter():
	$DeckCounter.text = str(deck.size())

func _on_deck_visual_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		draw_card()
