extends Node2D


# ============================================================================ #
#region Constants

const BUILDING_ASSET_PATH = "res://assets/objects/"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

@export_group("Appearance")


@export_subgroup("Building Preview", "building_preview")

## The [member CanvasItem.modulate] of snapped building preview.
@export var building_preview_snapped_modulate: Color = Color(Color.WHITE, 1.0)

## The [member CanvasItem.modulate] of unsnapped building preview.
@export var building_preview_unsnapped_modulate: Color = Color(Color.WHITE, 0.5)


@export_subgroup("Population Change Preview", "population_change_preview")

## Color of the Population Change Preview label when its value is greater than
## [code]0[/code].
@export_color_no_alpha
var population_change_preview_positive_color: Color = Color.GREEN

## Color of the Population Change Preview label when its value is lesser than
## [code]0[/code].
@export_color_no_alpha
var population_change_preview_negative_color: Color = Color.RED


@export_subgroup("Building Bonus Preview", "building_bonus_preview")

## Color of the Building Bonus Preview label.
@export_color_no_alpha var building_bonus_preview_color: Color = Color.YELLOW


@export_group("", "")

@export var world: World = null
@export var building_ruleset_engine: BuildingRulesetEngine = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

var _picked_building_type: Building.BuildingType = Building.BuildingType.NONE

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	UIEventBus.building_card_picked.connect(_on_building_card_picked)
	UIEventBus.building_card_dropped.connect(_on_building_card_dropped)
	GameplayEventBus.building_placed.connect(_on_building_placed)
	_unload_preview_building_sprite()
	_init_population_change_preview_label()
	_init_building_bonus_preview_label()


func _process(_delta: float) -> void:
	position = world.get_local_mouse_position()
	_process_snap_preview_building_sprite()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _init_population_change_preview_label() -> void:
	if %PopulationChangePreviewLabel.has_theme_color_override(&"font_color"):
		%PopulationChangePreviewLabel.remove_theme_color_override(&"font_color")
	%PopulationChangePreviewLabel.add_theme_color_override(
			&"font_color", population_change_preview_positive_color)
	%PopulationChangePreviewLabel.hide()


func _init_building_bonus_preview_label() -> void:
	if %BuildingBonusPreviewLabel.has_theme_color_override(&"font_color"):
		%BuildingBonusPreviewLabel.remove_theme_color_override(&"font_color")
	%BuildingBonusPreviewLabel.add_theme_color_override(
			&"font_color", building_bonus_preview_color)
	%BuildingBonusPreviewLabel.hide()


func _load_preview_building_sprite(building_type: Building.BuildingType) -> void:
	match building_type:
		Building.BuildingType.HOUSING:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_housing.png"))
		Building.BuildingType.GREENHOUSE:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_greenhouse.png"))
		Building.BuildingType.RANCH:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_ranch.png"))
		Building.BuildingType.FISHERY:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_fishery.png"))
		Building.BuildingType.SOLAR_FARM:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_solar_farm.png"))
		Building.BuildingType.WIND_FARM:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_wind_farm.png"))
		Building.BuildingType.NUCLEAR_REACTOR:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_nuclear_reactor.png"))
		Building.BuildingType.FACTORY:
			$PreviewBuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_factory.png"))
		_:
			push_error("Unrecognized building type: '%s'." % [
				Building.BuildingType.keys()[building_type]
			])
			return
	_picked_building_type = building_type


func _unload_preview_building_sprite() -> void:
	%PreviewBuildingSprite2D.texture = null
	_picked_building_type = Building.BuildingType.NONE


func _process_snap_preview_building_sprite() -> void:
	var map_coords: Vector2i = world.local_to_map(position)
	var ruleset_parse_result: Dictionary[StringName, Variant] =\
			building_ruleset_engine.parse_rules(map_coords, _picked_building_type)
	if (
			ruleset_parse_result.placement_check_status
			== BuildingRulesetEngine.PlacementCheckStatus.ALLOWED
	):
		_snap_preview(
				map_coords,
				ruleset_parse_result.interaction_result.get_population_change(),
				ruleset_parse_result.interaction_result.get_building_bonus())
		UIEventBus.preview_cursor_snapped.emit(
				map_coords,
				_picked_building_type,
				ruleset_parse_result.placement_check_status,
				ruleset_parse_result.interaction_result.duplicate())
	else:
		_unsnap_preview()
		UIEventBus.preview_cursor_unsnapped.emit()


func _snap_preview(
		map_coords: Vector2i,
		population_change: int,
		building_bonus: int
) -> void:
	var target_position: Vector2 = world.map_to_local(map_coords)
	target_position = world.to_global(target_position)
	target_position = to_local(target_position)
	%PreviewBuildingSprite2D.position = target_position
	%PreviewBuildingSprite2D.modulate = building_preview_snapped_modulate

	if population_change < 0:
		%PopulationChangePreviewLabel.show()
		%PopulationChangePreviewLabel.text = "%d👨‍🚀" % [population_change]
		if %PopulationChangePreviewLabel.has_theme_color_override(&"font_color"):
			%PopulationChangePreviewLabel.remove_theme_color_override(&"font_color")
		%PopulationChangePreviewLabel.add_theme_color_override(
				&"font_color", population_change_preview_negative_color)
	elif population_change > 0:
		%PopulationChangePreviewLabel.show()
		%PopulationChangePreviewLabel.text = "+%d👨‍🚀" % [population_change]
		if %PopulationChangePreviewLabel.has_theme_color_override(&"font_color"):
			%PopulationChangePreviewLabel.remove_theme_color_override(&"font_color")
		%PopulationChangePreviewLabel.add_theme_color_override(
				&"font_color", population_change_preview_positive_color)

	if building_bonus > 0:
		%BuildingBonusPreviewLabel.show()
		%BuildingBonusPreviewLabel.text = "+%d🏠" % [building_bonus]


func _unsnap_preview() -> void:
	%PreviewBuildingSprite2D.position = Vector2.ZERO
	%PreviewBuildingSprite2D.modulate = building_preview_unsnapped_modulate
	%PopulationChangePreviewLabel.hide()
	%BuildingBonusPreviewLabel.hide()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# UIEventBus.building_card_picked(building_type: Building.BuildingType).
func _on_building_card_picked(building_type: Building.BuildingType) -> void:
	_load_preview_building_sprite(building_type)


# Listens to
# UIEventBus.building_card_dropped(building_type: Building.BuildingType).
func _on_building_card_dropped(_building_type: Building.BuildingType) -> void:
	_unload_preview_building_sprite()


# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		_building_type: Building.BuildingType,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	_unload_preview_building_sprite()

#endregion
# ============================================================================ #
