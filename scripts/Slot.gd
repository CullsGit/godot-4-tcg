extends Control

var placed_card: Card = null 

@export var slot_index: int
@export var is_player1: bool


func is_empty():
	return placed_card == null

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var game_manager = %GameManager
		var current_board = game_manager.get_current_board()
		var board = self.get_parent().get_parent()

		# Ensure the slot belongs to the current board
		if board.get_instance_id() != current_board.get_instance_id():
			return
			
		var selected_hand_card = game_manager.selected_hand_card
		var selected_board_card = game_manager.selected_board_card

		if is_empty() and selected_hand_card:
			selected_hand_card.get_parent().remove_card(selected_hand_card)
			game_manager.selected_hand_card = null  # Clear hand selection
			place_card(selected_hand_card)
		elif selected_board_card and selected_board_card.get_parent().is_in_group("BoardSlot"):
			var current_slot = selected_board_card.get_parent()
			board.move_card(current_slot, get_slot_direction(current_slot, self))

func place_card(card):
	var board = get_parent().get_parent()
	var game_manager = %GameManager
	# Remove the card from the previous parent safely
	if card.get_parent():
		card.get_parent().remove_child(card)

	add_child(card)
	card.set_activated(false)
	card.position = Vector2.ZERO
	placed_card = card
	# Use an action
	var action_manager = %ActionManager
	action_manager.use_action()
	card.toggle_selection()
	game_manager.deselect_all_cards()
	board.check_opponent_cards_in_range(self)


func remove_card():
	if placed_card:
		placed_card.get_parent().remove_child(placed_card)
		placed_card = null

func get_slot_direction(from_slot, to_slot):
	var from_index = from_slot.slot_index
	var to_index = to_slot.slot_index
	var diff = to_index - from_index

	match diff:
		-1: return "left"
		1: return "right"
		-3: return "up"
		3: return "down"
		-4: return "up_left"
		-2: return "up_right"
		2: return "down_left"
		4: return "down_right"
		-6: return "back_to_front"
		6: return "front_to_back"
		_: return ""

func highlight():
	$Panel.modulate = Color(0.6, 1, 0.6)
func unhighlight():
	$Panel.modulate = Color(1, 1, 1, 0.6)
