extends Panel
class_name Card

# === Exports & Variables ===
@export var card_id: String
@export var card_owner: Player

var hover_preview_scene = preload("res://Scenes/CardPreview.tscn")
var hover_preview_instance: Control

enum CardContext { HAND, BOARD }
var card_context: CardContext = CardContext.HAND
var hand_card_base_position: Vector2

# Stats loaded from CardDB
var card_name        : String
var card_type        : String
var card_ability     : String
var card_rarity      : String

# State flags
var is_selected   : bool = false
var deactivated   : bool = false
var bulwarked     : bool = false
var shrouding     : bool = false
var shrouded      : bool = false

# Tweens & Nodes
var hover_tween      : Tween
var bulwarked_tween  : Tween
var shrouding_tween  : Tween
var shrouded_tween   : Tween
@onready var image_node: TextureRect = $TextureRect

# Your existing signals
signal card_selected(card)
signal use_ability(card: Card, ability: String)

var _is_dragging = false
var _drop_accepted = false

func _ready() -> void:
	# 1) Fetch data from the singleton
	var data = CardDB.get_card_data(card_id)
	if data == null:
		push_error("CardData not found for id '%s'" % card_id)
		return

	# 2) Apply stats & art
	card_name = data.name
	card_type = data.type
	card_ability = data.ability
	card_rarity = data.rarity
	image_node.texture = ResourceLoader.load(data.texture_path)

	# 3) Wire up highlights/hover
	update_highlight()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# === Hover Effects ===
func _on_mouse_entered() -> void:
	if hover_tween:
		hover_tween.kill()
	
	match card_context:
		CardContext.HAND:
			hover_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			hover_tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.15)

			if hover_preview_instance == null:
				hover_preview_instance = hover_preview_scene.instantiate()
				hover_preview_instance.setup_from_card(self, 2)

				var hover_layer = card_owner.hand.hover_card_root
				hover_layer.add_child(hover_preview_instance)

				var hand_global_pos = card_owner.hand.get_global_position()
				var hand_size = card_owner.hand.size

				var x = hand_global_pos.x + hand_size.x / 2.0 - 64
				var y = hand_global_pos.y - 300

				hover_preview_instance.global_position = Vector2(x, y) - hover_preview_instance.size / 2.0

		CardContext.BOARD:
			hover_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)


func _on_mouse_exited() -> void:
	if hover_tween:
		hover_tween.kill()
	
	
	match card_context:
		CardContext.HAND:
			hover_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			hover_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)

			if hover_preview_instance:
				var hover_layer = card_owner.hand.hover_card_root
				hover_layer.remove_child(hover_preview_instance)
				hover_preview_instance = null

		CardContext.BOARD:
			hover_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			hover_tween.tween_property(self, "scale", Vector2.ONE, 0.1)


# === UI & Highlighting ===
func update_highlight() -> void:
	var mod = Color(1,1,1,1)
	if deactivated:
		mod.a = 0.3
	elif is_selected:
		mod = Color(1.5,1.5,1.5,1)
	$TextureRect.modulate = mod


# === Input & Abilities ===
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			card_selected.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and is_selected:
			match card_ability:
				"Bulwark": use_ability.emit(self, "Bulwark")
				"Shroud":  use_ability.emit(self, "Shroud")

func is_locked() -> bool:
	return deactivated or shrouded or bulwarked or shrouding

func toggle_selection() -> void:
	is_selected = not is_selected
	update_highlight()

func toggle_bulwarked() -> void:
	bulwarked = not bulwarked
	bulwarked_tween = create_tween()
	if bulwarked:
		bulwarked_tween.tween_property(image_node, "self_modulate", Color(1,0.9,0,1), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		bulwarked_tween.tween_property(image_node, "scale", Vector2(1.14,1.14), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		bulwarked_tween.tween_property(image_node, "self_modulate", Color(1,1,1,1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		bulwarked_tween.tween_property(image_node, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func toggle_shrouding() -> void:
	shrouding = not shrouding
	shrouding_tween = create_tween()
	if shrouding:
		shrouding_tween.tween_property(image_node, "self_modulate", Color(0.741,0.455,1,1), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		shrouding_tween.tween_property(image_node, "scale", Vector2(1.14,1.14), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		shrouding_tween.tween_property(image_node, "self_modulate", Color(1,1,1,1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		shrouding_tween.tween_property(image_node, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func toggle_shrouded() -> void:
	shrouded = not shrouded
	shrouded_tween = create_tween()
	if shrouded:
		shrouded_tween.tween_property(image_node, "self_modulate", Color.BLACK, 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		shrouded_tween.tween_property(image_node, "self_modulate", Color(1,1,1,1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if is_locked() or card_owner != TurnManager.get_current_player():
		return

	_is_dragging = true

	var data := {
		"type": "card",
		"card": self,
		"context": card_context,
		"origin_slot": null
	}
	
	if card_context == CardContext.BOARD:
		data.origin_slot = get_parent()

	var preview: Control = duplicate()
	
	set_drag_preview(preview)
	
	if !is_selected:
		card_selected.emit(self)

	visible = false
	return data

func _notification(code: int) -> void:
	if code == NOTIFICATION_DRAG_END:
		visible = true
		if not _drop_accepted and is_selected:
			UIManager.deselect_all_cards()
