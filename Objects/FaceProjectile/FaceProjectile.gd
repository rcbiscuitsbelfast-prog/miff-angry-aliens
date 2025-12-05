class_name FaceProjectile
extends Projectile

# Face-specific properties
export var face_texture: Texture
export var squash_stretch_enabled = true

onready var squash_stretch = $SquashStretch
onready var face_sprite = $FaceSprite

func _ready():
	super._ready()
	if face_texture:
		face_sprite.texture = face_texture
	
	# Enable squash/stretch effects
	if squash_stretch_enabled and squash_stretch:
		connect("body_entered", squash_stretch, "_on_impact")

func get_class():
	return "FaceProjectile"

func get_width() -> float:
	if face_sprite and face_sprite.texture:
		return face_sprite.texture.get_size().x * face_sprite.global_scale.x
	return super.get_width()

func get_height() -> float:
	if face_sprite and face_sprite.texture:
		return face_sprite.texture.get_size().y * face_sprite.global_scale.y
	return super.get_height()