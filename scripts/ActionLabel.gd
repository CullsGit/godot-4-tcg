extends Label

func _on_action_manager_actions_updated(current_actions):
	text = "Actions: %d" % current_actions
