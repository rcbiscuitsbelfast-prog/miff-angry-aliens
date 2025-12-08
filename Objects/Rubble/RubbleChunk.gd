class_name RubbleChunk
extends RigidBody2D

# Rubble properties
@export var is_walkable: bool = true
@export var chunk_texture: Texture2D
@export var max_settle_time: float = 3.0

var settled = false
var settle_timer = 0.0
var original_position: Vector2

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
    if chunk_texture:
        sprite.texture = chunk_texture
    
    original_position = global_position
    
    # Add to walkable group for traversal system
    if is_walkable:
        add_to_group("walkable_rubble")

func _physics_process(delta):
    if settled:
        return
        
    # Check if rubble has settled
    settle_timer += delta
    
    if linear_velocity.length() < 10 and settle_timer > 0.5:
        settle_rubble()
    elif linear_velocity.length() > 50:
        settle_timer = 0.0

func settle_rubble():
    if settled:
        return
        
    settled = true
    
    # Convert to static for stable platforming
    freeze = true
    
    # Snap to grid for better platforming
    global_position = global_position.snapped(Vector2(8, 8))
    
    # Ensure proper collision for player
    collision.disabled = false
    
    # Visual feedback - small bounce
    var tween = create_tween()
    tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2).from(Vector2(1.2, 0.8)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func is_climbable() -> bool:
    return is_walkable and settled and global_position.y < get_player_position().y - 50

func get_player_position() -> Vector2:
    var player = get_tree().get_nodes_in_group("player")
    if player.size() > 0:
        return player[0].global_position
    return global_position

func get_top_position() -> Vector2:
    return global_position + Vector2(0, -sprite.texture.get_height() / 2)