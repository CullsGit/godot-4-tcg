extends Node

@export var max_actions: int = 3

var current_actions: int = max_actions

signal actions_updated(current_actions)

var actions_label: Label = null

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)
	var scene_root = get_tree().get_current_scene() as Node
	actions_label = scene_root.get_node("ActionsLabel") as Label
	actions_updated.connect(_on_actions_updated)
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


func _on_actions_updated(actions_remaining: int) -> void:
	if actions_label:
		actions_label.text = "Actions: %d" % actions_remaining


func _on_turn_started(_current_player: Player) -> void:
	reset_actions()
