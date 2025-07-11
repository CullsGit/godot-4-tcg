extends Control
class_name Slot

signal slot_clicked(slot: Slot)

var placed_card: Card = null 

@export var slot_index: int


func is_empty():
	return placed_card == null


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("slot_clicked", self)


func highlight():
	$Panel.modulate = Color(0.6, 1, 0.6)


func unhighlight():
	$Panel.modulate = Color(1, 1, 1, 0.6)
