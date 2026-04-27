class_name BuildingCard
extends Node2D


# ============================================================================ #
#region Constants

## [BuildingCard] asset location.
const BUILDING_CARD_ASSET_DIR: String =\
		"res://assets/user_interface/building_stack/building_card/"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

@export_group("Sprites")


@export_subgroup("Foreground")

## Data definition for foreground sprites based on key
## [enum Building.BuildingClass] and the corresponding [CompressedTexture2D]
## value.
@export var foreground_sprites: Dictionary[Building.BuildingClass, CompressedTexture2D] = {}


@export_subgroup("Building Sprite Variations")

## Data definition for building sprite variations based on key
## [enum Building.BuildingType] and the corresponding [Array] of sprite file
## names ([String]).
@export var building_sprite_variations: Dictionary[Building.BuildingType, Array] = {}


@export_group("Dynamic Transform")

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
#region Private variables

var _is_pickable: bool = false
var _is_picked: bool = false
var _building_type: Building.BuildingType = Building.BuildingType.NONE
var _variation_value: float = INF

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
		if $BackgroundSprite2D.get_rect().has_point(to_local(event.position)):
			_set_hovered()
		else:
			_unset_hovered()

	if event is InputEventMouseButton and event.pressed:
		var is_event_inside: bool =\
				$BackgroundSprite2D.get_rect().has_point(to_local(event.position))

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
func get_size() -> Vector2:
	return $BackgroundSprite2D.get_rect().size


## Returns the [enum Building.BuildingType] of this building card.
func get_building_type() -> Building.BuildingType:
	return _building_type


## Returns the building sprite variation value of this building card. See
## [method set_type_and_variation].[br]
## [br]
## Returns [constant @GDScript.INF] if the building card is in an invalid state
## and will cause undefined behavior if used.
func get_variation_value() -> float:
	return _variation_value


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
## [method is_picked].[br]
## [br]
## Set [param quiet] to [code]true[/code] to disable signal emitting.
func set_picked(quiet: bool = false) -> void:
	_is_picked = true
	if not quiet:
		UIEventBus.building_card_picked.emit(
				get_building_type(),
				get_variation_value())
	scale = Vector2.ONE * (float(picked_scale) / 100)
	position.y -= picked_offset


## Sets this building card as NOT being picked up by the player. See
## [method is_picked].[br]
## [br]
## Set [param quiet] to [code]true[/code] to disable signal emitting.
func unset_picked(quiet: bool = false) -> void:
	_is_picked = false
	if not quiet:
		UIEventBus.building_card_dropped.emit(
				get_building_type(),
				get_variation_value())
	scale = Vector2.ONE * (float(pickable_scale) / 100)
	position.y += picked_offset


## Update the visual elements for this building card to match
## [param building_type]
## @deprecated: Use [method set_type_and_variation] instead.
func set_type(building_type: Building.BuildingType) -> void:
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

	$BuildingSprite2D.texture = load(Building.BUILDING_ASSET_DIR.path_join(
			building_sprite_variations[building_type][0]))
	$ForegroundSprite2D.texture =\
			foreground_sprites[Building.get_building_class_of_type(building_type)]
	$BuildingNameLabel.text = Building.BUILDING_NAME[building_type]
	_building_type = building_type


## Update the visual elements for this building card to match
## [param building_type], then sets the building sprite variation based on
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
	$BuildingSprite2D.texture = load(Building.BUILDING_ASSET_DIR.path_join(
			variations[variation_index]))
	$ForegroundSprite2D.texture =\
			foreground_sprites[Building.get_building_class_of_type(building_type)]
	$BuildingNameLabel.text = Building.BUILDING_NAME[building_type]
	_building_type = building_type
	_variation_value = variation_value

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
