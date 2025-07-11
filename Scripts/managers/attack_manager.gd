# Scripts/managers/attack_manager.gd
extends Node

signal card_defeated(defeated_card: Card)

# Your original RPS rules and costs
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

# No @onready board here—grab it inside can_attack()

# Note: ActionManager is an autoload, so we can call it directly
func can_attack(attacker: Card, target: Card) -> bool:
	var current_board = TurnManager.get_current_player().board
	var attacker_slot = attacker.get_parent()
	if attacker_slot == null:
		return false
	if attacker.bulwarked or attacker.shrouding:
		return false

	# Lane‐blocking logic
	var blockers = current_board.allied_blockers_in_lane(attacker_slot)
	var valid_targets: Array
	if attacker.card_ability == "Overstrike":
		match blockers:
			2:
				return false
			1:
				valid_targets = current_board.check_opponent_cards_in_range(attacker_slot)
			0:
				valid_targets = current_board.check_opponent_cards_in_range(attacker_slot, true)
	else:
		if blockers > 0:
			return false
		valid_targets = current_board.check_opponent_cards_in_range(attacker_slot)

	if target not in valid_targets:
		return false

	# RPS defeat check
	var atype = attacker.card_ability
	var ttype = target.card_ability
	if COMBAT_RULES[ttype]["beats"] == atype:
		return false

	# Action‐point check
	var cost = get_action_cost(attacker, target)
	if ActionManager.current_actions < cost:
		return false

	return true

func get_action_cost(attacker: Card, target: Card) -> int:
	var rules = COMBAT_RULES.get(attacker.card_ability)
	var ttype = target.card_ability
	if rules:
		var cost = rules.action_cost.get(ttype, 2)
		# Overpower tweak
		if attacker.card_ability == "Overpower" and attacker.card_ability == ttype and not target.bulwarked:
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
	ActionManager.use_action(cost)

	# (Optional) play animations here…

	# Remove the defeated card
	target.get_parent().remove_child(target)
	target.queue_free()
	emit_signal("card_defeated", target)
