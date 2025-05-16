extends GutTest

const Card = preload("res://scripts/Card.gd")

var card
var texture_rect

func before_each():
	card = autoqfree(Card.new())
	texture_rect = autoqfree(TextureRect.new())
	texture_rect.name = "TextureRect"
	card.add_child(texture_rect)

	# Reset state
	card.is_selected = false
	card.is_activated = true
	card.card_ability = ""
	card.bulwarked = false
	card.shrouding = false
	card.is_shrouded = false

#――――――――――――――――――――――――――――#
#  SIGNAL & INPUT TESTS
#――――――――――――――――――――――――――――#

func test_left_click_emits_card_selected():
	watch_signals(card)
	var event = InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_LEFT
	card._gui_input(event)
	assert_signal_emitted(card, "card_selected")

func test_right_click_bulwark_emits_use_bulwark_ability():
	card.card_ability = "Bulwark"
	card.is_activated = true
	watch_signals(card)
	var event = InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_RIGHT
	card._gui_input(event)
	assert_signal_emitted(card, "used_bulwark_ability")

func test_right_click_shroud_emits_use_shroud_ability():
	card.card_ability = "Shroud"
	card.is_activated = true
	watch_signals(card)
	var event = InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_RIGHT
	card._gui_input(event)
	assert_signal_emitted(card, "used_shroud_ability")

func test_right_click_bulwark_when_deactivated_emits_nothing():
	card.card_ability = "Bulwark"
	card.is_activated = false
	watch_signals(card)
	var event = InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_RIGHT
	card._gui_input(event)
	assert_signal_not_emitted(card, "used_bulwark_ability")

func test_right_click_bulwark_with_no_ability_emits_nothing():
	card.is_activated = true
	watch_signals(card)
	var event = InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_RIGHT
	card._gui_input(event)
	assert_signal_not_emitted(card, "used_bulwark_ability")

func test_right_click_shroud_when_deactivated_emits_nothing():
	card.card_ability = "Shroud"
	card.is_activated = false
	watch_signals(card)
	var event = InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_RIGHT
	card._gui_input(event)
	assert_signal_not_emitted(card, "used_shroud_ability")

func test_right_click_shroud_with_no_ability_emits_nothing():
	card.is_activated = true
	watch_signals(card)
	var event = InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_RIGHT
	card._gui_input(event)
	assert_signal_not_emitted(card, "used_shroud_ability")

#――――――――――――――――――――――――――――#
#  TOGGLE & STATE TESTS
#――――――――――――――――――――――――――――#

func test_toggle_selection_flips_flag_and_highlights():
	assert_false(card.is_selected)
	#toggle selected
	card.toggle_selection()
	assert_true(card.is_selected)
	assert_eq(texture_rect.modulate, Color(1.5, 1.5, 1.5, 1))

	#toggle back
	card.toggle_selection()
	assert_false(card.is_selected)
	assert_eq(texture_rect.modulate, Color(1, 1, 1, 1))
