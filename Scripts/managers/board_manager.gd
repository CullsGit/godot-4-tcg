extends Node

func _on_turn_started(current_player):
	# only flip on local‐vs‐local: you could guard with a `if is_multiplayer: return`
	var flip = $Tween  # or your AnimationPlayer
	flip.interpolate_property( $Board, "rotation_degrees", 0, 180, 0.5 )
	flip.start()
