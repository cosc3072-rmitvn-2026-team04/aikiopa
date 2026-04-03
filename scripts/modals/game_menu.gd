extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%ResumeButton.pressed.connect(_on_resume_button_pressed)
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%QuitToMainMenuButton.pressed.connect(_on_quit_to_main_menu_button_press)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %ResumeButton.pressed.connect().
func _on_resume_button_pressed() -> void:
	acted.emit(&"resume")


# Listens to %SaveButton.pressed.connect().
func _on_save_button_pressed() -> void:
	acted.emit(&"save_expedition")


# Listens to %QuitToMainMenuButton.pressed.connect().
func _on_quit_to_main_menu_button_press() -> void:
	acted.emit(&"quit_to_menu")

#endregion
# ============================================================================ #
