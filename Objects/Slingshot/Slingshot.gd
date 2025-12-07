extends Node2D

# signals
signal projectile_launched(projectile)
# exported vars
@export var slingshot_elastic_force = 40
@export var max_distance: int = 100 # max distance from rest position
# dependencies
@onready var elastic_back: Sprite2D = $ElasticBack
@onready var elastic_front: Sprite2D = $ElasticFront
@onready var elastic_pad: Sprite2D = $ElasticPad
@onready var elastic_control_point: Marker2D = $ElasticPadTarget
@onready var rest_position = $RestPosition
@onready var trajectory_drawer = $TrajectoryDrawer
# vars
var launch_impulse = Vector2(0, 0)  # impulse (kg*m / s) - https://en.wikipedia.org/wiki/Impulse_(physics)
var projectile: Projectile
var projectile_tween: Tween

enum States {
    IDLE,
    LOADING_PROJECTILE,
    PROJECTILE_LOADED, # projectile loaded
    AIMING,
}
var state = States.IDLE


func _ready():
    elastic_control_point.position = rest_position.position
    if projectile:
        projectile.freeze = true
        projectile.global_position = rest_position.global_position


func _physics_process(delta):
    launch_impulse = update_launch_impulse()
    match state:
        States.IDLE:
            update_elastics_rest_position()
        States.LOADING_PROJECTILE:
            update_elastics_rest_position()
            # move the elastics according to projectile position
            elastic_control_point.global_position = projectile.global_position + Vector2(0, projectile.get_height() / 2)
        States.AIMING:
            trajectory_drawer.draw_trajectory(
                launch_impulse / projectile.mass, # velocity (m/s)
                projectile.global_position,
                projectile.gravity_scale * ProjectSettings.get("physics/2d/default_gravity")
            )
            update_elastics() # elastics graphic effects
        _:
            pass


func load_projectile(proj: Projectile):
    state = States.LOADING_PROJECTILE
    projectile = proj
    var tween = create_tween()
    tween.tween_property(projectile, "global_position", rest_position.global_position, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func update_launch_impulse():
    return slingshot_elastic_force * ($InputArea.global_position - elastic_pad.global_position)


func update_elastics():
    # point where the elastic touches the projectile
    var projectile_touch = projectile.position - (launch_impulse.normalized() * projectile.get_width() / 2)
    elastic_back.rotation = elastic_back.global_position.angle_to_point(projectile_touch)
    elastic_back.scale.x = elastic_back.global_position.distance_to(projectile_touch) / (elastic_back.texture.get_width())
    # update point
    projectile_touch = projectile.position - (launch_impulse.normalized() * projectile.get_width() / 2)
    elastic_front.rotation = elastic_front.global_position.angle_to_point(projectile_touch)
    elastic_front.scale.x = elastic_front.global_position.distance_to(projectile_touch) / (elastic_front.texture.get_width())
    elastic_pad.global_position = projectile_touch
#    elastic_pad.rotation = elastic_pad.global_position.direction_to(projectile.global_position).angle()
    elastic_pad.rotation = launch_impulse.angle()


func update_elastics_rest_position():
    var ctrl_pos = elastic_control_point.global_position
    elastic_back.rotation = elastic_back.global_position.angle_to_point(ctrl_pos)
    elastic_back.scale.x = elastic_back.global_position.distance_to(ctrl_pos) / (elastic_back.texture.get_width())
    elastic_front.rotation = elastic_front.global_position.angle_to_point(ctrl_pos)
    elastic_front.scale.x = elastic_front.global_position.distance_to(ctrl_pos) / (elastic_front.texture.get_width())
    elastic_pad.global_position = ctrl_pos
    elastic_pad.rotation = -PI / 2


func launch(launch_impulse: Vector2):
    if !projectile:
        return
    projectile.freeze = false
    projectile.apply_impulse(launch_impulse)
    projectile_launched.emit(projectile)
    projectile = null


func _on_InputArea_slingshot_released():
    if state == States.AIMING:
        set_physics_process(true)
        launch(launch_impulse)
        trajectory_drawer.clear()
        var tween = create_tween()
        tween.tween_property(elastic_control_point, "position", rest_position.position, 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
        state = States.IDLE


func _on_InputArea_slingshot_moved(touch_pos):
    if projectile == null:
        print("Error: Slingshot does not have any projectile registered")
        return

    var xformed_touch_pos = get_viewport().get_canvas_transform().affine_inverse() * touch_pos
    if state == States.IDLE and xformed_touch_pos.distance_to(rest_position.global_position) < 5:
        return
    state = States.AIMING
    # clamp movement
    projectile.global_position = (xformed_touch_pos - rest_position.global_position).limit_length(max_distance) + rest_position.global_position
    # animate elastics by updating elastic_control_point position
    elastic_control_point.global_position = projectile.global_position
