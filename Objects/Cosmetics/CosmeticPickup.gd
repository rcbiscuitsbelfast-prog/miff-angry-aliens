extends Area2D

# Cosmetic Pickup Item
# Collectible accessories dropped by StickPerson enemies

signal cosmetic_collected(cosmetic_type, cosmetic_name)

@export var cosmetic_type = "hat"  # hat, moustache, wig, glasses
@export var cosmetic_name = "default"
@export var pickup_sound: AudioStream

@onready var sprite = $Sprite
@onready var audio_player = $AudioStreamPlayer

func _ready():
	# Connect detection
	connect("body_entered", self, "_on_pickup")
	
	# Setup visual
	setup_visual()

func setup_visual():
	# Set sprite based on cosmetic type
	match cosmetic_type:
		"hat":
			sprite.texture = load("res://Assets/graphics/hat_icon.png")  # Placeholder
		"moustache":
			sprite.texture = load("res://Assets/graphics/moustache_icon.png")  # Placeholder
		"wig":
			sprite.texture = load("res://Assets/graphics/wig_icon.png")  # Placeholder
		"glasses":
			sprite.texture = load("res://Assets/graphics/glasses_icon.png")  # Placeholder
		_:
			sprite.texture = load("res://Assets/graphics/question.png")
	
	# Add floating animation
	var tween = create_tween()
	tween.interpolate_property(
		sprite, "position:y",
		0,
		-10,
		2.0,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		sprite, "modulate:a",
		0.5,
		1.0,
		2.0,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	tween.set_repeat(true)
	tween.start()

func _on_pickup(body: Node):
	# Check if player picked up
	if body and body.is_in_group("player"):
		# Add cosmetic to player profile
		PlayerProfile.unlock_cosmetic(cosmetic_type, cosmetic_name)
		
		# Play pickup sound
		if pickup_sound and audio_player:
			audio_player.stream = pickup_sound
			audio_player.play()
		
		# Emit signal
		cosmetic_collected.emit(cosmetic_type, cosmetic_name)
		
		# Visual feedback
		play_pickup_effect()

func play_pickup_effect():
	# Create simple pickup effect
	var tween = create_tween()
	tween.interpolate_property(
		sprite, "scale",
		Vector2(1, 1),
		Vector2(1.5, 1.5),
		0.3,
		Tween.TRANS_BACK, Tween.EASE_IN_OUT
	)
	tween.interpolate_property(
		sprite, "modulate",
		sprite.modulate,
		Color(1, 1, 1, 0),
		0.3,
		Tween.TRANS_BACK, Tween.EASE_IN_OUT
	)
	tween.start()

func _on_tween_completed(object: Object, key: NodePath):
	# Remove after pickup animation
	if key == NodePath(":scale"):
		queue_free()