extends Control

var cards_in_hand: Array = []
const MAX_HAND_SIZE = 5

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees := 10
@export var x_sep := -35
@export var y_min := 50
@export var y_max := -50

func add_card(card: Card) -> void:
	if cards_in_hand.size() < MAX_HAND_SIZE:
		card.card_context = Card.CardContext.HAND
		card.scale = Vector2(1.6, 1.6)
		cards_in_hand.append(card)
		add_child(card)
		_update_card_fanning()

func remove_card(card):
	if card in cards_in_hand:
		cards_in_hand.erase(card)
		remove_child(card)
		_update_card_fanning()


func _update_card_fanning() -> void:
	if cards_in_hand.is_empty():
		return
	
	var single_card_width = cards_in_hand[0].size.x
	var cards = cards_in_hand.size()
	var all_cards_size = single_card_width * cards + x_sep * (cards - 1)
	var final_x_sep := x_sep
	
	if all_cards_size > size.x:
		final_x_sep = (size.x - single_card_width * cards) / (cards - 1)
		all_cards_size = size.x
		
	var offset = (size.x - all_cards_size) / 2
	
	for i in cards:
		var card = cards_in_hand[i]
		var y_multiplier = hand_curve.sample(1.0 / (cards-1) * i)
		var rot_multiplier = rotation_curve.sample(1.0 / (cards-1) * i)
		
		if cards == 1:
			y_multiplier = 0.0
			rot_multiplier = 0.0
		
		var final_x: float = offset + single_card_width * i + final_x_sep * i
		var final_y: float = y_min + y_max * y_multiplier
		
		card.position = Vector2(final_x, final_y)
		card.hand_card_base_position = Vector2(final_x, final_y) # Store for hover reset
		card.rotation_degrees = max_rotation_degrees * rot_multiplier
