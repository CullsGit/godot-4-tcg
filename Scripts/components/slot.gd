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


func highlight():
	$Panel.modulate = Color(0.6, 1, 0.6)


func unhighlight():
	$Panel.modulate = Color(1, 1, 1, 0.6)
