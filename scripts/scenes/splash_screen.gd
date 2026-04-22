extends GameScene2D


# @onread -> use $ or %

var _animation_player: AnimationPlayer = %Sprite2D.AnimationPlayer


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
    _animation_player.connect("animation_finished", _end_splash.unbind(1))
    _animation_player.play("default") # change default ->...


func _process(_delta: float) -> void:
    if Input.is_action_pressed("ui_cancel"):
        _end_splash()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _end_splash() -> void:
    _animation_player.stop(true)
    scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #
