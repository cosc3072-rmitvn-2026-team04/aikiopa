extends CharacterBody2D


# ============================================================================ #
#region Exported properties

@export_group("Pan", "pan")

## Speed of the camera's panning.
@export_range(50.0, 5000.0, 5.0, "suffix:px/s") var pan_speed: int = 2500

## The sensitivity of mouse-controlled panning. Higher values result in more
## rapid panning.
@export_range(0.01, 10.0, 0.01) var pan_mouse_sensitivity: float = 1.0


@export_group("Zoom", "zoom")

## Mininimum camera zoom (zoom out).
@export_range(0.5, 1.0, 0.01) var zoom_min: float = 1.0

## Maximum camera zoom (zoom in).
@export_range(1.0, 2.0, 0.01) var zoom_max: float = 1.0

## The amount of zoom change per zoom command from the player.
@export_range(0.01, 0.1, 0.01) var zoom_increment: float = 0.01

## The rate of zoom per [method Node._process] frame.
@export_range(1.0, 100.0, 1.0) var zoom_rate: float =  1.0

@export_group("", "")


@export var world: World = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	%Camera2D.zoom_min = zoom_min
	%Camera2D.zoom_max = zoom_max
	%Camera2D.zoom_increment = zoom_increment
	%Camera2D.zoom_rate = zoom_rate

	GameplayEventBus.building_placed.connect(_on_building_placed)


func _physics_process(delta: float) -> void:
	var fps_sync: float = delta * Engine.physics_ticks_per_second
	var movement: Vector2 = Input.get_vector(
			"player_camera_left",
			"player_camera_right",
			"player_camera_up",
			"player_camera_down")

	if movement:
		# Keyboard-controlled panning.
		velocity = movement * pan_speed * fps_sync / %Camera2D.zoom
	elif Input.is_action_pressed("player_camera_mouse_pan"):
		# Mouse-controlled panning.
		var mouse_velocity: Vector2 = Input.get_last_mouse_screen_velocity()
		mouse_velocity.clampf(-pan_speed, pan_speed)
		velocity = -mouse_velocity * pan_mouse_sensitivity * fps_sync / %Camera2D.zoom
	else:
		velocity = Vector2.ZERO

	move_and_slide()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods


## Forces this player camera to become the current active one.
func make_current() -> void:
	%Camera2D.make_current()


## Sets this player camera's position immediately to its current smoothing
## destination.
func reset_smoothing() -> void:
	%Camera2D.reset_smoothing()


## Returns the tile position of the camera on the map. Undefined behavior if
## [member world] is not set.
func get_map_coords() -> Vector2i:
	if world:
		return world.local_to_map(position)
	return Vector2i(-1, -1)


## Returns the chunk offset that the camera is in. Undefined behavior if
## [member world] is not set.
func get_chunk_position() -> Vector2i:
	if get_map_coords() == Vector2i(INF, INF):
		return get_map_coords()
	var map_position: Vector2 = Vector2(get_map_coords())

	var chunk_size: Vector2 = Vector2(world.get_chunk_size())
	return Vector2i(
			roundi(map_position.x / chunk_size.x - 0.5),
			roundi(map_position.y / chunk_size.y - 0.5))

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to
# GameplaEventBus.building_placed(
#		coords: Vector2i,
#		building_type: Building.BuildingType).
func _on_building_placed(
		coords: Vector2i,
		_building_type: Building.BuildingType
) -> void:
	position = world.get_terrain_tile_map_layer().map_to_local(coords)

#endregion
# ============================================================================ #
