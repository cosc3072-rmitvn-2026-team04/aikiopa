class_name BuildingCard
extends Node2D


func get_size() -> Vector2i:
	return $CardBackgroundSprite2D.get_rect().size


## Change type for CardForegroundSprite2D, BuildingSprite2D, BuildingNameLabel
func set_type(building: World.BuildingType) -> void:
	const FGPATH = "res://assets/building_stack/building_card/"
	const BUILDINGPATH = "res://assets/objects/"
	match building:
		World.BuildingType.HOUSING:
			$CardForegroundSprite2D.texture = load(FGPATH + "housing_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_housing.png")
			$BuildingNameLabel.text = "House"
		World.BuildingType.SOLAR_FARM:
			$CardForegroundSprite2D.texture = load(FGPATH + "energy_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_solar_farm.png")
			$BuildingNameLabel.text = "Solar Farm"
		World.BuildingType.WIND_FARM:
			$CardForegroundSprite2D.texture = load(FGPATH + "energy_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_wind_farm.png")
			$BuildingNameLabel.text = "Wind Farm"
		World.BuildingType.NUCLEAR_REACTOR:
			$CardForegroundSprite2D.texture = load(FGPATH + "energy_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_nuclear_reactor.png")
			$BuildingNameLabel.text = "Nuclear Reactor"
		World.BuildingType.GREENHOUSE:
			$CardForegroundSprite2D.texture = load(FGPATH + "food_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_greenhouse.png")
			$BuildingNameLabel.text = "Greenhouse"
		World.BuildingType.RANCH:
			$CardForegroundSprite2D.texture = load(FGPATH + "food_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_ranch.png")
			$BuildingNameLabel.text = "Ranch"
		World.BuildingType.FISHERY:
			$CardForegroundSprite2D.texture = load(FGPATH + "food_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_fishery.png")
			$BuildingNameLabel.text = "Fishery"
		World.BuildingType.FACTORY:
			$CardForegroundSprite2D.texture = load(FGPATH + "industry_fg.png")
			$BuildingSprite2D.texture = load(BUILDINGPATH + "building_factory.png")
			$BuildingNameLabel.text = "Factory"
		_:
			push_error("Unrecognized building type: '%s'." % [World.BuildingType.keys()[building]])
