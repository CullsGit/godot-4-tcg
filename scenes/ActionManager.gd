extends Node

@export var max_actions := 3

var current_actions := max_actions

signal actions_updated(current_actions)

func _ready():
	actions_updated.emit(current_actions)

func use_action():
	if current_actions > 0:
		current_actions -= 1
		actions_updated.emit(current_actions)
	else:
		print("No actions left!")

func reset_actions():
	current_actions = max_actions
	actions_updated.emit(current_actions)
