class_name GameScene2D
extends Control


## Signals whether this scene is done processing and is ready to switch to the
## next scene.
## [br][br]
## Not emitted by default. Must be emitted manually.
## [br][br]
## This signal is connected to [Main]. [param next_scene_key] is used for the
## next scene change.
@warning_ignore("unused_signal")
signal scene_finished(next_scene_key: SceneKey)

enum SceneKey {
	MAIN_MENU,
	NONE,
}

const GAME_SCENE = {
	SceneKey.MAIN_MENU: "res://scenes/main_menu/main_menu.tscn",
}
