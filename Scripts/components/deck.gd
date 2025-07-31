extends Control

@export var card_scene    : PackedScene
@onready var player : Player = get_parent()

const CARD_TYPES          : Array[String] = ["Void", "Fury", "Aura"]
const COPIES_PER_TYPE     : int = 6
const STARTING_HAND_SIZE  : int = 5

var _deck : Array = []

func _ready() -> void:
	generate_deck()
	shuffle_deck()
	await get_tree().process_frame
	draw_starting_hand()
	update_deck_counter()


func generate_deck() -> void:
	_deck.clear()
	# Build a pool of CardData for each type
	for type in CARD_TYPES:
		var cards_of_type = CardDB.get_cards_by_type(type)
		cards_of_type.shuffle()
		# Take COPIES_PER_TYPE from each, cycling if needed
		for i in COPIES_PER_TYPE:
			var data = cards_of_type[i % cards_of_type.size()]
			var card = card_scene.instantiate()
			card.card_id = data.id
			card.card_owner = player
			card.card_selected.connect(UIManager.on_card_selected)
			card.use_ability.connect(UIManager.on_use_card_ability)
			_deck.append(card)


func shuffle_deck() -> void:
	_deck.shuffle()


func draw_starting_hand() -> void:
	for _i in STARTING_HAND_SIZE:
		draw_card(true)


func draw_card(starting_hand := false) -> void:
	if _deck.is_empty():
		return

	if starting_hand:
		player.hand.add_card(_deck.pop_front())
		update_deck_counter()
		return

	if player != TurnManager.get_current_player():
		return

	if player.hand.cards_in_hand.size() >= player.hand.MAX_HAND_SIZE:
		return

	player.hand.add_card(_deck.pop_front())
	update_deck_counter()

	ActionManager.use_action()


func update_deck_counter() -> void:
	$DeckCounter.text = str(_deck.size())


func _on_deck_visual_gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		draw_card()


func is_empty() -> bool:
	return _deck.size() == 0
