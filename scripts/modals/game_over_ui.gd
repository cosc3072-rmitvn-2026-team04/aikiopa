extends GameUI


# ============================================================================ #
#region Godot builtins
func _ready() -> void:
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%NewGameButton.pressed.connect(_on_new_game_button_pressed)
	%QuitToMenuButton.pressed.connect(_on_quit_to_menu_button_press)
#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %SaveButton.pressed.connect().
func _on_save_button_pressed() -> void:
	acted.emit(&"save_expedition")

# Listens to %NewGameButton.pressed.connect().
func _on_new_game_button_pressed() -> void:
	acted.emit(&"new_game")

# Listens to %QuitToMenuButton.pressed.connect().
func _on_quit_to_menu_button_press() -> void:
	acted.emit(&"quit_to_menu")
#endregion
# ============================================================================ #
