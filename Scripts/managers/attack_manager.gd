# Scripts/managers/attack_manager.gd
extends Node
class_name AttackManager

signal card_defeated(defeated_card: Card)

# RPS rules
var _beats := {
	"Rock":     "Scissors",
	"Scissors": "Paper",
	"Paper":    "Rock"
}

# 1) Delegate your existing can_attack check
func can_attack(attacker: Card, target_slot: Node) -> bool:
	return BoardManager.can_attack(attacker, target_slot)

# 2) Actually resolve one attack
func resolve_attack(attacker: Card, target_slot: Node) -> void:
	var defender: Card = target_slot.get_node_or_null("Card") as Card
	if defender == null or not can_attack(attacker, target_slot):
		return

	emit_signal("pre_attack", attacker, defender)

	# Determine outcome
	var outcome: String
	if _beats[attacker.card_ability] == defender.card_ability:
		outcome = "attacker"
	elif _beats[defender.card_ability] == attacker.card_ability:
		outcome = "defender"
	else:
		outcome = "tie"

	match outcome:
		"attacker":
			_remove_card(defender)
			emit_signal("card_defeated", defender)
		"defender":
			_remove_card(attacker)
			emit_signal("card_defeated", attacker)
		"tie":
			# No removals on tie; you can add effects here if desired

	emit_signal("post_attack", attacker, defender, outcome)

# 3) Helper to actually free the card node
func _remove_card(card: Card) -> void:
	card.get_parent().remove_child(card)
	card.queue_free()
