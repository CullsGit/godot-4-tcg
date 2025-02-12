extends Panel  # Use Panel or ColorRect to allow background color changes

@export var card_type: String = ""  # Card type (Tank, Damage, Magic, Healer)


# Color mapping for each card type
const CARD_COLORS = {
	"Tank": Color.BLUE,
	"Damage": Color.RED,
	"Magic": Color.GREEN,
	"Healer": Color.PURPLE
}

func _ready():
	if card_type in CARD_COLORS:
		var new_style = StyleBoxFlat.new()  # Create a new style box
		new_style.bg_color = CARD_COLORS[card_type]  # Assign background color
		set("theme_override_styles/panel", new_style)  # Apply the color to the panel
