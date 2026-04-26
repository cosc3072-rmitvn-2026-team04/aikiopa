extends Node2D


# ============================================================================ #
#region Exported properties

@export_group("Appearance")


@export_subgroup("Building Preview", "building_preview")

## The [member CanvasItem.modulate] of snapped building preview.
@export var building_preview_snapped_modulate: Color = Color(Color.WHITE, 1.0)

## The [member CanvasItem.modulate] of unsnapped building preview.
@export var building_preview_unsnapped_modulate: Color = Color(Color.WHITE, 0.5)


@export_subgroup("Population Change Preview", "population_change_preview")

## Color of the [code]PopulationChangePreviewLabel[/code] when its value is
## greater than [code]0[/code].
@export_color_no_alpha
var population_change_preview_positive_color: Color = Color.GREEN

## Color of the [code]PopulationChangePreviewLabel[/code] when its value is
## lesser than [code]0[/code].
@export_color_no_alpha
var population_change_preview_negative_color: Color = Color.RED

## Color of the [code]PopulationChangePreviewLabel[/code] when its value is
## equal to [code]0[/code].
@export_color_no_alpha
var population_change_preview_neutral_color: Color = Color.WHITE


@export_subgroup("Building Bonus Preview", "building_bonus_preview")

## Color of the [code]BuildingBonusPreviewLabel[/code].
@export_color_no_alpha var building_bonus_preview_color: Color = Color.YELLOW


@export_subgroup("Terrain Feature Context Preview", "terrain_feature_context_preview")

## Color modulation of terrain features to warn the player that placing a
## building on top would destroy them.
@export var terrain_feature_context_preview_modulate: Color = Color(1.0, 1.0, 1.0, 0.5)


@export_group("", "")

@export var world: World = null
@export var building_ruleset_engine: BuildingRulesetEngine = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

var _interaction_result_label_scene: PackedScene =\
		preload("res://scenes/game/cursor_ui/interaction_result_label.tscn")

var _picked_building_type: Building.BuildingType = Building.BuildingType.NONE
var _picked_building_variation_value: float = INF
var _context_applied_terrain_features: Array[TerrainFeature] = []
var _context_applied_buildings: Array[Building] = []
var _preview_snapped: bool = false

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
	_unsnap_preview()


func _process(_delta: float) -> void:
	position = world.get_local_mouse_position()
	_process_snap_preview_building_sprite()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _init_population_change_preview_label() -> void:
	%PopulationChangePreviewLabel.add_theme_color_override(
			&"font_color", population_change_preview_positive_color)
	%PopulationChangePreviewLabel.hide()


func _init_building_bonus_preview_label() -> void:
	%BuildingBonusPreviewLabel.add_theme_color_override(
			&"font_color", building_bonus_preview_color)
	%BuildingBonusPreviewLabel.hide()


func _reset_environment_interaction_result_labels() -> void:
	if %EnvironmentInteractionResultLabels.get_child_count() > 0:
		for label: Node2D in %EnvironmentInteractionResultLabels.get_children():
			%EnvironmentInteractionResultLabels.remove_child(label)
			label.queue_free()


func _load_preview_building_sprite(
		building_type: Building.BuildingType,
		variation_value: float
) -> void:
	%BuildingPreview.set_type_and_variation(building_type, variation_value)
	_picked_building_type = building_type
	_picked_building_variation_value = variation_value


func _unload_preview_building_sprite() -> void:
	%BuildingPreview.set_type_and_variation(
			Building.BuildingType.NONE,
			0.0)
	_picked_building_type = Building.BuildingType.NONE
	_picked_building_variation_value = INF


func _process_snap_preview_building_sprite() -> void:
	# HACK: This gets called every frame and is a performance bottleneck.
	_remove_neighbor_building_context()
	_remove_terrain_feature_context()
	var map_coords: Vector2i = world.local_to_map(position)
	var ruleset_parse_result: Dictionary[StringName, Variant] =\
			building_ruleset_engine.parse_rules(
					map_coords,
					_picked_building_type,
					false)
	if (
			ruleset_parse_result.placement_check_status
			== BuildingRulesetEngine.PlacementCheckStatus.ALLOWED
	): # HACK: This gets called every frame and is a performance bottleneck.
		_apply_neighbor_building_context(ruleset_parse_result.interaction_result)
		_apply_terrain_feature_context(map_coords, _picked_building_type)
		_snap_preview(
				map_coords,
				ruleset_parse_result.interaction_result)
		UIEventBus.preview_cursor_snapped.emit(
				map_coords,
				_picked_building_type,
				_picked_building_variation_value,
				ruleset_parse_result.placement_check_status,
				BuildingRulesetEngine.InteractionResult.sum(
						ruleset_parse_result.interaction_result.values()))
		_preview_snapped = true
	else:
		if _preview_snapped:
			_preview_snapped = false
			_unsnap_preview()
			UIEventBus.preview_cursor_unsnapped.emit()
		_apply_blocked_context(
			map_coords,
			ruleset_parse_result.placement_check_status,
			ruleset_parse_result.interaction_result)


func _snap_preview(
		map_coords: Vector2i,
		interaction_results: Dictionary[Vector2i, BuildingRulesetEngine.InteractionResult],
) -> void:
	var target_position: Vector2 = world.map_to_local(map_coords)
	target_position = world.to_global(target_position)
	target_position = to_local(target_position)
	%BuildingPreview.position = target_position
	%BuildingPreview.modulate = building_preview_snapped_modulate
	%BuildingPreview.snap(map_coords)

	var summarized_interaction_result: BuildingRulesetEngine.InteractionResult =\
			BuildingRulesetEngine.InteractionResult.sum(interaction_results.values())

	var total_population_change = summarized_interaction_result.get_population_change()
	%PopulationChangePreviewLabel.show()
	%PopulationChangePreviewLabel.text = "%+d👨‍🚀" % [total_population_change]
	if total_population_change > 0:
		%PopulationChangePreviewLabel.add_theme_color_override(
				&"font_color", population_change_preview_positive_color)
	elif total_population_change < 0:
		%PopulationChangePreviewLabel.add_theme_color_override(
				&"font_color", population_change_preview_negative_color)
	else:
		%PopulationChangePreviewLabel.add_theme_color_override(
				&"font_color", population_change_preview_neutral_color)

	var total_building_bonus: int = summarized_interaction_result.get_building_bonus()
	if total_building_bonus > 0:
		%BuildingBonusPreviewLabel.show()
		%BuildingBonusPreviewLabel.text = "+%d🏠" % [total_building_bonus]
	else:
		%BuildingBonusPreviewLabel.text = "NaN🏠"
		%BuildingBonusPreviewLabel.hide()

	_reset_environment_interaction_result_labels()
	for interaction_coords: Vector2i in interaction_results.keys():
		if interaction_coords != map_coords:
			var interaction_result: BuildingRulesetEngine.InteractionResult =\
					interaction_results[interaction_coords]
			var population_change: int = interaction_result.get_population_change()
			var building_bonus: int = interaction_result.get_building_bonus()

			var interaction_result_label: Node2D =\
					_interaction_result_label_scene.instantiate()
			interaction_result_label.display(population_change, building_bonus)

			var target_label_position: Vector2 = world.map_to_local(interaction_coords)
			target_label_position = world.to_global(target_label_position)
			target_label_position = to_local(target_label_position)
			interaction_result_label.position = target_label_position
			%EnvironmentInteractionResultLabels.add_child(interaction_result_label)



func _unsnap_preview() -> void:
	%BuildingPreview.unsnap()
	%BuildingPreview.position = Vector2.ZERO
	%BuildingPreview.modulate = building_preview_unsnapped_modulate
	%PopulationChangePreviewLabel.text = "NaN👨‍🚀"
	%PopulationChangePreviewLabel.hide()
	%BuildingBonusPreviewLabel.text = "NaN🏠"
	%BuildingBonusPreviewLabel.hide()
	_remove_neighbor_building_context()
	_remove_terrain_feature_context()
	_reset_environment_interaction_result_labels()


func _apply_neighbor_building_context(
		interaction_results: Dictionary[Vector2i, BuildingRulesetEngine.InteractionResult]
) -> void:
	for interaction_coords: Vector2i in interaction_results.keys():
		var interaction_result: BuildingRulesetEngine.InteractionResult =\
				interaction_results[interaction_coords]
		var population_change: int = interaction_result.get_population_change()
		var building_bonus: int = interaction_result.get_building_bonus()
		var building_layer: Node2D = world.get_building_layer()
		var building: Building = building_layer.get_building_instance_at(
				interaction_coords)
		if building:
			if population_change == 0:
				building.unset_highlight()
			elif population_change < 0:
				building.set_highlight(building.HighlightMode.HIGHLIGHT_NEGATIVE)
			else:
				building.set_highlight(building.HighlightMode.HIGHLIGHT_POSITIVE)

			if building_bonus > 0:
				building.set_highlight(building.HighlightMode.HIGHLIGHT_ALTERNATIVE)

			if not _context_applied_buildings.has(building):
				_context_applied_buildings.append(building)


func _remove_neighbor_building_context() -> void:
	if not _context_applied_buildings.is_empty():
		for building: Building in _context_applied_buildings:
			if building:
				building.unset_highlight()
		_context_applied_buildings.clear()


func _apply_terrain_feature_context(
		map_coords: Vector2i,
		building_type: Building.BuildingType
) -> void:
	var terrain_type: World.TerrainType = world.get_terrain_at(map_coords)
	if terrain_type in [
		World.TerrainType.SHALLOW_WATER_FISHES,
		World.TerrainType.PLAIN_FOREST,
		World.TerrainType.GRASSLAND_FOREST,
	]:
		if building_type == Building.BuildingType.FISHERY:
			return
		var terrain_feature_layer: Node = world.get_terrain_feature_layer()
		var terrain_feature: TerrainFeature =\
				terrain_feature_layer.get_feature_instance_at(map_coords)
		terrain_feature.modulate = terrain_feature_context_preview_modulate
		if not _context_applied_terrain_features.has(terrain_feature):
			_context_applied_terrain_features.append(terrain_feature)


func _remove_terrain_feature_context() -> void:
	if not _context_applied_terrain_features.is_empty():
		for terrain_feature: TerrainFeature in _context_applied_terrain_features:
			if terrain_feature:
				terrain_feature.modulate = Color.WHITE # Reset modulation to default.
		_context_applied_terrain_features.clear()


func _apply_blocked_context(
		map_coords: Vector2i,
		placement_check_status,
		interaction_results: Dictionary[Vector2i, BuildingRulesetEngine.InteractionResult]
) -> void:
	_reset_environment_interaction_result_labels()
	if (
			placement_check_status in [
				BuildingRulesetEngine.PlacementCheckStatus.BLOCKED_BY_TERRAIN,
				BuildingRulesetEngine.PlacementCheckStatus.BLOCKED_BY_ADJACENT_BUILDING,
			]
	):
		for interaction_coords: Vector2i in interaction_results.keys():
			if(
					interaction_coords == map_coords
					or interaction_results[interaction_coords] == null
			):
				var interaction_result_label: Node2D =\
						_interaction_result_label_scene.instantiate()
				interaction_result_label.display(0, 0, true)

				var target_label_position: Vector2 = world.map_to_local(interaction_coords)
				target_label_position = world.to_global(target_label_position)
				target_label_position = to_local(target_label_position)
				interaction_result_label.position = target_label_position
				%EnvironmentInteractionResultLabels.add_child(interaction_result_label)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to UIEventBus.building_card_picked(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_card_picked(
	building_type: Building.BuildingType,
	variation_value: float
) -> void:
	_load_preview_building_sprite(building_type, variation_value)


# Listens to UIEventBus.building_card_dropped(
#		building_type: Building.BuildingType,
#		variation_value: float).
func _on_building_card_dropped(
		_building_type: Building.BuildingType,
		_variation_value: float
) -> void:
	_unload_preview_building_sprite()


# Listens to GameplayEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType,
#		variation_value: float,
#		interaction_result: BuildingRulesetEngine.InteractionResult).
func _on_building_placed(
		_coords: Vector2i,
		_building_type: Building.BuildingType,
		_variation_value: float,
		_interaction_result: BuildingRulesetEngine.InteractionResult
) -> void:
	_unload_preview_building_sprite()

#endregion
# ============================================================================ #
