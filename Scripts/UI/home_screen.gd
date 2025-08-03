extends CanvasLayer

@onready var local_button = $VBoxContainer/LocalPlayButton
@onready var vs_cpu_button = $VBoxContainer/VersusCPUButton

func _ready() -> void:

	get_tree().paused = true
	
	local_button.connect("pressed", Callable(self, "_on_local_pressed"))
	vs_cpu_button.connect("pressed", Callable(self, "_on_vs_cpu_pressed"))


func _on_local_pressed() -> void:
	GameManager.set_mode(GameManager.GameMode.LOCAL)
	_start_game()

func _on_vs_cpu_pressed() -> void:
	GameManager.set_mode(GameManager.GameMode.VS_CPU)
	_start_game()

func _start_game() -> void:
	visible = false  # hide menu
	get_tree().paused = false
