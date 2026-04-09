extends GameUI


# The building card currently on the player's hand to be placed down in the
# [World].
var _picked_building: Building.BuildingType = Building.BuildingType.NONE


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	UIEventBus.building_card_picked.connect(_on_building_card_picked)
	UIEventBus.building_card_dropped.connect(_on_building_card_dropped)
	GameplayEventBus.population_changed.connect(_on_population_changed)


func _input(event: InputEvent) -> void:
	if (
			_picked_building != Building.BuildingType.NONE
			and	event is InputEventMouseButton
			and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT
	):
		UIEventBus.building_placement_requested.emit(
				event.position,
				_picked_building)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to UIEventBus.building_card_picked(building: Building.BuildingType).
func _on_building_card_picked(building: Building.BuildingType) -> void:
	_picked_building = building


# Listens to building_card_dropped(building: Building.BuildingType).
func _on_building_card_dropped(_building: Building.BuildingType) -> void:
	_picked_building = Building.BuildingType.NONE


# Listens to
# GameplayEventBus.population_changed(old_amount: int, new_amount: int).
func _on_population_changed(_old_amount: int, _new_amount: int) -> void:
	%PopulationLabel.text = "%d" % Global.game_state.population

#endregion
# ============================================================================ #
