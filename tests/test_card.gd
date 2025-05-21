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

func test_set_activated_updates_flag_and_transparency():
	card.set_activated(false)
	assert_false(card.is_activated)
	assert_eq(texture_rect.modulate, Color(1, 1, 1, 0.3))

func test_toggle_bulwarked_flag_and_resets_tween():
	assert_false(card.bulwarked)
	card.toggle_bulwarked()
	assert_true(card.bulwarked)
	assert_not_null(card.bulwarked_tween)
	var first_tween = card.bulwarked_tween
	card.toggle_bulwarked()
	assert_false(card.bulwarked)
	assert_ne(card.bulwarked_tween, first_tween)

func test_toggle_shrouding_flag_and_resets_tween():
	assert_false(card.shrouding)
	card.toggle_shrouding()
	assert_true(card.shrouding)
	assert_not_null(card.shrouding_tween)
	var first_tween = card.shrouding_tween
	card.toggle_shrouding()
	assert_false(card.shrouding)
	assert_ne(card.shrouding_tween, first_tween)

func test_toggle_shrouded_flag_and_resets_tween():
	assert_false(card.is_shrouded)
	card.toggle_shrouded()
	assert_true(card.is_shrouded)
	assert_not_null(card.shrouded_tween)
	var first_tween = card.shrouded_tween
	card.toggle_shrouded()
	assert_false(card.is_shrouded)
	assert_ne(card.shrouded_tween, first_tween)

#――――――――――――――――――――――――――――#
#  MOUSE ENTER/EXIT & TWEEN TESTS
#――――――――――――――――――――――――――――#

func test_on_mouse_entered_creates_new_tween():
	assert_null(card.hover_tween)
	card._on_mouse_entered()
	assert_not_null(card.hover_tween)

func test_on_mouse_exited_creates_new_tween():
	assert_null(card.hover_tween)
	card._on_mouse_exited()
	assert_not_null(card.hover_tween)

#――――――――――――――――――――――――――――#
#  SETUP & VISUAL UPDATE TESTS
#――――――――――――――――――――――――――――#

func test_setup_assigns_data_and_properties():
	var data = {
		"type": "Aura",
		"ability": "Shroud",
		"image_path": ""
	}
	card.setup(data)
	assert_eq(card.card_data, data)
	assert_eq(card.card_type, "Aura")
	assert_eq(card.card_ability, "Shroud")

func test_update_visual_sets_texture_when_present():
	var dummy_tex = GradientTexture2D.new()
	card.card_asset = dummy_tex
	card.update_visual()
	assert_eq(texture_rect.texture, dummy_tex)
