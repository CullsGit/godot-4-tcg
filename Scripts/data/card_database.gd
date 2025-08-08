extends Node

var cards: Dictionary = {}

func _ready() -> void:
	var dir = DirAccess.open("res://Resources/Cards")
	if dir:
		for file in dir.get_files():
			if file.ends_with(".remap"):
				file = file.trim_suffix(".remap")
			if file.ends_with(".tres"):
				var data = ResourceLoader.load("res://Resources/Cards/%s" % file)
				cards[data.id] = data


func get_cards_by_type(type_filter: String) -> Array:
	var matches: Array = []
	for data in cards.values():
		if data.type == type_filter:
			matches.append(data)
	return matches


func get_card_data(card_id: String) -> CardData:
	if cards.has(card_id):
		return cards[card_id]
	push_error("CardDatabase: no CardData for id '%s'" % card_id)
	return null
