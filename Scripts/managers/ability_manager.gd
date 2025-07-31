extends Node

signal shrouding_started(card: Card)
signal shrouding_ended(card: Card)

var active_shrouders: Array[Card] = []

# Public API
func bulwarked(card: Card) -> void:
	toggle_ability(card.toggle_bulwarked)

func shrouding(card: Card) -> void:
	var was_active = card.shrouding
	toggle_ability(card.toggle_shrouding)
	
	if not was_active and card.shrouding:
		active_shrouders.append(card)
		shrouding_started.emit(card)
	elif was_active and not card.shrouding:
		active_shrouders.erase(card)
		shrouding_ended.emit(card)

# --- helpers ---------------------------------------------------------

func toggle_ability(toggle_fn: Callable) -> void:
	if ActionManager.current_actions < 1:
		return

	ActionManager.use_action()
	toggle_fn.call()

func is_shrouding_active_for(player: Player) -> bool:
	for card in active_shrouders:
		if card.card_owner == player:
			return true
	return false
