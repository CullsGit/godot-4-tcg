extends CanvasLayer

var winner: int

func _ready():
	get_tree().paused = true
	%PlayerLabel.text = "Player %s Wins" % str(winner)
	%RestartButton.pressed.connect(on_restart_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)


func on_restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")

func on_quit_button_pressed():
	get_tree().quit()
