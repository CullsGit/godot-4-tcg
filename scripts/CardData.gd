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
		"image_path": "res://assets/cards/Andhor.png",
		"ability": "Dash",
	},
		#{
		#"name": "Daeseek",
		#"type": "Void",
		#"image_path": "res://assets/cards/Daeseek.png",
		#"ability": "Strafe",
	#},
		#{
		#"name": "Drav",
		#"type": "Fury",
		#"image_path": "res://assets/cards/Drav.png",
		#"ability": "Overpower",
	#},
		#{
		#"name": "Fangah",
		#"type": "Fury",
		#"image_path": "res://assets/cards/Fangah.png",
		#"ability": "Dash",
	#},
		#{
		#"name": "Galan",
		#"type": "Aura",
		#"image_path": "res://assets/cards/Galan.png",
		#"ability": "Overstrike",
	#},
		#{
		#"name": "Hagmar",
		#"type": "Void",
		#"image_path": "res://assets/cards/Hagmar.png",
		#"ability": "Overpower",
	#},
		{
		"name": "Phaestus",
		"type": "Aura",
		"image_path": "res://assets/cards/Phaestus.png",
		"ability": "Shroud",
	},
		#{
		#"name": "Ryia",
		#"type": "Aura",
		#"image_path": "res://assets/cards/Ryia.png",
		#"ability": "Strafe",
	#},
		#{
		#"name": "Sku",
		#"type": "Aura",
		#"image_path": "res://assets/cards/Sku.png",
		#"ability": "Bulwark",
	#},
		#{
		#"name": "Skyace",
		#"type": "Void",
		#"image_path": "res://assets/cards/Skyace.png",
		#"ability": "Bulwark",
	#},
		#{
		#"name": "Taeg",
		#"type": "Fury",
		#"image_path": "res://assets/cards/Taeg.png",
		#"ability": "Strafe",
	#},
		#{
		#"name": "Tors",
		#"type": "Void",
		#"image_path": "res://assets/cards/Tors.png",
		#"ability": "Overstrike",
	#},
		#{
		#"name": "Tsula",
		#"type": "Void",
		#"image_path": "res://assets/cards/Tsula.png",
		#"ability": "Shroud",
	#},
		#{
		#"name": "Tsuma",
		#"type": "Aura",
		#"image_path": "res://assets/cards/Tsuma.png",
		#"ability": "Dash",
	#},
		{
		"name": "Tsuvck",
		"type": "Fury",
		"image_path": "res://assets/cards/Tsuvck.png",
		"ability": "Shroud",
	},
		#{
		#"name": "Vaeri",
		#"type": "Fury",
		#"image_path": "res://assets/cards/Vaeri.png",
		#"ability": "Overstrike",
	#},
			#{
		#"name": "Vorn",
		#"type": "Aura",
		#"image_path": "res://assets/cards/Vorn.png",
		#"ability": "Overpower",
	#},
			#{
		#"name": "Zoas",
		#"type": "Fury",
		#"image_path": "res://assets/cards/Zoas.png",
		#"ability": "Bulwark",
	#}
	# Add as many cards as needed here!
]
