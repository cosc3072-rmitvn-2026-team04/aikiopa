class_name BuildingCard
extends Node2D


func get_size() -> Vector2i:
    return $CardBackgroundSprite2D.get_rect().size
