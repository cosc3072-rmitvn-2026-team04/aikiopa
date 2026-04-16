class_name BuildingCard
extends Node2D


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

## The visual "pop-up" offset when a building card is picked up by the player.
## See [method is_picked]. This is to give extra emphasis that the card is
## being picked up.
@export_range(0, 128, 1, "suffix:px") var picked_offset: int = 0

#endregion
# ============================================================================ #


# ============================================================================ #
#region Variables

var _is_pickable: bool = false
var _is_picked: bool = false
var _building_type: Building.BuildingType = Building.BuildingType.NONE

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_is_pickable = false
	_is_picked = false


func _input(event: InputEvent) -> void:
	if not is_pickable():
		return

	if not is_picked() and event is InputEventMouseMotion:
		if $CardBackgroundSprite2D.get_rect().has_point(to_local(event.position)):
			_set_hovered()
		else:
			_unset_hovered()

	if event is InputEventMouseButton and event.pressed:
		var is_event_inside: bool =\
				$CardBackgroundSprite2D.get_rect().has_point(to_local(event.position))

		if is_event_inside and event.button_index == MOUSE_BUTTON_LEFT:
			if not is_picked():
				set_picked()
			else:
				unset_picked()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and is_picked():
			unset_picked()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the screen size of this building card.
func get_size() -> Vector2i:
	return $CardBackgroundSprite2D.get_rect().size


## Returns the [enum Building.BuildingType] of this building card.
func get_building_type() -> Building.BuildingType:
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
	UIEventBus.building_card_picked.emit(get_building_type())
	scale = Vector2.ONE * (float(picked_scale) / 100)
	position.y -= picked_offset


## Sets this building card as NOT being picked up by the player. See
## [method is_picked].
func unset_picked() -> void:
	_is_picked = false
	UIEventBus.building_card_dropped.emit(get_building_type())
	scale = Vector2.ONE * (float(pickable_scale) / 100)
	position.y += picked_offset


## Update the visual elements for this building card to match
## [param building_type].
func set_type(building_type: Building.BuildingType) -> void:
	match building_type:
		Building.BuildingType.HOUSING:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("housing_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_housing.png"))
		Building.BuildingType.GREENHOUSE:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_greenhouse.png"))
		Building.BuildingType.RANCH:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_ranch.png"))
		Building.BuildingType.FISHERY:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_fishery.png"))
		Building.BuildingType.SOLAR_FARM:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_solar_farm.png"))
		Building.BuildingType.WIND_FARM:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_wind_farm.png"))
		Building.BuildingType.NUCLEAR_REACTOR:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_nuclear_reactor.png"))
		Building.BuildingType.FACTORY:
			$CardForegroundSprite2D.texture = load(
					Global.BUILDING_CARD_ASSET_DIR.path_join("industry_fg.png"))
			$BuildingSprite2D.texture = load(
					Global.BUILDING_ASSET_DIR.path_join("building_factory.png"))
		_:
			push_error("Unrecognized building type: '%s'." % [
				Building.BuildingType.keys()[building_type]
			])
			return

	$BuildingNameLabel.text = Building.BUILDING_NAME[building_type]
	_building_type = building_type

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
