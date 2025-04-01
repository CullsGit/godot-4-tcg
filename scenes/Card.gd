extends Panel  # Card is a Panel
class_name Card

@export var card_type: String = ""  # Card type
@export var card_asset: Texture

var is_selected = false  # Track selection state
var is_activated = true


signal card_selected(card)  # Signal when card is selected

func _ready():
	update_visual()
	update_highlight()

func update_visual():
	var texture_rect = $TextureRect
	if card_asset:
		texture_rect.texture = card_asset

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		card_selected.emit(self)  # Notify Hand.gd that this card was clicked

func set_activated(value: bool):
	is_activated = value
	update_highlight()

func toggle_selection():
	is_selected = !is_selected  # Toggle selection state
	update_highlight()  # Apply highlight immediately

func update_highlight():
	var texture_rect = $TextureRect
	
	if not is_activated:
		texture_rect.modulate = Color(1, 1, 1, 0.3)  # Make it transparent-ish
	elif is_selected:
		texture_rect.modulate = Color(1.5, 1.5, 1.5, 1)  # Bright glow
	else:
		texture_rect.modulate = Color(1, 1, 1, 1)  # Normal
