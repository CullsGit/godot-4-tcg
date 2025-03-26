extends Panel  # Card is a Panel
class_name Card

@export var card_type: String = ""  # Card type
var is_selected = false  # Track selection state
var is_activated = true


signal card_selected(card)  # Signal when card is selected


const CARD_COLORS = {
	"Tank": Color.BLUE,
	"Damage": Color.RED,
	"Magic": Color.GREEN
}

func _ready():
	# Set initial card color
	update_highlight()
	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		card_selected.emit(self)  # Notify Hand.gd that this card was clicked

func set_activated(value: bool):
	is_activated = value
	update_highlight()

func toggle_selection():
	is_selected = !is_selected  # Toggle selection state
	update_highlight()  # Apply highlight immediately

func update_highlight():
	var new_style = StyleBoxFlat.new()
	new_style.bg_color = CARD_COLORS[card_type]

	if not is_activated:
		new_style.bg_color = new_style.bg_color.darkened(0.5)

	if is_selected:
		new_style.border_color = Color.SNOW
		new_style.border_width_top = 4
		new_style.border_width_bottom = 4
		new_style.border_width_left = 4
		new_style.border_width_right = 4
	else:
		new_style.border_width_top = 0
		new_style.border_width_bottom = 0
		new_style.border_width_left = 0
		new_style.border_width_right = 0

	set("theme_override_styles/panel", new_style)  # Apply highlight
