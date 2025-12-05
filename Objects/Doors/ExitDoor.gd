class_name ExitDoor
extends Area2D

export var locked = true
export var unlock_animation_time = 0.5

var sprite: Sprite
var collision_shape: CollisionShape2D
var is_unlocked = false

signal door_unlocked
signal door_entered(body)

func _ready():
	sprite = $Sprite
	collision_shape = $CollisionShape2D
	update_door_state()
	connect("body_entered", self, "_on_body_entered")

func unlock():
	if is_unlocked:
		return
	
	is_unlocked = true
	locked = false
	emit_signal("door_unlocked")
	
	play_unlock_animation()

func lock():
	is_unlocked = false
	locked = true
	update_door_state()

func play_unlock_animation():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	
	if sprite:
		tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), unlock_animation_time / 2)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), unlock_animation_time / 2)

func update_door_state():
	if not sprite:
		return
	
	if is_unlocked or not locked:
		sprite.modulate = Color.green
	else:
		sprite.modulate = Color.red

func _on_body_entered(body: Node):
	if is_unlocked or not locked:
		emit_signal("door_entered", body)
		if body.has_method("complete_room"):
			body.complete_room()
