extends GutTest

const ActionManager = preload("res://scripts/ActionManager.gd")

var manager

func before_each():
	manager = autoqfree(ActionManager.new())

func test_initial_actions_equal_max_actions():
	# On creation, current_actions should be the same as max_actions
	assert_eq(manager.current_actions, manager.max_actions,
	"current_actions should start at max_actions")

func test_ready_emits_action_updated_signal():
	# The _ready() hook should fire the 'actions_updated' signal once
	watch_signals(manager)
	manager._ready()
	assert_signal_emitted(manager, "actions_updated")

func test_use_action_decrements_and_emits_signal():
	watch_signals(manager)
	var before = manager.current_actions
	manager.use_action()
	assert_eq(manager.current_actions, before - 1, 
		"use_action() should decrement current_actions")
	assert_signal_emitted(manager, "actions_updated")

func test_use_action_when_zero_does_not_emit_signal():
	manager.current_actions = 0
	watch_signals(manager)
	manager.use_action()
	assert_eq(manager.current_actions, 0, 
		"current_actions should stay at 0 when no actions remain")
	assert_signal_not_emitted(manager, "actions_updated")

func test_reset_actions_restores_max_and_emits_signal():
	manager.current_actions = 0
	watch_signals(manager)
	manager.reset_actions()
	assert_eq(manager.current_actions, manager.max_actions,
		"current_actions should equal max_actions when reset")
	assert_signal_emitted(manager, "actions_updated")
