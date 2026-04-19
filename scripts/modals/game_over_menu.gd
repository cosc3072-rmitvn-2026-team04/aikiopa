extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%NewExpeditionButton.pressed.connect(_on_new_session_button_pressed)
	%QuitToMainMenuButton.pressed.connect(_on_quit_to_main_menu_button_press)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Set %PopulationValueLabel.text to [param population].
func set_population(population: int) -> void:
	%PopulationValueLabel.text = "Final Population: %d👨‍🚀" % [population]


## Show the Game Over Menu.
func open() -> void:
	# TODO: This could be made prettier using a Tween animation to slide the
	# menu in.
	process_mode = Node.PROCESS_MODE_INHERIT
	show()


## Hide the Game Over Menu.
func close() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %SaveButton.pressed.connect().
func _on_save_button_pressed() -> void:
	acted.emit(&"save_snapshot")


# Listens to %NewExpeditionButton.pressed.connect().
func _on_new_session_button_pressed() -> void:
	acted.emit(&"new_session")


# Listens to %QuitToMainMenuButton.pressed.connect().
func _on_quit_to_main_menu_button_press() -> void:
	acted.emit(&"quit_to_main_menu")

#endregion
# ============================================================================ #
