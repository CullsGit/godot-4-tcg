extends Panel  # Card is a Panel
class_name Card

@export var card_type: String = ""  # Card type
@export var card_asset: Texture

var is_selected = false  # Track selection state
var is_activated = true


signal card_selected(card)  # Signal when card is selected
var tween: Tween

func _ready():
	update_visual()
	update_highlight()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	reset_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)

func _on_mouse_exited():
	reset_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)

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

func reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()
