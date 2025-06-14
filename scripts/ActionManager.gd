extends Node

@export var max_actions: int = 3

var current_actions: int = max_actions

signal actions_updated(current_actions)

func _ready():
	actions_updated.emit(current_actions)

func use_action(required_actions = 1) -> void:
	if current_actions >= required_actions:
		current_actions -= required_actions
		actions_updated.emit(current_actions)
	else:
		print("No actions left!")

func reset_actions() -> void:
	current_actions = max_actions
	actions_updated.emit(current_actions)
