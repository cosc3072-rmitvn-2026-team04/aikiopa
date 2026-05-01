extends GameScene2D
## Credits.


# ============================================================================ #
#region Exported properties

@export_range(10.0, 100.0, 0.1, "or_greater", "suffix:px/s")
var auto_scroll_speed: float = 10.0

@export_range(10.0, 1000.0, 0.1, "or_greater", "suffix:px/s")
var manual_scroll_speed: float = 10.0

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private variables

var _current_scroll_position: float = 0.0
var _scroll_paused: bool = false

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	_scene_transition_in()

	%ScrollRestartTimer.timeout.connect(_on_scroll_restart_timer_timeout)

	visibility_changed.connect(_on_visibility_changed)
	%ScrollContainer.scroll_started.connect(_on_scroll_container_scroll_started)
	%ScrollContainer.gui_input.connect(_on_scroll_container_gui_input)
	%ScrollContainer.resized.connect(_on_scroll_container_resized)

	_set_header_and_footer()
	_scroll_paused = false


func _process(delta: float) -> void:
	if not visible:
		return

	var input_axis = Input.get_axis("ui_up", "ui_down")
	if input_axis != 0:
		# Manual scrolling.
		_apply_scroll(input_axis * manual_scroll_speed * delta)
		_start_scroll_restart_timer()
	elif not _scroll_paused:
		# Auto scrolling.
		_apply_scroll(auto_scroll_speed * delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_scroll_paused = true
		MainMenu.scene_transition_in_enabled = false
		await _scene_transition_out()
		scene_finished.emit(SceneKey.MAIN_MENU)

#endregion
# ============================================================================ #


# ============================================================================ #
#region Private methods

func _scene_transition_in() -> void:
	%SceneTransitionAnimationPlayer.play(&"transition_in")
	await %SceneTransitionAnimationPlayer.animation_finished


func _scene_transition_out() -> void:
	%SceneTransitionAnimationPlayer.play(&"transition_out")
	await %SceneTransitionAnimationPlayer.animation_finished


func _start_scroll_restart_timer() -> void:
	_scroll_paused = true
	%ScrollRestartTimer.start()


func _apply_scroll(amount: float) -> void:
	_current_scroll_position += amount

	var content_height: float = %ScrollContainer.get_v_scroll_bar().max_value
	var max_scroll: float = content_height - %ScrollContainer.size.y
	_current_scroll_position = clampf(_current_scroll_position, 0.0, max_scroll)
	%ScrollContainer.scroll_vertical = int(_current_scroll_position)

	if _current_scroll_position >= max_scroll and max_scroll > 0:
		_scroll_paused = true


func _set_header_and_footer() -> void:
	%HeaderSpaceControl.custom_minimum_size.y = get_viewport_rect().size.y
	%FooterSpaceControl.custom_minimum_size.y = get_viewport_rect().size.y
	%RichTextLabel.custom_minimum_size.x = get_viewport_rect().size.x

#endregion
# ============================================================================ #


# ============================================================================ #
#region Signal listeners

# Listens to _scroll_resart_timer.timeout.
func _on_scroll_restart_timer_timeout() -> void:
	# Sync tracker with the actual UI position.
	_current_scroll_position = float(%ScrollContainer.scroll_vertical)
	_scroll_paused = false


# Listens to visibility_changed.
func _on_visibility_changed() -> void:
	if visible:
		_current_scroll_position = 0.0
		%ScrollContainer.scroll_vertical = 0
		%RichTextLabel.grab_focus()
		_scroll_paused = false


# Listens to %ScrollContainer.scroll_started.
func _on_scroll_container_scroll_started() -> void:
	# Pause auto-scroll if touch/drag starts.
	_start_scroll_restart_timer()


# Listens to %ScrollContainer.gui_input.
func _on_scroll_container_gui_input(event: InputEvent) -> void:
	# Pause auto-scroll if mouse wheel is used.
	if event is InputEventMouseButton:
		if (
				event.button_index == MOUSE_BUTTON_WHEEL_UP
				or event.button_index == MOUSE_BUTTON_WHEEL_DOWN
		):
			_current_scroll_position = float(%ScrollContainer.scroll_vertical)
			_start_scroll_restart_timer()


# Listens to %ScrollContainer.resized.
func _on_scroll_container_resized() -> void:
	_current_scroll_position = float(%ScrollContainer.scroll_vertical)
	_set_header_and_footer()

#endregion
# ============================================================================ #
