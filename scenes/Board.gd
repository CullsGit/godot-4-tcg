extends Control

var slots = []  # List of all slots on the board

func _ready():
	# Find all slots inside the GridContainer
	for child in $Grid.get_children():
		if child is Control:
			slots.append(child)
