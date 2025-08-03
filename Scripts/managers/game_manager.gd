# GameManager.gd
extends Node

enum GameMode { LOCAL, VS_CPU }

@export var mode: GameMode = GameMode.LOCAL

var player1: Player
var player2: Player

func _ready() -> void:
	await get_tree().process_frame

	var main_scene = get_tree().get_current_scene()

	player1 = main_scene.get_node("Player1") as Player
	player2 = main_scene.get_node("Player2") as Player

	set_mode(mode)

# Switch modes and bootstrap players / turn system
func set_mode(new_mode: GameMode) -> void:
	mode = new_mode

	match mode:
		GameMode.LOCAL:
			player1.controller = null
			player2.controller = null

		GameMode.VS_CPU:
			player1.controller = null
			player2.controller = player2.get_node_or_null("AIController")

	# assign into turn manager and start
	TurnManager.players = [player1, player2]
	await get_tree().process_frame  # let any signal hookups settle
	TurnManager.start_turn()
