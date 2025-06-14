extends CanvasLayer


func _ready():
	get_tree().paused = true
	%PlayerLabel.text = 'Player 1' + 'Won!'
	%RestartButton.pressed.connect(on_restart_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)


func on_restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")

func on_quit_button_pressed():
	get_tree().quit()
