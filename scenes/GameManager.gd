extends Node

@onready var board1: Control = $Board1
@onready var board2: Control = $Board2
@onready var hand1: Control = board1.get_node("Hand")
@onready var hand2: Control = board2.get_node("Hand")
@export var action_manager: Node

var current_player = 1  # 1 = Board1, 2 = Board2

func _ready():
	action_manager.actions_updated.connect(_on_actions_updated)
	update_board_interactivity()
	update_hand_interactivity()  # Ensure correct hand is active

func _on_actions_updated(actions_left):
	if actions_left == 0:
		switch_turns()

func switch_turns():
	current_player = 2 if current_player == 1 else 1
	action_manager.reset_actions()
	update_board_interactivity()
	update_hand_interactivity()  # Update the active hand
	print("Switched to Player %d" % current_player)

func update_board_interactivity():
	board1.set_process(current_player == 1)
	board2.set_process(current_player == 2)
	board1.set_physics_process(current_player == 1)
	board2.set_physics_process(current_player == 2)
	board1.visible = true  # Keep visible, but could later hide opponent’s view
	board2.visible = true

func update_hand_interactivity():
	hand1.set_process(current_player == 1)
	hand2.set_process(current_player == 2)
	hand1.set_physics_process(current_player == 1)
	hand2.set_physics_process(current_player == 2)
	hand1.visible = current_player == 1  # Hide inactive hand
	hand2.visible = current_player == 2

func get_current_board():
	return board1 if current_player == 1 else board2

func get_current_hand():
	return hand1 if current_player == 1 else hand2
