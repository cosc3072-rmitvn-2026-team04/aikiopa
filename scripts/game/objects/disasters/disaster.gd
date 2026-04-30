class_name Disaster
extends Node2D


# ============================================================================ #
#region Enums

## The disaster types available in the game.
enum DisasterType {
	NONE,
	METEOR_STRIKE,
	EARTHQUAKE,
}

## The shape of the destruction area in the [World].
enum DestructionPattern {
	## Placeholder value. Has no effect and will cause an error to be printed if
	## used during runtime.
	PATTERN_NULL,

	## Circular area with radius specified by [member destruction_pattern_size].
	## A radius of [code]0[/code] is the center tile; [code]1[/code] includes
	## the first ring of neighbors, [code]2[/code] includes the second ring,
	## and so on.
	PATTERN_CIRCULAR,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported properties

## The [enum DestructionPattern] for this disaster event.
@export var destruction_pattern: DestructionPattern

## The size of the [enum DestructionPattern] for this disaster event.
@export var destruction_pattern_size: int

## The lifetime of the disaster event in seconds, after which the disaster
## instance would be removed and freed. Must be longer than the
## [member Timer.wait_time] of the [code]DestructionTriggerTimer[/code].
@export_range(0.1, 1.0, 0.1, "or_greater", "suffix:s") var lifetime: float = 0.5

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _target_coords: Vector2i
@onready var _destruction_trigger_timer: Timer = $DestructionTriggerTimer

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	assert(
			_destruction_trigger_timer.wait_time <= lifetime,
			"Fatal: 'DestructionTriggerTimer.wait_time' must not be longer than 'lifetime'.")

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Returns the [enum DisasterType] of this [Disaster] instance.[br]
## [br]
## Virtual method. Override in children scenes to provide the correct return
## value.
func get_type() -> DisasterType:
	push_warning("Calling method 'get_type()' on generic 'Disaster' instance.")
	return DisasterType.NONE


## Starts, processes, and finishes the [Disaster]. The disaster is first added
## as a child in [param world] at [param target_coords], then its logic would be
## processed, before being removed and freed at the end of its
## [member lifetime].
func process(world: World, target_coords: Vector2i) -> void:
	world.get_disaster_layer().add_child(self)
	_destruction_trigger_timer.timeout.connect(
			_on_destruction_trigger_timer_timeout)

	position = world.map_to_local(target_coords)
	$AnimationPlayer.play(&"main")
	$SfxController.play_sound_2d(
			&"DisasterSound2D", Vector2.ZERO,
			false, true, true)

	await get_tree().create_timer(lifetime).timeout
	world.get_disaster_layer().remove_child(self)
	queue_free()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _get_destruction_area(target_coords: Vector2i) -> Array[Vector2i]:
	match destruction_pattern:
		DestructionPattern.PATTERN_CIRCULAR:
			return Math.HexGrid.get_offset_area_from_range_at(
					target_coords, destruction_pattern_size,
					Math.HexGrid.OffsetLayout.ODD_R)
		_:
			push_error("Disaster pattern '%s' not implemented" % [
				DestructionPattern.keys()[destruction_pattern],
			])
			return []

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

func _on_destruction_trigger_timer_timeout() -> void:
	GameplayEventBus.disaster_destruction_triggered.emit(
			_get_destruction_area(_target_coords))

#endregion
# ============================================================================ #
