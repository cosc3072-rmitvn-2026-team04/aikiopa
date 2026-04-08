class_name BuildingCard
extends Node2D


# ============================================================================ #
#region Constants

const CARD_ASSET_PATH = "res://assets/building_stack/building_card/"
const BUILDING_ASSET_PATH = "res://assets/objects/"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

## Visual scale increase/decrease when a building card is pickable by the
## player. See [method is_pickable].
@export_range(0, 200, 1, "suffix:%") var pickable_scale: int = 100

## Visual scale increase/decrease when hovered over by the player's cursor.
@export_range(0, 200, 1, "suffix:%") var hover_scale: int = 100

## Visual scale increase/decrease when a building card is picked up by the
## player. See [method is_picked].
@export_range(0, 200, 1, "suffix:%") var picked_scale: int = 100

#endregion
# ============================================================================ #


# ============================================================================ #
#region Variables

var _is_pickable: bool = false
var _is_picked: bool = false
var _building_type: World.BuildingType = World.BuildingType.NONE

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_is_pickable = false
	_is_picked = false


func _input(event: InputEvent) -> void:
	if not _is_pickable:
		return
	if not _is_picked and event is InputEventMouseMotion:
		if $CardBackgroundSprite2D.get_rect().has_point(to_local(event.position)):
			_set_hovered()
		else:
			_unset_hovered()
	if event is InputEventMouseButton and event.pressed:
		if (
				event.button_index == MOUSE_BUTTON_LEFT
				and $CardBackgroundSprite2D.get_rect().has_point(
						to_local(event.position))
		):
			GameplayEventBus.building_card_picked.emit(get_building_type())
			set_picked()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			GameplayEventBus.building_card_dropped.emit(get_building_type())
			unset_picked()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the screen size of this building card.
func get_size() -> Vector2i:
	return $CardBackgroundSprite2D.get_rect().size


## Returns the [enum World.BuildingType] of this building card.
func get_building_type() -> World.BuildingType:
	return _building_type


## Returns [code]true[/code] if this building card can be picked up (selected)
## by the the player to be placed in the [World].
func is_pickable() -> bool:
	return _is_pickable


## Sets this building card to be considered by the game's internal systems as
## pickable. See [method is_pickable].
func set_pickable() -> void:
	_is_pickable = true
	scale = Vector2.ONE * (float(pickable_scale) / 100)


## Sets this building card to NOT be considered by the game's internal systems
## as pickable. See [method is_pickable].
func unset_pickable() -> void:
	_is_pickable = false
	scale = Vector2.ONE


## Returns [code]true[/code] if this building card is being picked up (selected)
## by the player to be placed in the [World].
func is_picked() -> bool:
	return _is_picked


## Sets this building card as being picked up by the player. See
## [method is_picked].
func set_picked() -> void:
	_is_picked = true
	scale = Vector2.ONE * (float(picked_scale) / 100)


## Sets this building card as NOT being picked up by the player. See
## [method is_picked].
func unset_picked() -> void:
	_is_picked = false
	scale = Vector2.ONE * (float(pickable_scale) / 100)


## Update the visual elements for this building card to match [param building].
func set_type(building: World.BuildingType) -> void:
	match building:
		World.BuildingType.HOUSING:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("housing_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_housing.png"))
		World.BuildingType.SOLAR_FARM:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_solar_farm.png"))
		World.BuildingType.WIND_FARM:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_wind_farm.png"))
		World.BuildingType.NUCLEAR_REACTOR:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_nuclear_reactor.png"))
		World.BuildingType.GREENHOUSE:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_greenhouse.png"))
		World.BuildingType.RANCH:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_ranch.png"))
		World.BuildingType.FISHERY:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_fishery.png"))
		World.BuildingType.FACTORY:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("industry_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_factory.png"))
		_:
			push_error("Unrecognized building type: '%s'." % [
				World.BuildingType.keys()[building]
			])
			return

	$BuildingNameLabel.text = World.BUILDING_NAME[building]
	_building_type = building

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _set_hovered() -> void:
	scale = Vector2.ONE * (float(hover_scale) / 100)


func _unset_hovered() -> void:
	scale = Vector2.ONE * (float(pickable_scale) / 100)

#endregion
# ============================================================================ #
