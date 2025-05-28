extends GutTest

# Define mock classes for testing
class DummySlot:
	var placed_card = null
	var slot_index = 0
	var is_player1 = true

	func _init(_idx=0, _player1=true):
		slot_index = _idx
		is_player1 = _player1

	func is_empty():
		return placed_card == null

	func highlight():
		pass

	func unhighlight():
		pass

class DummyCard:
	var bulwarked = false
	var shrouding = false
	var card_ability = ""
	var get_parent_called = false

	func get_parent():
		get_parent_called = true
		return null
