extends Camera2D


# ============================================================================ #
#region Exported properties

@export_group("Pan", "pan")

## Speed of the camera's panning. Only affects keyboard-controlled camera
## panning.
@export_range(50.0, 5000.0, 5.0, "suffix:px/s") var pan_speed: int = 2500


@export_group("Zoom", "zoom")

## Mininimum camera zoom (zoom out).
@export_range(0.1, 1.0, 0.01) var zoom_min: float = 1.0

## Maximum camera zoom (zoom in).
@export_range(1.0, 3.0, 0.01) var zoom_max: float = 1.0

## The amount of zoom change per zoom command from the player.
@export_range(0.01, 0.1, 0.01) var zoom_increment: float = 0.01

## The rate of zoom per [method Node._process] frame.
@export_range(1.0, 100.0, 1.0) var zoom_rate: float =  1.0

@export_group("", "")


@export var world: World = null
@export var card_stack_controller: CardStackController = null
@export var population_controller: PopulationController = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private properties

var _target_zoom: float = 0.5

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%DebugCanvasLayer.visible = false
	UIEventBus.gameplay_debug_mode_toggled.connect(
			_on_gameplay_debug_mode_toggled)
	%AddCardButton.pressed.connect(_on_add_card_button_pressed)
	%PopCardButton.pressed.connect(_on_pop_card_button_pressed)
	%ChangePopulationButton.pressed.connect(_on_change_population_button_pressed)
	%ShroudDisplayCheckBox.toggled.connect(_on_shroud_display_check_button_toggled)


func _process(delta: float) -> void:
	if is_current():
		# Update labels.
		var map_coords: Vector2i = world.local_to_map(position)
		%CameraMapCoordsLabel.text = "(%d, %d)" % [map_coords.x, map_coords.y ]
		%CameraZoomLabel.text = "Zoom: %.2f" % [zoom.x]
		%TerrainLabel.text = "%s 🏞️" % [
			World.TerrainType.keys()[world.get_terrain_at(map_coords)],
		]
		%BuildingLabel.text = "%s 🏠" % [
			Building.BuildingType.keys()[world.get_building_at(map_coords)],
		]

		var movement: Vector2 = Input.get_vector(
				"debug_camera_left",
				"debug_camera_right",
				"debug_camera_up",
				"debug_camera_down")
		position += movement * pan_speed * delta / zoom

		# Keyboard-controlled zooming.
		if (
				$KeyboardZoomDelayTimer.is_stopped()
				and	Input.is_action_pressed("debug_camera_zoom_in")
				and zoom.x < zoom_max
		):
			_zoom_in()
			$KeyboardZoomDelayTimer.start()
		if (
				$KeyboardZoomDelayTimer.is_stopped()
				and Input.is_action_pressed("debug_camera_zoom_out")
				and zoom.x > zoom_min
		):
			_zoom_out()
			$KeyboardZoomDelayTimer.start()

		# Zoom interpolation (linear).
		if not is_equal_approx(zoom.x, _target_zoom):
			zoom = lerp(zoom, _target_zoom * Vector2.ONE, zoom_rate * delta)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _zoom_in() -> void:
	_target_zoom = min(_target_zoom + zoom_increment, zoom_max)


func _zoom_out() -> void:
	_target_zoom = max(_target_zoom - zoom_increment, zoom_min)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to UIEventBus.gameplay_debug_mode_toggled(toggled_on: bool).
func _on_gameplay_debug_mode_toggled(toggled_on: bool) -> void:
	if toggled_on:
		make_current()
		%DebugCanvasLayer.visible = true
	else:
		%DebugCanvasLayer.visible = false


# TODO: Update this (#21).
# Listens to %AddCardButton.pressed.
func _on_add_card_button_pressed() -> void:
	var added_building_type: Building.BuildingType =\
			card_stack_controller.add_building()
	%CardAddedLabel.text = " Added: %s " % [
		Building.BuildingType.keys()[added_building_type]
	]


# TODO: Update this (#21).
# Listens to %PopCardButton.pressed.
func _on_pop_card_button_pressed() -> void:
	var popped_building_type: Building.BuildingType =\
			card_stack_controller.pop_building()
	%CardPoppedLabel.text = " Popped: %s " % [
		Building.BuildingType.keys()[popped_building_type]
	]


# Listens to %ChangePopulationButton.pressed.
func _on_change_population_button_pressed() -> void:
	population_controller.change_population(int(%PopulationChangeSpinBox.value))


# Listens to %ShroudDisplayCheckBox.toggled(toggled_on: bool).
func _on_shroud_display_check_button_toggled(toggled_on: bool) -> void:
	UIEventBus.gameplay_debug_mode_shroud_toggled.emit(toggled_on)

#endregion
# ============================================================================ #
