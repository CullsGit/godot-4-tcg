extends Panel

enum CardType { RED, BLUE, GREEN, PURPLE }

var type: CardType
var selected: bool = false

func set_type(new_type: CardType):
	type = new_type
	match type:
		CardType.RED: $ColorRect.color = Color(1, 0, 0)
		CardType.BLUE: $ColorRect.color = Color(0, 0, 1)
		CardType.GREEN: $ColorRect.color = Color(0, 1, 0)
		CardType.PURPLE: $ColorRect.color = Color(0.5, 0, 0.5)

func _on_card_pressed():
	selected = !selected
	update_visual_state()

func update_visual_state():
	if selected:
		modulate = modulate.lightened(0.3)
	else:
		modulate = modulate.darkened(0.3)


func reset_selection():
	selected = false
	update_visual_state()

func _on_card_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed:
		print("Card detected a click!")
		_on_card_pressed()
