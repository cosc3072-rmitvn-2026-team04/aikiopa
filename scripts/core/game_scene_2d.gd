class_name GameScene2D
extends Node2D


## Signals whether this scene is done processing and is ready to switch to the
## next scene. Must be emitted manually.
## [br][br]
## This signal is connected to [Main]. [param next_scene_key] identifies the
## next scene.
@warning_ignore("unused_signal")
signal scene_finished(next_scene_key: SceneKey)

enum SceneKey {
	MAIN_MENU,
	TUTORIAL,
	FREE_PLAY,
	SAVE_LOADER,
	SETTINGS,
	CREDITS,
	NONE,
}

const GAME_SCENE: Dictionary[SceneKey, String] = {
	SceneKey.MAIN_MENU: "res://scenes/main_menu.tscn",
	SceneKey.TUTORIAL: "res://scenes/tutorial.tscn",
	SceneKey.FREE_PLAY: "res://scenes/free_play.tscn",
	SceneKey.SAVE_LOADER: "res://scenes/save_loader.tscn",
	SceneKey.SETTINGS: "res://scenes/settings.tscn",
	SceneKey.CREDITS: "res://scenes/credits.tscn",
}
