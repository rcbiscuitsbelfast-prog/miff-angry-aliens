extends RigidBody2D
class_name Obstacle

@export var debris_texture: Texture2D

signal hit

func get_debris_texture() -> Texture2D:
    return debris_texture


func get_obstacle_class():
    return "Obstacle"
