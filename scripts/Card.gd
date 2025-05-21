extends Panel  # Card is a Panel
class_name Card

@export var card_type: String
@export var card_ability: String
@export var card_asset: Texture
var card_data: Dictionary

var is_selected = false  # Track selection state
var is_activated = true
var bulwarked = false
var shrouding = false
var is_shrouded = false

signal card_selected(card)  # Signal when card is selected
signal used_bulwark_ability(card)
signal used_shroud_ability(card)
var hover_tween: Tween
var bulwarked_tween: Tween
var shrouding_tween: Tween
var shrouded_tween: Tween

func _ready():
	update_visual()
	update_highlight()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(data: Dictionary):
	card_data = data
	card_type = data["type"]
	card_ability = data["ability"]
	
	var img_path = data.get("image_path", '')
	if img_path != '' and ResourceLoader.exists(img_path):
		card_asset = load(data["image_path"])

	call_deferred("_apply_card_image")

func _apply_card_image():
	var image_node = $TextureRect
	if image_node:
		image_node.texture = card_asset
	else:
		push_error("TextureRect not found in Card scene!")

func _on_mouse_entered():
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)

func _on_mouse_exited():
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.4)

func update_visual():
	var texture_rect = $TextureRect
	if card_asset:
		texture_rect.texture = card_asset

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			card_selected.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and is_activated and card_ability == 'Bulwark':
			used_bulwark_ability.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and is_activated and card_ability == 'Shroud':
			used_shroud_ability.emit(self)

func set_activated(value: bool):
	is_activated = value
	update_highlight()

func toggle_shrouded():
	is_shrouded = !is_shrouded
	
	var texture_rect = $TextureRect
	shrouded_tween = create_tween()
	
	if is_shrouded:
		shrouded_tween.tween_property(texture_rect, "self_modulate", Color('black'), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		shrouded_tween.tween_property(texture_rect, "self_modulate", Color(1, 1, 1, 1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func toggle_selection():
	is_selected = !is_selected  # Toggle selection state
	update_highlight()  # Apply highlight immediately

func toggle_bulwarked():
	var texture_rect = $TextureRect

	bulwarked = !bulwarked
	bulwarked_tween = create_tween()
	
	if bulwarked:
		bulwarked_tween.tween_property(texture_rect, "self_modulate", Color(1, 0, 0, 1), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		bulwarked_tween.tween_property(texture_rect, "scale", Vector2(1.14, 1.14), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		bulwarked_tween.tween_property(texture_rect, "self_modulate", Color(1, 1, 1, 1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		bulwarked_tween.tween_property(texture_rect, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func toggle_shrouding():
	var texture_rect = $TextureRect

	shrouding = !shrouding
	shrouding_tween = create_tween()
	
	if shrouding:
		shrouding_tween.tween_property(texture_rect, "self_modulate", Color(1, 0, 1, 1), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		shrouding_tween.tween_property(texture_rect, "scale", Vector2(1.14, 1.14), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		shrouding_tween.tween_property(texture_rect, "self_modulate", Color(1, 1, 1, 1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		shrouding_tween.tween_property(texture_rect, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func update_highlight():
	var texture_rect = $TextureRect
	
	if not is_activated:
		texture_rect.modulate = Color(1, 1, 1, 0.3)  # Make it transparent-ish
	elif is_selected:
		texture_rect.modulate = Color(1.5, 1.5, 1.5, 1)  # Bright glow
	else:
		texture_rect.modulate = Color(1, 1, 1, 1)  # Normal
