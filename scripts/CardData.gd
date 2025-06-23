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
		"image_path": "res://assets/game_cards/Andhor.jpg",
		"ability": "Dash",
	},
		{
		"name": "Daeseek",
		"type": "Void",
		"image_path": "res://assets/game_cards/Daeseek.jpg",
		"ability": "Strafe",
	},
		{
		"name": "Drav",
		"type": "Fury",
		"image_path": "res://assets/game_cards/Drav.jpg",
		"ability": "Overpower",
	},
		{
		"name": "Fangah",
		"type": "Fury",
		"image_path": "res://assets/game_cards/Fangah.jpg",
		"ability": "Dash",
	},
		{
		"name": "Galan",
		"type": "Aura",
		"image_path": "res://assets/game_cards/Galan.jpg",
		"ability": "Overstrike",
	},
		{
		"name": "Hagmar",
		"type": "Void",
		"image_path": "res://assets/game_cards/Hagmar.jpg",
		"ability": "Overpower",
	},
		{
		"name": "Phaestus",
		"type": "Aura",
		"image_path": "res://assets/game_cards/Phaestus.jpg",
		"ability": "Shroud",
	},
		{
		"name": "Ryia",
		"type": "Aura",
		"image_path": "res://assets/game_cards/Ryia.jpg",
		"ability": "Strafe",
	},
		{
		"name": "Sku",
		"type": "Aura",
		"image_path": "res://assets/game_cards/Sku.jpg",
		"ability": "Bulwark",
	},
		{
		"name": "Skyace",
		"type": "Void",
		"image_path": "res://assets/game_cards/Skyace.jpg",
		"ability": "Bulwark",
	},
		{
		"name": "Taeg",
		"type": "Fury",
		"image_path": "res://assets/game_cards/Taeg.jpg",
		"ability": "Strafe",
	},
		{
		"name": "Tsula",
		"type": "Void",
		"image_path": "res://assets/game_cards/Tsula.jpg",
		"ability": "Shroud",
	},
		{
		"name": "Tsuma",
		"type": "Aura",
		"image_path": "res://assets/game_cards/Tsuma.jpg",
		"ability": "Dash",
	},
		{
		"name": "Tsuvck",
		"type": "Fury",
		"image_path": "res://assets/game_cards/Tsuvck.jpg",
		"ability": "Shroud",
	},
		{
		"name": "Vaeri",
		"type": "Fury",
		"image_path": "res://assets/game_cards/Vaeri.jpg",
		"ability": "Overstrike",
	},
		{
		"name": "Vorisk",
		"type": "Void",
		"image_path": "res://assets/game_cards/Vorisk.jpg",
		"ability": "Overstrike",
	},
			{
		"name": "Vorn",
		"type": "Aura",
		"image_path": "res://assets/game_cards/Vorn.jpg",
		"ability": "Overpower",
	},
			{
		"name": "Zaos",
		"type": "Fury",
		"image_path": "res://assets/game_cards/Zaos.jpg",
		"ability": "Bulwark",
	}
	# Add as many cards as needed here!
]
