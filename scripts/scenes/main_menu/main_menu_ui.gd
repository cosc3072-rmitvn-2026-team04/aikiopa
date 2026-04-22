extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%StartButton.pressed.connect(_on_start_button_pressed)
	%GalleryButton.pressed.connect(_on_gallery_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_press)
	%CreditsButton.pressed.connect(_on_credits_button_press)
	%QuitButton.pressed.connect(_on_quit_button_press)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %StartButton.pressed.connect()
func _on_start_button_pressed() -> void:
	acted.emit(&"start")

# Listens to %GalleryButton.pressed.connect()
func _on_gallery_button_pressed() -> void:
	acted.emit(&"gallery")

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
