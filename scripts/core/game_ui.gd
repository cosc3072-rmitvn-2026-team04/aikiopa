class_name GameUI
extends Control
## Must be a child of a [CanvasLayer] for correct scaling.


# ============================================================================ #
#region Signals

## Emitted when a child UI element requests the parent scene to perform an
## [param action].
@warning_ignore("unused_signal")
signal acted(action: StringName)

## Emitted when a child UI element requests the parent scene to perform an
## [param action]. Includes a [param data] payload that can be passed up the
## node tree to the parent scene.
@warning_ignore("unused_signal")
signal acted_with_data(action: StringName, data: Variant)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

@onready var _ui_sfx_controller: SfxController = null

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_ui_sfx_controller = $/root/Main/UISfxController
	if not _ui_sfx_controller:
		push_warning("No UISfxController detected. UI SFX is disabled.")
	refresh_ui_sfx()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Refreshes and synchronizes UI sound effects for nodes in the following global
## groups:[br]
## [br]
## - [code]ui_buttons[/code][br]
## [br]
## Iterates through the groups above to ensure all member nodes are correctly
## connected to the central UI [SfxController]. This method is idempotent and
## should be called after instantiating new UI elements to register any newly
## qualified nodes.
func refresh_ui_sfx() -> void:
	for child in get_tree().get_nodes_in_group("ui_buttons"):
		if not child is Button:
			push_warning("Found non Button child '%s' in group 'ui_buttons'" % [
				child.get_path()
			])
			continue
		var button: Button = child as Button
		if not button.disabled:
			if not button.mouse_entered.is_connected(_on_ui_buttons_mouse_entered):
				button.mouse_entered.connect(_on_ui_buttons_mouse_entered)
			if not button.pressed.is_connected(_on_ui_buttons_pressed):
				button.pressed.connect(_on_ui_buttons_pressed)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

#region UI SFX listeners

func _on_ui_buttons_mouse_entered() -> void:
	if _ui_sfx_controller:
		_ui_sfx_controller.play_sound(&"ButtonHovered")


func _on_ui_buttons_pressed() -> void:
	if _ui_sfx_controller:
		_ui_sfx_controller.play_sound(&"ButtonPressed")

#endregion

#endregion
# ============================================================================ #
