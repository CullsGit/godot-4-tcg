extends Node

signal card_defeated(defeated_card: Card)

const COMBAT_RULES := {
	"Fury": {
		"beats": "Aura",
		"action_cost": { "Aura": 1, "Fury": 2 }
	},
	"Aura": {
		"beats": "Void",
		"action_cost": { "Void": 1, "Aura": 2 }
	},
	"Void": {
		"beats": "Fury",
		"action_cost": { "Fury": 1, "Void": 2 }
	}
}

func get_valid_attack_targets(attacker: Card) -> Array:
	var allow_overstrike = (attacker.card_ability == "Overstrike")
	var in_range = BoardManager.get_cards_in_range(attacker, allow_overstrike)
	
	return in_range.filter(func(target):
		return can_attack(attacker, target)
	)

func get_valid_attack_slots(attacker: Card) -> Array:
	return get_valid_attack_targets(attacker).map(func(c):
		return c.get_parent() as Slot
	)


func can_attack(attacker: Card, target: Card) -> bool:
	# 1) Status gates
	if attacker.is_locked() or target.shrouded:
		return false

	# 2) Spatial / range check via BoardManager
	var allow_overstrike = (attacker.card_ability == "Overstrike")
	var in_range  = BoardManager.get_cards_in_range(attacker, allow_overstrike)
	if target not in in_range:
		return false

	# 3) Rock‑Paper‑Scissors defeat check
	var atk_type = attacker.card_type
	var def_type = target.card_type
	if COMBAT_RULES[def_type]["beats"] == atk_type:
		return false

	# 4) Action‑point affordability
	var cost = get_action_cost(attacker, target)
	if ActionManager.current_actions < cost:
		return false

	return true

func get_action_cost(attacker: Card, target: Card) -> int:
	var rules = COMBAT_RULES.get(attacker.card_type)
	var target_type = target.card_type
	if rules:
		var cost = rules.action_cost.get(target_type, 2)
		# Overpower tweak
		if attacker.card_ability == "Overpower" and attacker.card_type == target_type and not target.bulwarked:
			print('true')
			cost = 1
		# Bulwark penalty
		if target.bulwarked:
			cost = 3
		return cost
	return 2

func resolve_attack(attacker: Card, target: Card) -> void:
	if not can_attack(attacker, target):
		return

	var cost = get_action_cost(attacker, target)

	UIManager.deselect_all_cards()
	ActionManager.use_action(cost)

	var slot = target.get_parent() as Slot
	slot.placed_card = null

	slot.remove_child(target)
	target.queue_free()
	emit_signal("card_defeated", target)
