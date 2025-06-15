extends Button
#DELETE THIS IN REAL GAME

func _ready():
	%RestartButton.pressed.connect(on_restart_button_pressed)

func on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
