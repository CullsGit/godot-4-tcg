extends Node

@export var max_actions := 3
@onready var action_label = $"../ActionLabel"

var current_actions := max_actions
var current_player := 1  # 1 for Player 1, 2 for Player 2

signal actions_updated(current_actions)

func _ready():
	connect("actions_updated", Callable(self, "_on_action_manager_actions_updated"))
	emit_signal("actions_updated", current_actions)

func use_action():
	if current_actions > 0:
		current_actions -= 1
		emit_signal("actions_updated", current_actions)
	else:
		print("No actions left!")

func reset_actions():
	current_actions = max_actions
	emit_signal("actions_updated", current_actions)

func _on_action_manager_actions_updated(current_actions):
	action_label.text = "Actions Left: %d" % current_actions
	
