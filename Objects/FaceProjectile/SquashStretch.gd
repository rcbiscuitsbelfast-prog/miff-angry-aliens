extends Node

# Squash & Stretch animation controller for face projectiles
@onready var sprite = get_parent().get_node("FaceSprite")
var impact_tween: Tween

func _ready():
	impact_tween = create_tween()
	add_child(impact_tween)

func _on_impact(body: Node):
	var impact_force = get_parent().linear_velocity.length()
	
	# Calculate squash based on impact force
	var squash_factor = min(impact_force / 1000.0, 2.0)
	var stretch_factor = 1.0 / (1.0 + squash_factor * 0.5)
	
	# Impact squash animation
	impact_tween.remove_all()
	impact_tween.interpolate_property(
		sprite, "scale",
		Vector2(1, 1),
		Vector2(1.0 + squash_factor, stretch_factor),
		0.15,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT
	)
	
	# Recovery stretch animation
	impact_tween.interpolate_property(
		sprite, "scale",
		Vector2(1.0 + squash_factor, stretch_factor),
		Vector2(1.0, 1.0),
		0.3,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT,
		0.15
	)
	
	impact_tween.start()
	
	# Add screen shake for heavy impacts
	if impact_force > 800:
		add_screen_shake(impact_force / 100.0)

func add_screen_shake(intensity: float):
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_shake"):
		camera.add_shake(intensity, 0.3)