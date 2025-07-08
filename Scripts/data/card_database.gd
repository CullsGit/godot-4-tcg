extends Node

var cards: Dictionary = {}

func _ready() -> void:
	var dir = DirAccess.open("res://Resources/Cards")
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tres"):
				var data = ResourceLoader.load("res://Resources/Cards/%s" % file)
				cards[data.id] = data

func get_cards_by_type(type_filter: String) -> Array:
	var matches: Array = []
	for data in cards.values():
		if data.type == type_filter:
			matches.append(data)
	return matches
