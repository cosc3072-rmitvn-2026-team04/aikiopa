class_name GameUI
extends Control
## Must be a child of a [CanvasLayer] for correct scaling.

## Emitted when a child UI element requests the parent scene to perform an
## [param action].
@warning_ignore("unused_signal")
signal acted(action: StringName)

## Emitted when a child UI element requests the parent scene to perform an
## [param action]. Includes a [param data] payload that can be passed up the
## node tree to the parent scene.
@warning_ignore("unused_signal")
signal acted_with_data(action: StringName, data: Variant)
