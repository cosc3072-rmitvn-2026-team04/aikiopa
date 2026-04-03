extends Control


# building_card is used to instantiate
var BUILDING_CARD = load("res://scripts/core/building_card.tscn")
@export var stack_line: Curve
# @export var rotation_line: Curve

@export var x_sep:= -10
@export var y_min:= 0
@export var y_max:= -15


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not BUILDING_CARD:
		push_error("Failed to load building_card.tscn; verify the file exists at res://scripts/core/building_card.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func draw() -> void:
	pass


func _update_cards()-> void:
	var cards := get_child_count()

	var final_x_sep := x_sep

	if cards > 3:
		final_x_sep = x_sep * 2
