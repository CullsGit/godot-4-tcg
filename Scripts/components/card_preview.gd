extends Panel

func setup_from_card(card: Card, preview_scale: float = 1.8) -> void:
	var texture_rect = $TextureRect
	texture_rect.texture = card.image_node.texture

	scale = Vector2.ONE * preview_scale
