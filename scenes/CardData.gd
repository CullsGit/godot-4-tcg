extends Node

# Example card data
var all_cards := [
	{
		"name": "Canto",
		"type": "Tank",
		"image_path": "res://assets/cards/cantobig.png",
		"ability": "Strafe",
	},
	{
		"name": "Faetum",
		"type": "Damage",
		"image_path": "res://assets/cards/faetumresize.png",
		"ability": "Overpower",
	},
	{
		"name": "Fortis",
		"type": "Magic",
		"image_path": "res://assets/cards/fortis2x.png",
		"ability": "Dash",
	}
	# Add as many cards as needed here!
]

func get_cards_by_type(card_type: String) -> Array:
	return all_cards.filter(func(card): return card["type"] == card_type)

func get_random_card() -> Dictionary:
	return all_cards[randi() % all_cards.size()]
