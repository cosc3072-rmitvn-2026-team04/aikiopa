@icon("res://assets/icons/sfx_controller.svg")
class_name SfxController
extends Node
## Simple controller for 2D sound effects.[br]
## [br]
## [b]Usage:[/b] Include all needed sound effect as children of this node.
## Nested children are not allowed. The only accepted node types are
## [AudioStreamPlayer] and [AudioStreamPlayer2D].[br]
## [br]
## Throws a failed assertion if the structure of its children does not satisfy
## the above requirements.


# ============================================================================ #
#region Signals

## Emitted when a child [AudioStreamPlayer] or [AudioStreamPlayer2D] finishes
## playing. [b]Note:[/b] Not emitted when exiting the tree while sounds are
## playing.
signal playback_finished(sfx_name: StringName)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Exported members

@export_group("Randomization", "random_")

## [i]Absolute[/i] threshold for pitch scale randomization when calling
## [method play_sound] or [method play_sound_2d] with the flag
## [code]randomize_pitch[/code] set to [code]true[/code].
## [br][br]
## Pitch randomization works by adding a random number within this threshold
## (could be negative or positive) to the [member AudioStreamPlayer.pitch_scale]
## of the [AudioStreamPlayer] node.
@export_range(0.0, 16.0, 0.001, "or_greater")
var pitch_scale_random_threshold: float = 5.0 / 12.0 # Perfect fourth.

## [i]Absolute[/i] threshold for volume randomization when calling
## [method play_sound] or [method play_sound_2d] with the flag
## [code]randomize_volume[/code] set to [code]true[/code].
## [br][br]
## Volume randomization works by adding a random number within this threshold
## (could be negative or positive) to the [member AudioStreamPlayer.volume_db]
## of the [AudioStreamPlayer] node.
@export_range(0.0, 30.0, 0.01, "exp", "suffix:dB")
var volume_random_threshold: float = 4.0

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	var children: Array[Node] = get_children()
	if children.size() == 0:
		return

	for child in children:
		assert((child is AudioStreamPlayer) or (child is AudioStreamPlayer2D),
				"SfxController must contain only AudioStreamPlayer or AudioStreamPlayer2D")
		assert(child.get_child_count(true) == 0,
				"SfxController does not accept nested children.")
		child.finished.connect(func (): playback_finished.emit(child.name))

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Plays the child [AudioStreamPlayer] identified by [param audio_stream_name].
## Set [param randomize_pitch] and/or [param randomize_volume] to control
## playback randomization.
func play_sound(
		audio_stream_name: StringName,
		randomize_pitch: bool = false,
		randomize_volume: bool = false
) -> void:
	var audio_stream_player: AudioStreamPlayer = get_node(
			"%s" % audio_stream_name)
	if audio_stream_player:
		var original_pitch_scale: float = audio_stream_player.pitch_scale
		var original_volume_db: float = audio_stream_player.volume_db
		if randomize_pitch:
			audio_stream_player.pitch_scale += Global.rng.randf_range(
					-pitch_scale_random_threshold,
					pitch_scale_random_threshold
			)
		if randomize_volume:
			audio_stream_player.volume_db += Global.rng.randf_range(
					-volume_random_threshold,
					volume_random_threshold
			)

		audio_stream_player.play()
		await audio_stream_player.finished

		if randomize_pitch:
			audio_stream_player.pitch_scale = original_pitch_scale
		if randomize_volume:
			audio_stream_player.volume_db = original_volume_db


## Plays the child [AudioStreamPlayer2D] identified by
## [param audio_stream_name]. Set [param randomize_pitch] and/or
## [param randomize_volume] to control playback randomization.
func play_sound_2d(
		audio_stream_name: StringName, position: Vector2, global: bool = true,
		randomize_pitch: bool = false,
		randomize_volume: bool = false
) -> void:
	var audio_stream_player: AudioStreamPlayer2D = get_node(
			"%s" % audio_stream_name)
	if audio_stream_player:
		if global:
			audio_stream_player.global_position = position
		else:
			audio_stream_player.position = position

		var original_pitch_scale: float = audio_stream_player.pitch_scale
		var original_volume_db: float = audio_stream_player.volume_db
		if randomize_pitch:
			audio_stream_player.pitch_scale += Global.rng.randf_range(
					-pitch_scale_random_threshold,
					pitch_scale_random_threshold
			)
		if randomize_volume:
			audio_stream_player.volume_db += Global.rng.randf_range(
					-volume_random_threshold,
					volume_random_threshold
			)

		audio_stream_player.play()
		await audio_stream_player.finished

		if randomize_pitch:
			audio_stream_player.pitch_scale = original_pitch_scale
		if randomize_volume:
			audio_stream_player.volume_db = original_volume_db

#endregion
# ============================================================================ #
