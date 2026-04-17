extends Node2D


# ============================================================================ #
#region Exported properties

@export_group("Population Change Label", "population_change")

## The text displays in [code]PopulationChangeLabel[/code] when its value is
## greater than [code]0[/code].
@export var population_change_positive_text: String = "+"

## Color of the [code]PopulationChangeLabel[/code] when its value is greater
## than [code]0[/code].
@export var population_change_positive_color: Color = Color.GREEN

## The text displays in [code]PopulationChangeLabel[/code] when its value is
## lesser than [code]0[/code].
@export var population_change_negative_text: String = "-"

## Color of the [code]PopulationChangeLabel[/code] when its value is lesser than
## [code]0[/code].
@export var population_change_negative_color: Color = Color.RED


@export_group("Building Bonus Label", "building_bonus")

## The text displays in [code]BuildingBonus[/code].
@export var building_bonus_text: String = "+"

## Color of the [code]BuildingBonusLabel[/code].
@export var building_bonus_color: Color = Color.YELLOW

#endregion
# ============================================================================ #


# ============================================================================ #
#region Godot builtins

func _ready() -> void:
	if %PopulationChangeLabel.has_theme_color_override(&"font_color"):
		%PopulationChangeLabel.remove_theme_color_override(&"font_color")
	%PopulationChangeLabel.hide()
	if %BuildingBonusLabel.has_theme_color_override(&"font_color"):
		%BuildingBonusLabel.remove_theme_color_override(&"font_color")
	%BuildingBonusLabel.hide()

#endregion
# ============================================================================ #


# ============================================================================ #
#region Public methods

## Displays the appropriate colored labels according to
## [param population_change] and [param building_bonus].
func display(population_change: int, building_bonus: int) -> void:
	if population_change != 0:
		%PopulationChangeLabel.show()
		if population_change > 0:
			%PopulationChangeLabel.add_theme_color_override(
					&"font_color",
					population_change_positive_color)
			%PopulationChangeLabel.text = population_change_positive_text
		else:
			%PopulationChangeLabel.add_theme_color_override(
					&"font_color",
					population_change_negative_color)
			%PopulationChangeLabel.text = population_change_negative_text
	if building_bonus > 0:
		%BuildingBonusLabel.show()
		%BuildingBonusLabel.add_theme_color_override(
				&"font_color",
				building_bonus_color)
		%BuildingBonusLabel.text = building_bonus_text

#endregion
# ============================================================================ #
