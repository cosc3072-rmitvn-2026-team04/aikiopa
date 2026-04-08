extends GameUI


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.population_changed.connect(_on_population_changed)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# GameplayEventBus.population_changed(old_amount: int, new_amount: int).
func _on_population_changed(_old_amount: int, _new_amount: int) -> void:
	%PopulationLabel.text = "%d" % Global.game_state.population

#endregion
# ============================================================================ #
