class_name FighterEnemy
extends Enemy

# Fighter-specific properties
@export var health = 100
@export var damage_threshold = 800

# Animation states
enum AnimationState {
	IDLE,
	HIT,
	DEATH,
	ATTACK
}

var current_animation = AnimationState.IDLE
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
    super._ready()
    setup_animations()
    play_animation(AnimationState.IDLE)

func setup_animations():
    # Setup idle animation
    var idle_frames = []
    for i in range(1, 9):
        var texture = load("res://New/fighter_Idle_%04d.png" % i)
        if texture:
            idle_frames.append(texture)
    
    if idle_frames.size() > 0:
        animation_player.add_animation("idle", create_animation(idle_frames, 8, true))
    
    # Setup hit animation
    var hit_frames = []
    for i in range(48, 52):
        var texture = load("res://New/fighter_hit_%04d.png" % i)
        if texture:
            hit_frames.append(texture)
    
    if hit_frames.size() > 0:
        animation_player.add_animation("hit", create_animation(hit_frames, 15, false))
    
    # Setup death animation
    var death_frames = []
    for i in range(52, 62):
        var texture = load("res://New/fighter_death_%04d.png" % i)
        if texture:
            death_frames.append(texture)
    
    if death_frames.size() > 0:
        animation_player.add_animation("death", create_animation(death_frames, 15, false))

func create_animation(frames: Array, fps: float, loop: bool) -> Animation:
    var animation = Animation()
    animation.length = frames.size() / fps
    animation.loop = loop
    
    var track_index = animation.add_track(Animation.TYPE_VALUE)
    animation.track_set_path(track_index, str(sprite.get_path()) + ":texture")
    animation.track_set_interpolation_loop_wrap(track_index, false)
    
    for i in range(frames.size()):
        var time = i / fps
        animation.track_insert_key(track_index, time, frames[i])
    
    return animation

func play_animation(state: AnimationState):
    current_animation = state
    
    match state:
        AnimationState.IDLE:
            if animation_player.has_animation("idle"):
                animation_player.play("idle")
        AnimationState.HIT:
            if animation_player.has_animation("hit"):
                animation_player.play("hit")
                await animation_player.animation_finished
                play_animation(AnimationState.IDLE)
        AnimationState.DEATH:
            if animation_player.has_animation("death"):
                animation_player.play("death")
        AnimationState.ATTACK:
            # Could add attack animation frames if available
            pass

func get_destruction_threshold(collider_type: RigidBody2D):
    # Fighter enemies are tougher than regular aliens
    match collider_type.get_class():
        "Obstacle":
            return damage_threshold / 2  # Less damage from obstacles
        "Projectile":
            return damage_threshold
        _:
            return damage_threshold

func take_damage(damage_amount: int):
    health -= damage_amount
    play_animation(AnimationState.HIT)
    
    if health <= 0:
        play_animation(AnimationState.DEATH)
        destroyed.emit(self, null, Vector2())

func _on_Destruction_animation_finished():
    # Called when death animation completes
    queue_free()