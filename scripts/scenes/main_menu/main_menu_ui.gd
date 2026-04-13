extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%TutorialButton.pressed.connect(_on_tutorial_button_pressed)
	%FreeGameButton.pressed.connect(_on_free_game_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_press)
	%CreditsButton.pressed.connect(_on_credits_button_press)
	%QuitButton.pressed.connect(_on_quit_button_press)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %TutorialButton.pressed.connect()
func _on_tutorial_button_pressed() -> void:
	acted.emit(&"tutorial")

# Listens to %FreeGameButton.pressed.connect()
func _on_free_game_button_pressed() -> void:
	acted.emit(&"free_play")

# Listens to %SettingsButton.pressed.connect()
func _on_settings_button_press() -> void:
	acted.emit(&"settings")

# Listens to %CreditsButton.pressed.connect()
func _on_credits_button_press() -> void:
	acted.emit(&"credits")

# Listens to %QuitButton.pressed.connect()
func _on_quit_button_press() -> void:
	acted.emit(&"quit")

#endregion
# ============================================================================ #
