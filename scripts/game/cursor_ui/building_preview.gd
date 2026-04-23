extends Node2D


# ============================================================================ #
#region Exported properties

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
func set_type(building_type: Building.BuildingType) -> void:
	match building_type:
		Building.BuildingType.NONE:
			_map_sprite_2d.texture = null
			_local_sprite_2d.texture = null
		Building.BuildingType.HOUSING:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_housing_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_housing_var0.png"))
		Building.BuildingType.GREENHOUSE:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_greenhouse_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_greenhouse_var0.png"))
		Building.BuildingType.RANCH:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_ranch_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_ranch_var0.png"))
		Building.BuildingType.FISHERY:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_fishery_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_fishery_var0.png"))
		Building.BuildingType.SOLAR_FARM:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_solar_farm_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_solar_farm_var0.png"))
		Building.BuildingType.WIND_FARM:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_wind_farm_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_wind_farm_var0.png"))
		Building.BuildingType.NUCLEAR_REACTOR:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_nuclear_reactor_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_nuclear_reactor_var0.png"))
		Building.BuildingType.FACTORY:
			_map_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_factory_var0.png"))
			_local_sprite_2d.texture = load(
					Building.BUILDING_ASSET_DIR.path_join("building_factory_var0.png"))
		_:
			push_error("Unrecognized building type: '%s'." % [
				Building.BuildingType.keys()[building_type]
			])
			return


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
