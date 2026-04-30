class_name DisasterController
extends Node


# ============================================================================ #
#region Exported properties

@export_group("Ruleset", "ruleset")

## The population casualty caused by disaster per building by
## [enum Building.BuildingClass]. Should be negative. Positive values will cause
## undefined behavior.
@export var ruleset_disaster_casualty: Dictionary[Building.BuildingClass, int] = {
	Building.BuildingClass.CLASS_HOUSING: 0,
	Building.BuildingClass.CLASS_FOOD: 0,
	Building.BuildingClass.CLASS_ENERGY: 0,
	Building.BuildingClass.CLASS_INDUSTRY: 0,
}


@export_group("", "")

@export var world: World = null
@export var population_controller: PopulationController = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	GameplayEventBus.disaster_destruction_triggered.connect(
			_on_disaster_destruction_triggered)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to GameplayEventBus.disaster_destruction_triggered(
#		area: Array[Vector2i]).
func _on_disaster_destruction_triggered(area: Array[Vector2i]) -> void:
	for destruction_coords: Vector2i in area:
		if not world.has_building_at(destruction_coords):
			continue

		var building_type: Building.BuildingType =\
				world.get_building_at(destruction_coords)
		if building_type == Building.BuildingType.LANDING_SITE:
			continue

		var building_class: Building.BuildingClass =\
				Building.get_building_class_of_type(building_type)
		population_controller.change_population(ruleset_disaster_casualty[building_class])
		world.destroy_building_at(destruction_coords)

#endregion
# ============================================================================ #
