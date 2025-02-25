extends Control

@export var card_scene: PackedScene  # Card scene
@export var hand_node: Node  # Hand reference


var deck = []  # Store 20 shuffled cards
const CARD_TYPES = ["Tank", "Damage", "Magic", "Healer"]

func _ready():
	generate_deck()
	shuffle_deck()
	draw_starting_hand()
	update_deck_counter()

# 🔹 Generate 5 cards of each type
func generate_deck():
	deck.clear()
	for type in CARD_TYPES:
		for i in range(5):
			var card = card_scene.instantiate()
			card.card_type = type
			deck.append(card)

# 🔹 Shuffle deck
func shuffle_deck():
	deck.shuffle()

# 🔹 Draw starting hand (5 cards)
func draw_starting_hand():
	for i in range(5):
		draw_card(false)

# 🔹 Draw a card
func draw_card(consume_action := true):
	if deck.size() > 0 and hand_node.hand_cards.size() < 5:
		var drawn_card = deck.pop_front()
		hand_node.add_card(drawn_card)
		update_deck_counter()

	if consume_action:
		var action_manager = get_tree().get_root().find_child("ActionManager", true, false)
		action_manager.use_action()

# 🔹 Update deck counter
func update_deck_counter():
	$DeckCounter.text = str(deck.size())

func _on_deck_visual_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		draw_card()
