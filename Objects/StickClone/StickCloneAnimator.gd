extends Node

# Animation manager for StickClone character
# Handles sprite frame selection and animation playback

class_name StickCloneAnimator

# Animation states
enum AnimState { IDLE, WALK, JUMP, JUMP_UP, JUMP_DOWN, CLIMB }

# References
@onready var animated_sprite = get_parent().get_node_or_null("AnimatedSprite")
@onready var sprite = get_parent().get_node_or_null("Sprite")

# Animation configuration
var current_animation = AnimState.IDLE
var is_playing = false
var facing_right = true

# Sprite sheet info
var frame_height = 64
var frame_width = 64
var frames_per_animation = {}

signal animation_finished

func _ready():
	setup_animations()

func setup_animations():
	# Setup animation frame ranges for each state
	# These correspond to fighter sprite sheet layout:
	# Fighter_Idle: frames 0-5 (standing)
	# Fighter_Walk: frames 6-13 (walking frames)
	# Fighter_Jump: frames 14-17 (jumping arc)
	
	frames_per_animation = {
		AnimState.IDLE: {"start": 0, "end": 5, "speed": 0.15},
		AnimState.WALK: {"start": 6, "end": 13, "speed": 0.1},
		AnimState.JUMP: {"start": 14, "end": 17, "speed": 0.2},
		AnimState.JUMP_UP: {"start": 14, "end": 15, "speed": 0.15},
		AnimState.JUMP_DOWN: {"start": 16, "end": 17, "speed": 0.15},
		AnimState.CLIMB: {"start": 18, "end": 23, "speed": 0.12}
	}

func play_animation(anim_state: int, force_restart: bool = false):
	if current_animation == anim_state and not force_restart:
		return
	
	current_animation = anim_state
	is_playing = true
	
	if animated_sprite and animated_sprite.frames:
		# Use AnimatedSprite if available with proper animation names
		match anim_state:
			AnimState.IDLE:
				animated_sprite.animation = "idle"
				animated_sprite.play()
			AnimState.WALK:
				animated_sprite.animation = "walk"
				animated_sprite.play()
			AnimState.JUMP:
				animated_sprite.animation = "jump"
				animated_sprite.play()
			AnimState.JUMP_UP:
				animated_sprite.animation = "jump_up"
				animated_sprite.play()
			AnimState.JUMP_DOWN:
				animated_sprite.animation = "jump_down"
				animated_sprite.play()
			AnimState.CLIMB:
				animated_sprite.animation = "climb"
				animated_sprite.play()
	else:
		# Fallback to sprite flipping
		update_sprite_frame(anim_state)

func update_sprite_frame(anim_state: int):
	# Fallback frame update for simple sprite
	if sprite:
		var frame_info = frames_per_animation.get(anim_state, frames_per_animation[AnimState.IDLE])
		var start_frame = frame_info["start"]
		sprite.frame = start_frame

func set_facing_direction(direction: float):
	facing_right = direction > 0
	if animated_sprite:
		animated_sprite.flip_h = not facing_right
	elif sprite:
		sprite.flip_h = not facing_right

func stop_animation():
	is_playing = false
	if animated_sprite:
		animated_sprite.stop()

func get_animation_duration(anim_state: int) -> float:
	var frame_info = frames_per_animation.get(anim_state, frames_per_animation[AnimState.IDLE])
	var frame_count = frame_info["end"] - frame_info["start"] + 1
	var speed = frame_info["speed"]
	return frame_count * speed

func create_animated_sprite_frames() -> SpriteFrames:
	# Helper to create SpriteFrames resource programmatically
	var frames = SpriteFrames.new()
	
	# Add animation libraries
	frames.add_animation("idle")
	frames.add_animation("walk")
	frames.add_animation("jump")
	frames.add_animation("jump_up")
	frames.add_animation("jump_down")
	frames.add_animation("climb")
	
	# Set animation speeds (frames per second)
	frames.set_animation_speed("idle", 6)
	frames.set_animation_speed("walk", 10)
	frames.set_animation_speed("jump", 5)
	frames.set_animation_speed("jump_up", 7)
	frames.set_animation_speed("jump_down", 7)
	frames.set_animation_speed("climb", 8)
	
	return frames
