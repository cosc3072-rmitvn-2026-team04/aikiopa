class_name BuildingCard
extends Node2D


const CARD_ASSET_PATH = "res://assets/building_stack/building_card/"
const BUILDING_ASSET_PATH = "res://assets/objects/"


# ============================================================================ #
#region Public methods

func get_size() -> Vector2i:
	return $CardBackgroundSprite2D.get_rect().size


## Change type for CardForegroundSprite2D, BuildingSprite2D, BuildingNameLabel
func set_type(building: World.BuildingType) -> void:
	match building:
		World.BuildingType.HOUSING:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("housing_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_housing.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		World.BuildingType.SOLAR_FARM:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_solar_farm.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		World.BuildingType.WIND_FARM:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_wind_farm.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		World.BuildingType.NUCLEAR_REACTOR:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("energy_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_nuclear_reactor.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		World.BuildingType.GREENHOUSE:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_greenhouse.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		World.BuildingType.RANCH:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_ranch.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		World.BuildingType.FISHERY:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("food_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_fishery.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		World.BuildingType.FACTORY:
			$CardForegroundSprite2D.texture = load(
					CARD_ASSET_PATH.path_join("industry_fg.png"))
			$BuildingSprite2D.texture = load(
					BUILDING_ASSET_PATH.path_join("building_factory.png"))
			$BuildingNameLabel.text = World.BUILDING_NAME[building]
		_:
			push_error("Unrecognized building type: '%s'." % [World.BuildingType.keys()[building]])

#endregion
# ============================================================================ #
