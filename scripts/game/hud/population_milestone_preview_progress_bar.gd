extends ProgressBar


# ============================================================================ #
#region Constants

const STYLE_BOX_BAR_POSITIVE: String =\
		"res://resources/themes/styleboxes/stylebox_effect_preview_positive.tres"
const STYLE_BOX_BAR_NEGATIVE: String =\
		"res://resources/themes/styleboxes/stylebox_effect_preview_negative.tres"

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Starts the flashing visual effect for the Population Milestone Preview
## Progress Bar.
func flash_start() -> void:
	$AnimationPlayer.play("flash")


## Stops and resets the flashing visual effect for the Population Milestone
## Preview Progress Bar.
func flash_reset() -> void:
	$AnimationPlayer.stop()

#endregion
# ============================================================================ #
