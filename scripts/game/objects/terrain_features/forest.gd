extends TerrainFeature


# ============================================================================ #
#region Public variables

var is_enclosed: bool

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	super()
	is_enclosed = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Overriden methods

func get_type() -> FeatureType:
	return TerrainFeature.FeatureType.FOREST

#endregion
# ============================================================================ #
