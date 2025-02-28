extends Node

@onready var board1: Control = $Board1
@onready var board2: Control = $Board2
@export var action_manager: Node

var current_player = 1  # 1 = Board1, 2 = Board2

func _ready():
	action_manager.actions_updated.connect(_on_actions_updated)
	update_board_interactivity()

func _on_actions_updated(actions_left):
	if actions_left == 0:
		switch_turns()

func switch_turns():
	current_player = 2 if current_player == 1 else 1
	action_manager.reset_actions()
	update_board_interactivity()
	print("Switched to Player %d" % current_player)

func update_board_interactivity():
	board1.set_process(current_player == 1)
	board2.set_process(current_player == 2)
	board1.set_physics_process(current_player == 1)
	board2.set_physics_process(current_player == 2)
	board1.visible = true  # Later, hide opponent’s hand
	board2.visible = true  # Later, hide opponent’s hand

func get_current_board():
	return board1 if current_player == 1 else board2
