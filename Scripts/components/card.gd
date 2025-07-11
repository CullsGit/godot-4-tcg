# Scripts/components/card.gd
extends Panel
class_name Card

# === Exports & Variables ===
@export var card_id: String     # matches your CardData.id

# Stats loaded from CardDB
var card_name   : String
var type        : String
var ability     : String
var rarity      : String

# State flags
var is_selected   : bool = false
var is_activated  : bool = true
var bulwarked     : bool = false
var shrouding     : bool = false
var is_shrouded   : bool = false

# Tweens & Nodes
var hover_tween      : Tween
var bulwarked_tween  : Tween
var shrouding_tween  : Tween
var shrouded_tween   : Tween
@onready var image_node: TextureRect = $TextureRect

# Your existing signals
signal card_selected(card)
signal used_bulwark_ability(card)
signal used_shroud_ability(card)


# === Startup ===
func _ready() -> void:
	# 1) Fetch data from the singleton
	var data = CardDB.get_card_data(card_id)
	if data == null:
		push_error("CardData not found for id '%s'" % card_id)
		return

	# 2) Apply stats & art
	card_name = data.name               # node name, if you rely on it
	type      = data.type
	ability   = data.ability
	rarity    = data.rarity
	image_node.texture = ResourceLoader.load(data.texture_path)

	# 3) Wire up highlights/hover
	update_highlight()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# === Hover Effects ===
func _on_mouse_entered() -> void:
	hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)

func _on_mouse_exited() -> void:
	hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(self, "scale", Vector2.ONE, 0.4)


# === UI & Highlighting ===
func update_highlight() -> void:
	var mod = Color(1,1,1,1)
	if not is_activated:
		mod.a = 0.3
	elif is_selected:
		mod = Color(1.5,1.5,1.5,1)
	$TextureRect.modulate = mod


# === Input & Abilities ===
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("card_selected", self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and is_activated:
			match ability:
				"Bulwark": emit_signal("used_bulwark_ability", self)
				"Shroud":  emit_signal("used_shroud_ability", self)


# === State Toggles ===
func set_activated(value: bool) -> void:
	is_activated = value
	update_highlight()

func toggle_selection() -> void:
	is_selected = not is_selected
	update_highlight()

func toggle_bulwarked() -> void:
	bulwarked = not bulwarked
	bulwarked_tween = create_tween()
	var tr = $TextureRect
	if bulwarked:
		bulwarked_tween.tween_property(tr, "self_modulate", Color(1,0,0,1), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		bulwarked_tween.tween_property(tr, "scale", Vector2(1.14,1.14), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		bulwarked_tween.tween_property(tr, "self_modulate", Color(1,1,1,1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		bulwarked_tween.tween_property(tr, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func toggle_shrouding() -> void:
	shrouding = not shrouding
	shrouding_tween = create_tween()
	var tr = $TextureRect
	if shrouding:
		shrouding_tween.tween_property(tr, "self_modulate", Color(1,0,1,1), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		shrouding_tween.tween_property(tr, "scale", Vector2(1.14,1.14), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		shrouding_tween.tween_property(tr, "self_modulate", Color(1,1,1,1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		shrouding_tween.tween_property(tr, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func toggle_shrouded() -> void:
	is_shrouded = not is_shrouded
	shrouded_tween = create_tween()
	var tr = $TextureRect
	if is_shrouded:
		shrouded_tween.tween_property(tr, "self_modulate", Color.BLACK, 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		shrouded_tween.tween_property(tr, "self_modulate", Color(1,1,1,1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
