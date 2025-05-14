extends GutTest

const ActionManager = preload("res://scripts/ActionManager.gd")

var manager

func before_each():
	manager = ActionManager.new()

func test_initial_actions_equal_max_actions():
	# On creation, current_actions should be the same as max_actions
	assert_eq(manager.current_actions, manager.max_actions,
	"current_actions should start at max_actions")
