extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%UnpauseButton.pressed.connect(_on_unpause_button_pressed)
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%QuitToMainMenuButton.pressed.connect(_on_quit_to_main_menu_button_press)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %UnpauseButton.pressed.connect().
func _on_unpause_button_pressed() -> void:
	acted.emit(&"unpause")


# Listens to %SaveButton.pressed.connect().
func _on_save_button_pressed() -> void:
	acted.emit(&"save_expedition")


# Listens to %QuitToMainMenuButton.pressed.connect().
func _on_quit_to_main_menu_button_press() -> void:
	acted.emit(&"quit_to_menu")

#endregion
# ============================================================================ #
