extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%ResumeButton.pressed.connect(_on_resume_button_pressed)
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%QuitToMainMenuButton.pressed.connect(_on_quit_to_main_menu_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_quit"):
		get_viewport().set_input_as_handled()
		_on_resume_button_pressed()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Show the Game Menu.
func open() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	show()


## Hide the Game Menu.
func close() -> void:
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to %ResumeButton.pressed.connect().
func _on_resume_button_pressed() -> void:
	acted.emit(&"resume")


# Listens to %SaveButton.pressed.connect().
func _on_save_button_pressed() -> void:
	acted.emit(&"save_session")


# Listens to %QuitToMainMenuButton.pressed.connect().
func _on_quit_to_main_menu_button_pressed() -> void:
	acted.emit(&"quit_game")

#endregion
# ============================================================================ #
