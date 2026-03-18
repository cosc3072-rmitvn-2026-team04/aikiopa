extends GameUI


func _ready() -> void:
	%SaveButton.pressed.connect(_on_save_button_pressed)
	%NewGameButton.pressed.connect(_on_new_game_button_pressed)
	%QuitToMenuButton.pressed.connect(_on_quit_to_menu_button_press)

func _on_save_button_pressed() -> void:
	acted.emit(&"save")

func _on_new_game_button_pressed() -> void:
	acted.emit(&"new_game")

func _on_quit_to_menu_button_press() -> void:
	acted.emit(&"quit_to_menu")
