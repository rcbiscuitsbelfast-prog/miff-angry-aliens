class_name Projectile
extends RigidBody2D

signal almost_stopped

enum STATES {
    IDLE, # waiting to be loaded on the slingshot
    MOVING, # moving after being launched from the slingshot
    STOPPED # stopped after being launched
}

@onready var trail: CPUParticles2D = $Trail

var state = STATES.IDLE


func _ready():
    trail.emitting = false


func get_width() -> float:
    return $Sprite2D.texture.get_width() * $Sprite2D.global_scale.x


func get_height() ->float:
    return $Sprite2D.texture.get_height() * $Sprite2D.global_scale.y


func apply_impulse(impulse: Vector2, offset: Vector2 = Vector2.ZERO):
    apply_central_impulse(impulse)
    state = STATES.MOVING


func _physics_process(delta):
    match state:
        STATES.IDLE:
            pass
        STATES.MOVING:
            trail.emitting = true
            trail.initial_velocity = linear_velocity.length() / 10
            trail.direction = -linear_velocity.normalized()
            trail.rotation = -rotation
            _moving_process()
        STATES.STOPPED:
            pass


func _moving_process():
    if linear_velocity.length() < 20 and get_contact_count() > 0:
        almost_stopped.emit()
        state = STATES.STOPPED

func get_projectile_class():
    return "Projectile"
