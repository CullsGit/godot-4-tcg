extends Node

func get_cards_by_type(card_type: String) -> Array:
	return all_cards.filter(func(card): return card["type"] == card_type)

func get_random_card() -> Dictionary:
	return all_cards[randi() % all_cards.size()]
# Example card data
var all_cards := [
	{
		"name": "Andhor",
		"type": "Void",
		"image_path": "res://assets/new_cards/Andhor.jpeg",
		"ability": "Dash",
	},
		{
		"name": "Daeseek",
		"type": "Void",
		"image_path": "res://assets/new_cards/Daeseek.jpeg",
		"ability": "Strafe",
	},
		{
		"name": "Drav",
		"type": "Fury",
		"image_path": "res://assets/new_cards/Drav.jpeg",
		"ability": "Overpower",
	},
		{
		"name": "Fangah",
		"type": "Fury",
		"image_path": "res://assets/new_cards/Fangah.png",
		"ability": "Dash",
	},
		{
		"name": "Galan",
		"type": "Aura",
		"image_path": "res://assets/new_cards/Galan.jpeg",
		"ability": "Overstrike",
	},
		{
		"name": "Hagmar",
		"type": "Void",
		"image_path": "res://assets/new_cards/Hagmar.jpeg",
		"ability": "Overpower",
	},
		{
		"name": "Phaestus",
		"type": "Aura",
		"image_path": "res://assets/new_cards/Phaestus.jpeg",
		"ability": "Shroud",
	},
		{
		"name": "Ryia",
		"type": "Aura",
		"image_path": "res://assets/new_cards/Ryia.jpeg",
		"ability": "Strafe",
	},
		{
		"name": "Sku",
		"type": "Aura",
		"image_path": "res://assets/new_cards/Sku.jpeg",
		"ability": "Bulwark",
	},
		{
		"name": "Skyace",
		"type": "Void",
		"image_path": "res://assets/new_cards/Skyace.jpeg",
		"ability": "Bulwark",
	},
		{
		"name": "Taeg",
		"type": "Fury",
		"image_path": "res://assets/new_cards/Taeg.jpeg",
		"ability": "Strafe",
	},
		{
		"name": "Vorisk",
		"type": "Void",
		"image_path": "res://assets/new_cards/Vorisk.jpeg",
		"ability": "Overstrike",
	},
		{
		"name": "Tsula",
		"type": "Void",
		"image_path": "res://assets/new_cards/Tsula.jpeg",
		"ability": "Shroud",
	},
		{
		"name": "Tsuma",
		"type": "Aura",
		"image_path": "res://assets/new_cards/Tsuma.jpeg",
		"ability": "Dash",
	},
		{
		"name": "Tsuvck",
		"type": "Fury",
		"image_path": "res://assets/new_cards/Tsuvck.jpeg",
		"ability": "Shroud",
	},
		{
		"name": "Vaeri",
		"type": "Fury",
		"image_path": "res://assets/new_cards/Vaeri.jpeg",
		"ability": "Overstrike",
	},
			{
		"name": "Vorn",
		"type": "Aura",
		"image_path": "res://assets/new_cards/Vorn.jpeg",
		"ability": "Overpower",
	},
			{
		"name": "Zoas",
		"type": "Fury",
		"image_path": "res://assets/new_cards/Zoas.jpeg",
		"ability": "Bulwark",
	}
	# Add as many cards as needed here!
]
