extends Node
class_name AIController

func take_turn(player: Player) -> void:
	await get_tree().create_timer(2).timeout
	await _draw_phase(player)
	await _play_phase(player)
	# await _move_phase(player)
	# await _attack_phase(player)

func _draw_phase(player: Player) -> void:
	var draw_gen := DrawGenerator.new()
	var play_gen := PlayGenerator.new()

	# Can we legally draw?
	var can_draw := not draw_gen.legal_draws(player).is_empty()
	if not can_draw:
		return

	# Do we already have a legal play? If yes, prefer play unless hand is low.
	var has_play := not play_gen.legal_plays(player).is_empty()
	var hand_size: int = player.hand.cards_in_hand.size()
	var want_draw: bool = (not has_play) or (hand_size <= 2)

	if want_draw and player.deck:
		player.deck.draw_card()  # consumes 1 AP via Deck.gd
		await get_tree().create_timer(randf_range(0.4, 0.8)).timeout

func _play_phase(player: Player) -> void:
	var gen := PlayGenerator.new()
	var safety_cap := 20  # avoid infinite loops if something goes weird

	while ActionManager.current_actions > 0 and safety_cap > 0:
		safety_cap -= 1

		var options := gen.legal_plays(player)
		if options.is_empty():
			break

		# Simple policy: pick the first legal (card, slot)
		var choice = options[0]
		var card: Card = choice[0]
		var slot: Slot = choice[1]

		# Execute using your real game API (no UI highlight/select needed)
		BoardManager.place_from_hand(card, slot)

		# Small human-like delay (optional)
		await get_tree().create_timer(randf_range(0.6, 1.2)).timeout
