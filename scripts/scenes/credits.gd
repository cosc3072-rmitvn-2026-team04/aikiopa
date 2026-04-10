extends GameScene2D


var auto_scroll_speed: float = 60.0
var input_scroll_speed: float = 400.0
var scroll_restart_delay: float = 1.5
var scroll_paused: bool = false

var timer: Timer = Timer.new()
var _current_scroll_position: float = 0.0

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var header_space: Control = %HeaderSpaceControl
@onready var footer_space: Control = %FooterSpaceControl

func _ready() -> void:
	# Timer
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_scroll_restart_timer_timeout)

	scroll_container.scroll_started.connect(_on_scroll_started)
	scroll_container.gui_input.connect(_on_gui_input)
	visibility_changed.connect(_on_visibility_changed)
	scroll_container.resized.connect(_on_resized)
	set_header_and_footer()
	scroll_paused = false

func _process(delta: float) -> void:
	if not visible or scroll_paused:
		return

	var input_axis = Input.get_axis("ui_up", "ui_down")
	if input_axis != 0:
		# manually scrolling
		_apply_scroll(input_axis * input_scroll_speed * delta)
		_start_scroll_restart_timer()
	else:
		# auto scrolling
		_apply_scroll(auto_scroll_speed * delta)

func _apply_scroll(amount: float) -> void:
	_current_scroll_position += amount

	# Calculate scroll distance
	var content_height = scroll_container.get_v_scroll_bar().max_value
	var max_scroll = content_height - scroll_container.size.y

	# Clamp to keep values within bounds
	_current_scroll_position = clamp(_current_scroll_position, 0, max_scroll)
	scroll_container.scroll_vertical = int(_current_scroll_position)

	if _current_scroll_position >= max_scroll and max_scroll > 0:
		_end_reached()

func _start_scroll_restart_timer() -> void:
	scroll_paused = true
	timer.start(scroll_restart_delay)

func _on_scroll_restart_timer_timeout() -> void:
	# Sync tracker with the actual UI position
	_current_scroll_position = float(scroll_container.scroll_vertical)
	scroll_paused = false

func _on_visibility_changed() -> void:
	if visible:
		_current_scroll_position = 0.0
		scroll_container.scroll_vertical = 0
		scroll_paused = false
		rich_text_label.grab_focus()

func _on_gui_input(event: InputEvent) -> void:
	# Pause auto-scroll if mouse wheel is used
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_start_scroll_restart_timer()

func _on_scroll_started() -> void:
	# Pause auto-scroll if touch/drag starts
	_start_scroll_restart_timer()

func _end_reached() -> void:
	scroll_paused = true

func set_header_and_footer() -> void:
	header_space.custom_minimum_size.y = get_viewport_rect().size.y
	footer_space.custom_minimum_size.y = get_viewport_rect().size.y
	rich_text_label.custom_minimum_size.x = get_viewport_rect().size.x

func _on_resized() -> void:
	set_header_and_footer()
	_current_scroll_position = float(scroll_container.scroll_vertical)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
