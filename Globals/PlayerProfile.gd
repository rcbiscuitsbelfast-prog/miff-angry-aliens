extends Node

signal face_changed(new_face_texture)
signal cosmetics_updated()

# Face data
var face_texture: Texture setget set_face_texture
var face_captured = false

# Face emotions
var current_emotion = "happy" 

# Face accessories
var unlocked_hats = ["default"]
var unlocked_glasses = ["none"]
var unlocked_filters = ["none"]
var unlocked_moustaches = ["none"]
var unlocked_wigs = ["none"]

# Currently equipped
var current_hat = "default"
var current_glasses = "none"
var current_filter = "none"
var current_moustache = "none"
var current_wig = "none"

# Monetization
var ads_removed = false setget , setget 
var premium_unlocked = false setget , setget 

# Player progress
var total_destruction_score = 0
var rooms_completed = 0
var highest_combo = 0

# Settings
var screen_shake = true setget , setget 
var smooth_follow = true setget , setget 
var music_enabled = true setget , setget 
var sfx_enabled = true setget , setget 

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

func get_face_with_emotion() -> Texture:
    # Return face texture with current emotion applied
    if not face_texture:
        return null
        
    # For now, return base face. In a full implementation,
    # this would apply emotion overlays/filters based on current_emotion
    return face_texture

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

func equip_moustache(moustache_name: String):
    if moustache_name in unlocked_moustaches:
        current_moustache = moustache_name
        emit_signal("cosmetics_updated")
        save_profile()

func equip_wig(wig_name: String):
    if wig_name in unlocked_wigs:
        current_wig = wig_name
        emit_signal("cosmetics_updated")
        save_profile()

func set_emotion(emotion_name: String):
    current_emotion = emotion_name
    emit_signal("face_changed", face_texture)

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
    current_emotion = "happy"
    unlocked_hats = ["default"]
    unlocked_glasses = ["none"]
    unlocked_filters = ["none"]
    unlocked_moustaches = ["none"]
    unlocked_wigs = ["none"]
    current_hat = "default"
    current_glasses = "none"
    current_filter = "none"
    current_moustache = "none"
    current_wig = "none"
    ads_removed = false
    premium_unlocked = false
    screen_shake = true
    smooth_follow = true
    music_enabled = true
    sfx_enabled = true
    total_destruction_score = 0
    rooms_completed = 0
    highest_combo = 0
    save_profile()