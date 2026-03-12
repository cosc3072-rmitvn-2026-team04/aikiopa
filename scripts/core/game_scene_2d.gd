class_name GameScene2D
extends Node2D


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
	PROLOGUE_TUTORIAL,
	FREE_PLAY,
	SAVEGAME_LOADER,
	SETTINGS,
	CREDITS,
	NONE,
}

const GAME_SCENE: Dictionary[int, String] = {
	SceneKey.MAIN_MENU: "res://scenes/main_menu/main_menu.tscn",
	SceneKey.PROLOGUE_TUTORIAL: "res://scenes/prologue_tutorial/prologue_tutorial.tscn",
	SceneKey.FREE_PLAY: "res://scenes/prologue_tutorial/prologue_tutorial.tscn",
	SceneKey.SAVEGAME_LOADER: "res://scenes/prologue_tutorial/prologue_tutorial.tscn",
	SceneKey.SETTINGS: "res://scenes/prologue_tutorial/prologue_tutorial.tscn",
	SceneKey.CREDITS: "res://scenes/prologue_tutorial/prologue_tutorial.tscn",
}
