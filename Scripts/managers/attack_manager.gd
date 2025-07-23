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


func can_attack(attacker: Card, target: Card) -> bool:
	var attacker_slot = attacker.get_parent()
	if target.shrouded:
		return false
	if attacker_slot == null:
		return false

	# Lane‐blocking logic
	var blockers = BoardManager.allied_blockers_in_lane(attacker_slot)
	var valid_targets: Array
	if attacker.card_ability == "Overstrike":
		match blockers:
			2:
				return false
			1:
				valid_targets = BoardManager.check_opponent_cards_in_range(attacker_slot)
			0:
				valid_targets = BoardManager.check_opponent_cards_in_range(attacker_slot, true)
	else:
		if blockers > 0:
			return false
		valid_targets = BoardManager.check_opponent_cards_in_range(attacker_slot)

	if target not in valid_targets:
		return false

	# RPS defeat check
	var attack_type = attacker.card_type
	var target_type = target.card_type
	if COMBAT_RULES[target_type]["beats"] == attack_type:
		return false

	# Action‐point check
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
	# Spend the actions
	BoardManager.clear_all_slot_highlights()
	ActionManager.use_action(cost)

	# (Optional) play animations here…

	# Remove the defeated card
	target.get_parent().remove_child(target)
	target.queue_free()
	emit_signal("card_defeated", target)
