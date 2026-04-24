extends Node2D


# ============================================================================ #
#region Exported properties

## Data definition for building sprite variations based on key
## [enum Building.BuildingType] and the corresponding [Array] of sprite file
## names ([String]).
@export var building_sprite_variations: Dictionary[Building.BuildingType, Array] = {}

@export var cursor_ui: Node2D = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _building_preview_sprite_2d_scene: PackedScene =\
		preload("res://scenes/game/cursor_ui/building_preview_sprite_2d.tscn")
var _map_sprite_2d: Sprite2D = null
@onready var _local_sprite_2d: Sprite2D = %BuildingPreviewSprite2D

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	var world: World = cursor_ui.world
	var building_layer: Node2D = world.get_building_layer()
	_map_sprite_2d = _building_preview_sprite_2d_scene.instantiate()
	_map_sprite_2d.name = &"CursorUIBuildingPreviewSprite2D"
	_map_sprite_2d.hide()
	building_layer.add_child(_map_sprite_2d, false, INTERNAL_MODE_BACK)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Sets the sprite of the building preview to match [param building_type].
## @deprecated: Use [method set_type_and_variation] instead.
func set_type(building_type: Building.BuildingType) -> void:
	if building_type == Building.BuildingType.NONE:
		_map_sprite_2d.texture = null
		_local_sprite_2d.texture = null
		return
	const ACCEPTED_BUILDING_TYPES: Array[Building.BuildingType] = [
		Building.BuildingType.LANDING_SITE,
		Building.BuildingType.HOUSING,
		Building.BuildingType.GREENHOUSE,
		Building.BuildingType.RANCH,
		Building.BuildingType.FISHERY,
		Building.BuildingType.SOLAR_FARM,
		Building.BuildingType.WIND_FARM,
		Building.BuildingType.NUCLEAR_REACTOR,
		Building.BuildingType.FACTORY,
	]
	if building_type not in ACCEPTED_BUILDING_TYPES:
			push_error("Building type '%s' not implemented." % [
				Building.BuildingType.keys()[building_type]
			])
			return

	var variations: Array[String] = building_sprite_variations[building_type]
	if variations.is_empty():
		return
	_map_sprite_2d.texture = load(Building.BUILDING_ASSET_DIR.path_join(
			variations[0]))
	_local_sprite_2d.texture = load(Building.BUILDING_ASSET_DIR.path_join(
			variations[0]))


## Sets the sprite of the building preview to match [param building_type] and
## [param variation_value] between [code]-1.0[/code] and [code]1.0[/code]
## (inclusive).[br]
## [br]
## The variation is calculated from the position of [param variation_value]
## within the uniform intervals in the above [code][-1.0, 1.0][/code] range,
## determined by the size of the corresponding sprite variation array for
## [param building_type] key in [member building_sprite_variations].
func set_type_and_variation(
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	if building_type == Building.BuildingType.NONE:
		_map_sprite_2d.texture = null
		_local_sprite_2d.texture = null
		return
	const ACCEPTED_BUILDING_TYPES: Array[Building.BuildingType] = [
		Building.BuildingType.LANDING_SITE,
		Building.BuildingType.HOUSING,
		Building.BuildingType.GREENHOUSE,
		Building.BuildingType.RANCH,
		Building.BuildingType.FISHERY,
		Building.BuildingType.SOLAR_FARM,
		Building.BuildingType.WIND_FARM,
		Building.BuildingType.NUCLEAR_REACTOR,
		Building.BuildingType.FACTORY,
	]
	if building_type not in ACCEPTED_BUILDING_TYPES:
			push_error("Building type '%s' not implemented." % [
				Building.BuildingType.keys()[building_type]
			])
			return

	var variations: Array[String] = Array(
			building_sprite_variations[building_type], TYPE_STRING, "", null)
	if variation_value < -1.0 or variation_value > 1.0:
		push_error("Value %.2f for parameter 'variation_value' is out of bound." % [
			variation_value
		])
		return
	if variations.is_empty():
		return

	var normalized_variation_value: float = (variation_value + 1.0) / 2.0
	var variation_index: int = int(normalized_variation_value * variations.size())
	variation_index = clampi(variation_index, 0, variations.size() - 1)
	_map_sprite_2d.texture = load(Building.BUILDING_ASSET_DIR.path_join(
			variations[variation_index]))
	_local_sprite_2d.texture = load(Building.BUILDING_ASSET_DIR.path_join(
			variations[variation_index]))


## Snaps the building preview onto the map's y-sorted [code]BuildingLayer[/code]
## at [param coords].
func snap(map_coords: Vector2i) -> void:
	var world: World = cursor_ui.world
	_map_sprite_2d.position = world.map_to_local(map_coords)
	_map_sprite_2d.show()
	_local_sprite_2d.hide()


## Unsnaps the building preview from the map's y-sorted
## [code]BuildingLayer[/code].
func unsnap() -> void:
	_map_sprite_2d.hide()
	_local_sprite_2d.show()

#endregion
# ============================================================================ #
