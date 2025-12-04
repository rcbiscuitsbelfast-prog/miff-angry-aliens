extends Node

# Global player profile management
extends Node

signal face_changed(new_face_texture)
signal cosmetics_updated()

# Face data
var face_texture: Texture setget set_face_texture
var face_captured = false

# Cosmetics unlocked
var unlocked_hats = ["default"]
var unlocked_glasses = []
var unlocked_filters = []

# Currently equipped
var current_hat = "default"
var current_glasses = null
var current_filter = null

# Player progress
var total_destruction_score = 0
var rooms_completed = 0
var highest_combo = 0

func _ready():
	# Load saved profile data
	load_profile()

func set_face_texture(texture: Texture):
	face_texture = texture
	face_captured = true
	emit_signal("face_changed", face_texture)
	save_profile()

func capture_face_from_camera():
	# TODO: Implement camera capture for mobile
	# For now, use placeholder
	var placeholder_face = load("res://New/fighter_Idle_0001.png")
	set_face_texture(placeholder_face)

func equip_hat(hat_name: String):
	if hat_name in unlocked_hats:
		current_hat = hat_name
		emit_signal("cosmetics_updated")
		save_profile()

func equip_glasses(glasses_name: String):
	if glasses_name in unlocked_glasses:
		current_glasses = glasses_name
		emit_signal("cosmetics_updated")
		save_profile()

func equip_filter(filter_name: String):
	if filter_name in unlocked_filters:
		current_filter = filter_name
		emit_signal("cosmetics_updated")
		save_profile()

func unlock_cosmetic(cosmetic_type: String, cosmetic_name: String):
	match cosmetic_type:
		"hat":
			if cosmetic_name not in unlocked_hats:
				unlocked_hats.append(cosmetic_name)
		"glasses":
			if cosmetic_name not in unlocked_glasses:
				unlocked_glasses.append(cosmetic_name)
		"filter":
			if cosmetic_name not in unlocked_filters:
				unlocked_filters.append(cosmetic_name)
	
	emit_signal("cosmetics_updated")
	save_profile()

func apply_cosmetics_to_sprite(sprite: Sprite):
	# Apply current cosmetics to a sprite
	# This would be called by StickClone or FaceProjectile
	pass

func update_progress(destruction_score: int, combo_count: int):
	total_destruction_score += destruction_score
	if combo_count > highest_combo:
		highest_combo = combo_count
	save_profile()

func complete_room():
	rooms_completed += 1
	save_profile()

func save_profile():
	var save_data = {
		"face_captured": face_captured,
		"unlocked_hats": unlocked_hats,
		"unlocked_glasses": unlocked_glasses,
		"unlocked_filters": unlocked_filters,
		"current_hat": current_hat,
		"current_glasses": current_glasses,
		"current_filter": current_filter,
		"total_destruction_score": total_destruction_score,
		"rooms_completed": rooms_completed,
		"highest_combo": highest_combo
	}
	
	# TODO: Implement actual file saving
	print("Saving profile: ", save_data)

func load_profile():
	# TODO: Implement actual file loading
	# For now, use defaults
	face_captured = false
	current_hat = "default"
	current_glasses = null
	current_filter = null
	total_destruction_score = 0
	rooms_completed = 0
	highest_combo = 0

func reset_profile():
	face_texture = null
	face_captured = false
	unlocked_hats = ["default"]
	unlocked_glasses = []
	unlocked_filters = []
	current_hat = "default"
	current_glasses = null
	current_filter = null
	total_destruction_score = 0
	rooms_completed = 0
	highest_combo = 0
	save_profile()