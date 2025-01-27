extends Panel


enum CardType { RED, BLUE, GREEN, YELLOW }
var type: CardType

func set_type(new_type: CardType):
	type = new_type
	match type:
		CardType.RED: $ColorRect.color = Color(1, 0, 0)
		CardType.BLUE: $ColorRect.color = Color(0, 0, 1)
		CardType.GREEN: $ColorRect.color = Color(0, 1, 0)
		CardType.YELLOW: $ColorRect.color = Color(0.5, 0, 1)
