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
@export_range(0.1, 1.0, 0.1, "or_greater", "suffix:s") var lifetime: float = 1.0

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
	_destruction_trigger_timer.timeout.connect(_on_destruction_trigger_timer_timeout)

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
func execute(world: World, target_coords: Vector2i) -> void:
	world.add_child(self)
	position = world.map_to_local(target_coords)
	_destruction_trigger_timer.start()

	_execute_hook()

	await get_tree().create_timer(lifetime).timeout
	world.remove_child(self)
	queue_free()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

## [color=deepskyblue][b]Virtual:[/b][/color] Override this method in children
## scenes to provide the appropriate behavior.[br]
## [br]
## Defines the custom behavior for this [Disaster] instance. Invoked in
## [method execute] after the instance is initialized and added to the [World]
## and before its [member lifetime] is expired. Useful for internal scene logic
## (animated sprites, sound effects, etc.).[br]
## [br]
## [b]Note:[/b] This method runs independent of the
## [code]DestructionTriggerTimer[/code] node, which is the trigger for the
## [World] to apply the destruction logic caused by this disaster. Keep in mind
## its [code]wait_time[/code] when syncing custom behavior to the destruction
## logic.[br]
## [br]
## [color=orange][b]WARNING:[/b] This method should only be used for internal
## scene logic. Attempts to modify external states will result in undefined
## behavior.[/color]
func _execute_hook() -> void:
	pass


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
