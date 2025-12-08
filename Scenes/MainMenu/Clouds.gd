extends Node2D

@onready var aliens_tween := $AliensTween
@onready var clouds = get_tree().get_nodes_in_group("clouds")

var far_speed = 25
var near_speed = 50

var clouds_arr = []

class Cloud:
    var obj
    var speed: int
    var sprite: Sprite2D
    var tween: Tween


func _ready():
    randomize()
    for c in clouds:
        if c.get_parent().name == "Far":
            var cl = Cloud.new()
            cl.obj = c
            cl.sprite = c.find_child("CloudSprite", true, false)
            cl.speed = far_speed + randi() % 20
            animate(cl)
            clouds_arr.append(cl)
        if c.get_parent().name == "Near":
            var cl = Cloud.new()
            cl.obj = c
            cl.sprite = c.find_child("CloudSprite", true, false)
            cl.speed = near_speed + randi() % 20
            animate(cl)
            clouds_arr.append(cl)


func _show_alien():
    var rnd_cloud = clouds_arr[randi() % clouds_arr.size()]
    rnd_cloud.obj.show_alien()


func _process(delta):
    for el in clouds_arr:
        var c = el.obj as Node2D
        var s = el.speed
        c.position.x += s * delta
        var sprite_width = el.sprite.texture.get_width() * c.scale.x
        if c.position.x - sprite_width / 2 > get_viewport_rect().size.x:
            c.position.x = -sprite_width / 2
            c.position.y = randf_range(-10, 240)
            # reset tween
            if el.tween:
                el.tween.kill()
            animate(el)


func horizontal_transition_time(speed):
    return get_viewport_rect().size.x / speed


func animate(cl):
    var duration = horizontal_transition_time(cl.speed)
    var random_scale = Vector2(
        cl.obj.scale.x * randf_range(0.8, 1.2),
        cl.obj.scale.y * randf_range(0.8, 1.2)
    )
    var target_y = cl.obj.position.y + randf_range(-80, 80)
    
    cl.tween = create_tween()
    cl.tween.set_parallel(true)
    cl.tween.tween_property(cl.obj, "scale", random_scale, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
    cl.tween.tween_property(cl.obj, "position:y", target_y, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

