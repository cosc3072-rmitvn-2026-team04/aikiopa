extends GameUI


@onready var _population_value_label: Label = %PopulationValueLabel

# ============================================================================ #
#region Godot builtins
func _ready() -> void:
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%NewExpeditionButton.pressed.connect(_on_new_expedition_button_pressed)
	%QuitToMainMenuButton.pressed.connect(_on_quit_to_main_menu_button_press)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Set %PopulationValueLabel.text to [param population].
func set_population(population: int) -> void:
	_population_value_label.text = "%d" % population

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %SaveButton.pressed.connect().
func _on_save_button_pressed() -> void:
	acted.emit(&"save_expedition")

# Listens to %NewExpeditionButton.pressed.connect().
func _on_new_expedition_button_pressed() -> void:
	acted.emit(&"new_expedition")

# Listens to %QuitToMainMenuButton.pressed.connect().
func _on_quit_to_main_menu_button_press() -> void:
	acted.emit(&"quit_to_main_menu")

#endregion
# ============================================================================ #
