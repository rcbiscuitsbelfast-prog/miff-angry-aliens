class_name DestructibleProp
extends Obstacle

# Prop configuration
enum PropType { LOCKER, DESK, VENDING_MACHINE, BOOKSHELF, TABLE }
@export var prop_type: PropType = PropType.LOCKER

# Damage system
@export var max_hitpoints: int = 3
var current_hitpoints: int

# Visual states
@export var damage_sprites: Array[Texture2D] = []
@export var rubble_scene: PackedScene

# Effects
@export var destruction_effect: PackedScene
@export var hit_sound: AudioStream
@export var destroy_sound: AudioStream

@onready var sprite = $Sprite
@onready var audio_player = $AudioStreamPlayer

signal prop_destroyed(prop, impact_force)
signal prop_damaged(prop, damage)

func _ready():
    super._ready()
    current_hitpoints = max_hitpoints
    
    # Set initial sprite
    if damage_sprites.size() > 0:
        sprite.texture = damage_sprites[0]

func get_prop_class():
    return "DestructibleProp"

func take_damage(impact_force: float, collider: Node = null):
    var damage = calculate_damage(impact_force)
    current_hitpoints -= damage
    
    prop_damaged.emit(self, damage)
    
    if current_hitpoints <= 0:
        destroy_prop(collider, impact_force)
    else:
        update_damage_sprite()
        play_hit_effect()
        shake_effect()

func calculate_damage(impact_force: float) -> int:
    # Base damage calculation
    var base_damage = impact_force / 300.0
    
    # Different prop types have different resistances
    match prop_type:
        PropType.LOCKER:
            return int(base_damage * 0.8)  # Metal locker - more resistant
        PropType.DESK:
            return int(base_damage * 1.2)  # Wooden desk - less resistant
        PropType.VENDING_MACHINE:
            return int(base_damage * 0.6)  # Heavy machine - very resistant
        PropType.BOOKSHELF:
            return int(base_damage * 1.5)  # Books - very fragile
        PropType.TABLE:
            return int(base_damage * 1.0)  # Standard resistance
        _:
            return int(base_damage)

func update_damage_sprite():
    if damage_sprites.size() > 1:
        var damage_percentage = 1.0 - (float(current_hitpoints) / float(max_hitpoints))
        var sprite_index = int(damage_percentage * (damage_sprites.size() - 1))
        sprite_index = clamp(sprite_index, 0, damage_sprites.size() - 1)
        
        if damage_sprites[sprite_index]:
            sprite.texture = damage_sprites[sprite_index]

func destroy_prop(collider: Node, impact_force: float):
    prop_destroyed.emit(self, impact_force)
    
    # Spawn rubble
    spawn_rubble()
    
    # Play destruction effects
    play_destruction_effects()
    
    # Queue for deletion
    queue_free()

func spawn_rubble():
    if not rubble_scene:
        return
        
    var rubble_count = randi_range(3, 7)
    for i in range(rubble_count):
        var chunk = rubble_scene.instantiate()
        chunk.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
        chunk.apply_central_impulse(Vector2(randf_range(-200, 200), randf_range(-300, -100)))
        get_parent().add_child(chunk)

func play_hit_effect():
    if hit_sound and audio_player:
        audio_player.stream = hit_sound
        audio_player.play()

func play_destruction_effects():
    # Play destruction sound
    if destroy_sound and audio_player:
        audio_player.stream = destroy_sound
        audio_player.play()
    
    # Spawn visual effect
    if destruction_effect:
        var effect = destruction_effect.instantiate()
        effect.global_position = global_position
        get_parent().add_child(effect)

func shake_effect():
    # Simple shake animation
    var tween = create_tween()
    var shake_pos = Vector2(randf_range(-5, 5), randf_range(-5, 5))
    tween.tween_property(sprite, "position", shake_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(sprite, "position", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)