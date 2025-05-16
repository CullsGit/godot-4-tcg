extends Node

@export var max_actions: int = 3

var current_actions: int = max_actions

signal actions_updated(current_actions)

func _ready():
	actions_updated.emit(current_actions)

func use_action() -> void:
	if current_actions > 0:
		current_actions -= 1
		actions_updated.emit(current_actions)
	else:
		print("No actions left!")

func reset_actions() -> void:
	current_actions = max_actions
	actions_updated.emit(current_actions)
