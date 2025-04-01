extends Control

@export var card_scene: PackedScene 
@export var hand_node: Node  

var deck = []
const CARD_TYPES = ["Tank", "Damage", "Magic"]

# Dictionary mapping card types to three different asset paths
const CARD_ASSETS = {
	"Tank": ["res://assets/cantobig.png"],
	"Damage": ["res://assets/faetumresize.png"],
	"Magic": ["res://assets/fortis2x.png"]
}

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
			card.card_asset = load(CARD_ASSETS[type][0])
			card.card_selected.connect(%GameManager.select_card)
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

		if not starting_hand:
			var action_manager = %ActionManager
			action_manager.use_action()

func update_deck_counter():
	$DeckCounter.text = str(deck.size())

func _on_deck_visual_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		draw_card()
