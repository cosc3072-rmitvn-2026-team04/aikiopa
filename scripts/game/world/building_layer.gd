extends Node2D


# ============================================================================ #
#region Public variables

## The [Building] instances in the game. Identified by their [Vector2i]
## coordinates.
var _buildings: Dictionary[Vector2i, Building]

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Removes all buildings (child nodes).
func clear() -> void:
	if get_child_count() > 0:
		for building: Building in get_children():
			remove_child(building)
			building.queue_free()
	_buildings.clear()


# TODO: Implement this.
## Returns the [enum Building.BuildingType] at [param coords].
func get_building_at(_coords) -> Building.BuildingType:
	return Building.BuildingType.NONE


# TODO: Implement this.
## Sets the building at [param coords] to one of [enum Building.BuildingType].
## TODO: Deterministically assign variation(s) at random.[br]
## [br]
## Returns [code]false[/code] if [param coords] is blocked by terrain or another
## building.
func set_building_at(
		_coords: Vector2i,
		_building_type: Building.BuildingType
) -> bool:
	return false


# TODO: Implement this.
## Destroys the building at [param coords].[br]
## [br]
## Returns [code]false[/code] if there is no building at [param coords].
func destroy_building_at(_coords: Vector2i) -> bool:
	push_error("Not implemented.")
	return false

#endregion
# ============================================================================ #
