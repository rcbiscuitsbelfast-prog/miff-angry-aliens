# Cafeteria Room Implementation
# First complete room for Toppler with lunch-themed destruction

extends "res://Scenes/Rooms/RoomBase.gd"

func _ready():
	# Set room configuration
	room_name = "Cafeteria"
	target_destruction_score = 5000
	has_bonus_level = true
	bonus_level_scene = preload("res://Scenes/BonusLevels/VentEscape.tscn")
	
	# Call parent _ready
	super._ready()
	
	# Setup cafeteria-specific elements
	setup_cafeteria()

func setup_cafeteria():
	# Load first projectile into slingshot
	load_first_projectile()

func load_first_projectile():
	var slingshot = face_launcher.get_node_or_null("Slingshot")
	if not slingshot:
		return
	
	# Create face projectile for launch
	var face_projectile = preload("res://Objects/FaceProjectile/FaceProjectile.tscn").instantiate()
	face_projectile.global_position = slingshot.rest_position.global_position
	
	# Apply player face texture if available
	var player_profile = get_node_or_null("/root/PlayerProfile")
	if player_profile and player_profile.face_texture:
		face_projectile.face_texture = player_profile.face_texture
	
	add_child(face_projectile)
	slingshot.load_projectile(face_projectile)

func _on_prop_destroyed(prop: DestructibleProp, impact_force: float):
	var prop_value = calculate_prop_value(prop)
	current_destruction_score += prop_value
	
	# Add to rage system
	if rage_system:
		rage_system.add_destruction_points(prop_value, impact_force)
	
	print("Prop destroyed! Score: %d, Total: %d" % [prop_value, current_destruction_score])
	
	# Check if all props are destroyed
	check_room_completion()

func _on_prop_damaged(prop: DestructibleProp, damage: int):
	# Handle prop damage visual feedback
	pass
