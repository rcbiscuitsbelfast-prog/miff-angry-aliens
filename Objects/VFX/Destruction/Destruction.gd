extends AnimatedSprite2D

var tween: Tween

func _ready():
    pass # Replace with function body.


func _on_AnimatedSprite_animation_finished():
    playing = false
    if tween and tween.is_running():
        tween.kill()
    tween = create_tween()
    tween.tween_property(self, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
