class_name StickPersonEnemy
extends DestructibleProp

# Stick Person Enemy - Uses same face as player but with accessories
# Found inside destruction area, reacts differently than regular props

# Accessory configuration
@export var has_moustache = true
@export var has_wig = false
@export var has_glasses = true

# Movement AI
@export var patrol_speed = 50
@export var detection_radius = 150

var current_direction = 1  # 1 = right, -1 = left
var player

func _ready():
	super._ready()
	
	# Add to special enemies group
	add_to_group("stick_person_enemies")
	
	# Setup accessory visuals
	setup_accessories()
	
	# Find player when they enter the area
	call_deferred("setup_player_detection")

func setup_accessories():
	# Add visual accessories based on configuration
	if has_moustache:
		add_moustache()
	if has_wig:
		add_wig()
	if has_glasses:
		add_glasses()

func add_moustache():
	var moustache = Sprite.new()
	moustache.texture = load("res://Assets/graphics/particle.png")  # Placeholder
	moustache.position = Vector2(0, -15)
	moustache.scale = Vector2(0.3, 0.1)
	add_child(moustache)

func add_wig():
	var wig = Sprite.new()
	wig.texture = load("res://Assets/graphics/particle.png")  # Placeholder
	wig.position = Vector2(0, -25)
	wig.scale = Vector2(0.4, 0.3)
	add_child(wig)

func add_glasses():
	var glasses = Sprite.new()
	glasses.texture = load("res://Assets/graphics/particle.png")  # Placeholder
	glasses.position = Vector2(0, -18)
	glasses.scale = Vector2(0.35, 0.15)
	add_child(glasses)

func setup_player_detection():
	# Create detection area for player
	var detection_area = Area2D.new()
	var detection_shape = CircleShape2D.new()
	detection_shape.radius = detection_radius
	
	detection_area.add_child(detection_shape)
	add_child(detection_area)
	
	detection_area.body_entered.connect(self._on_player_detected)
	detection_area.body_exited.connect(self._on_player_lost)

func _on_player_detected(body):
	if body and body.is_in_group("player"):
		player = body
		# Start following player when detected
		set_physics_process(true)

func _on_player_lost(body):
	if body and body == player:
		player = null
		# Stop following when player leaves
		set_physics_process(false)

func _physics_process(delta):
	if not player:
		return
	
	# Simple AI - move towards player
	var direction = (Player.global_position - global_position).normalized()
	current_direction = sign(direction.x)
	
	# Move in direction
	linear_velocity.x = direction.x * patrol_speed
	
	# Face the player
	var current_facing = current_direction > 0
	sprite.flip_h = not current_facing

func take_damage(impact_force: float, collider: Node = null):
	# StickPerson enemies are more fragile than regular props
	var damage = calculate_damage(impact_force) * 1.5  # 50% more damage
	
	current_hitpoints -= damage
	
	# React with emotion change
	change_emotion_on_hit()
	
	if current_hitpoints <= 0:
		destroy_person(collider, impact_force)
	else:
		play_hit_animation()

func change_emotion_on_hit():
	# Change emotion when hit - could affect face display
	# This would integrate with PlayerProfile emotion system
	print("StickPerson hit! Changing emotion to angry")

func play_hit_animation():
	# Play hit reaction animation
	# Simple sprite shake
	var tween = create_tween()
	tween.interpolate_property(
		sprite, "scale",
		Vector2(1, 1),
		Vector2(1.2, 0.8),
		0.2,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT
	)
	tween.start()

func destroy_person(collider: Node, impact_force: float):
	# Override destruction to play special animation
	prop_destroyed.emit(self, collider, impact_force)
	
	# Play special death animation
	play_death_animation()
	
	# Drop accessories as loot
	drop_accessories()

func play_death_animation():
	# Custom death animation for stick person
	var tween = create_tween()
	tween.interpolate_property(
		sprite, "modulate:a",
		1.0,
		0.0,
		1.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()

func drop_accessories():
	# Drop accessories as collectible items
	if has_moustache:
		drop_cosmetic("moustache")
	if has_wig:
		drop_cosmetic("wig")
	if has_glasses:
		drop_cosmetic("glasses")

func drop_cosmetic(type: String):
	# Create cosmetic pickup item
	var pickup = preload("res://Objects/Cosmetics/CosmeticPickup.tscn").instantiate()
	pickup.cosmetic_type = type
	pickup.global_position = global_position + Vector2(0, -20)
	get_parent().add_child(pickup)