extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	super()

	GameplayEventBus.game_over.connect(_on_game_over)
	%SaveSnapshotButton.pressed.connect(_on_save_snapshot_button_pressed)
	%NewSessionButton.pressed.connect(_on_new_session_button_pressed)
	%QuitToMainMenuButton.pressed.connect(_on_quit_to_main_menu_button_press)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Show the Game Over Menu.
func open() -> void:
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

# Listens to GameplayEventBus.game_over(
#		population_reached: int,
#		game_over_type: Game.GameOverType).
func _on_game_over(population: int, game_over_type: Game.GameOverType) -> void:
	%PopulationValueLabel.text = "Final Population: %d👨‍🚀" % [population]
	match game_over_type:
		Game.GameOverType.EMPTY_CARD_STACK:
			%PopulationValueLabel.text = "Final Population: %d👨‍🚀" % [population]
			%MessageLabel.text = "Expedition Completed!"
		Game.GameOverType.NO_POPULATION:
			%PopulationValueLabel.text = "Colony Abandoned"
			%MessageLabel.text = "Expedition Ended"
		_:
			%PopulationValueLabel.text = "!Error"
			%MessageLabel.text = "!Error"
			push_error("Unrecognized 'game_over_type': %s" % [
				Game.GameOverType.keys()[game_over_type]
			])
	%AnimationPlayer.play(&"activate")


# Listens to %SaveSnapshotButton.pressed.
func _on_save_snapshot_button_pressed() -> void:
	acted.emit(&"save_snapshot")


# Listens to %NewSessionButton.pressed.
func _on_new_session_button_pressed() -> void:
	acted.emit(&"new_session")


# Listens to %QuitToMainMenuButton.pressed.
func _on_quit_to_main_menu_button_press() -> void:
	acted.emit(&"quit_to_main_menu")

#endregion
# ============================================================================ #
