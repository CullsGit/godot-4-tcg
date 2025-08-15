extends Control
class_name Slot

signal slot_clicked(slot: Slot)

var placed_card: Card = null 

@export var slot_index: int


func is_empty():
	return placed_card == null

func get_board() -> Control:
	return get_parent().get_parent()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		emit_signal("slot_clicked", self, event.button_index)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or data.get("type","") != "card":
		return false

	var context = data.context
	
	if context == Card.CardContext.HAND:
		return is_empty() and get_board() == BoardManager.current_player.board
	else:
		return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var card: Card = data.card
	var context = data.context

	if context == Card.CardContext.HAND:
		BoardManager.place_from_hand(card, self)
	else:
		# Move an on-board card; need from_slot and to_slot
		var from_slot: Slot = data.origin_slot
		if from_slot == null and card.get_parent() is Slot:
			from_slot = card.get_parent()  # fallback if not set
		if from_slot:
			BoardManager.move_card(from_slot, self)

	# Make sure the real card shows after the manager re-parents it
	card.visible = true


func highlight():
	$Panel.modulate = Color(0.6, 1, 0.6)


func unhighlight():
	$Panel.modulate = Color(1, 1, 1, 0.6)
