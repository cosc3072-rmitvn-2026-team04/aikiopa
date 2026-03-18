extends GameUI


func _ready() -> void:
	%TutorialButton.pressed.connect(_on_tutorial_button_pressed)
	%FreeGameButton.pressed.connect(_on_free_game_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_press)
	%CreditsButton.pressed.connect(_on_credits_button_press)
	%QuitButton.pressed.connect(_on_quit_button_press)

func _on_tutorial_button_pressed() -> void:
	acted.emit(&"tutorial")

func _on_free_game_button_pressed() -> void:
	acted.emit(&"free_play")

func _on_settings_button_press() -> void:
	acted.emit(&"settings")

func _on_credits_button_press() -> void:
	acted.emit(&"credits")

func _on_quit_button_press() -> void:
	acted.emit(&"quit")
