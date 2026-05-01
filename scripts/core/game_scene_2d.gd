class_name GameScene2D
extends Node2D
## Base class for top-level game scenes. Contains logic and data for automated
## scene switching.


# ============================================================================ #
#region Signals

#region Animated scene transition

## Signal whether this scene has started its animated scene transition out
## sequence to the next scene. Must be emitted manually.[br]
## [br]
## This signal is connected to [Main] to handle smooth visual transition between
## scenes. [param background_color] identifies the fallback background color
## that may appear in the duration between the previous scene being freed and
## the next scene being initialized.
@warning_ignore("unused_signal")
signal scene_transition_out_started(background_color: Color)

## Signal whether this scene has finished its animated scene transition in
## sequence from the previous scene. Must be emitted manually.[br]
## [br]
## This signal is connected to [Main] to handle smooth visual transition between
## scenes.
@warning_ignore("unused_signal")
signal scene_transition_in_finished

#endregion


#region Scene switching logic

## Signals whether this scene is done processing and is ready to switch to the
## next scene. Must be emitted manually.
## [br][br]
## This signal is connected to the scene switching logic in [Main].
## [param next_scene_key] identifies the next scene.
@warning_ignore("unused_signal")
signal scene_finished(next_scene_key: SceneKey)

#endregion

#endregion
# ============================================================================ #


# ============================================================================ #
#region Enums

## The scenes available for the player in the game.
enum SceneKey {
	SPLASH_SCREEN,
	MAIN_MENU,
	PLAY,
	GALLERY,
	SAVE_LOADER,
	GALLERY_LOADER,
	SETTINGS,
	CREDITS,
	NONE,
}

#endregion
# ============================================================================ #


# ============================================================================ #
#region Constants

## The absolute file path for each [enum SceneKey] scene.
const GAME_SCENE: Dictionary[SceneKey, String] = {
	SceneKey.SPLASH_SCREEN: "res://scenes/splash_screen.tscn",
	SceneKey.MAIN_MENU: "res://scenes/main_menu.tscn",
	SceneKey.PLAY: "res://scenes/game_container/play.tscn",
	SceneKey.SAVE_LOADER: "res://scenes/save_loader/save_loader.tscn",
	SceneKey.GALLERY: "res://scenes/game_container/gallery.tscn",
	SceneKey.GALLERY_LOADER: "res://scenes/gallery_loader/gallery_loader.tscn",
	SceneKey.SETTINGS: "res://scenes/settings.tscn",
	SceneKey.CREDITS: "res://scenes/credits.tscn",
}

#endregion
# ============================================================================ #
