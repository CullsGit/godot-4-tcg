extends Node

# Public API (connect your card signals to these)
func bulwarked(card: Card) -> void:
	_toggle_with_cost(card, "bulwarked", card.toggle_bulwarked)

func shrouding(card: Card) -> void:
	_toggle_with_cost(card, "shrouding", card.toggle_shrouding)

# --- helpers ---------------------------------------------------------

func _toggle_with_cost(_card: Card, _flag_name: String, toggle_fn: Callable) -> void:
	if ActionManager.current_actions < 1:
		return

	ActionManager.use_action()
	toggle_fn.call()
	UIManager.deselect_all_cards()
