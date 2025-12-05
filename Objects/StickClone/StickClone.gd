class_name StickClone
extends KinematicBody2D

# Movement constants
const WALK_SPEED = 150
const JUMP_FORCE = 400
const GRAVITY = 800
const CLIMB_SPEED = 100

# Player states
enum State { ENTERING, WAITING, TRAVERSING, EXITING, CLIMBING }
var current_state = State.ENTERING

# Movement
var velocity = Vector2.ZERO
var is_jumping = false
var can_climb = false
var climb_target: Node

# Animation
var facing_right = true

# Components
onready var sprite = $AnimatedSprite
onready var face_sprite = $FaceSprite
onready var climb_prompt = $ClimbPrompt
onready var camera = $Camera2D

func _ready():
    add_to_group("player")
    
    # Initialize animations
    setup_animations()

func _physics_process(delta):
    match current_state:
        State.ENTERING:
            walk_to_launch_point()
        State.WAITING:
            idle_behavior()
        State.TRAVERSING:
            handle_traversal_input(delta)
        State.CLIMBING:
            handle_climbing(delta)
        State.EXITING:
            walk_to_exit()

func handle_traversal_input(delta):
    # Apply gravity
    velocity.y += GRAVITY * delta
    
    # Horizontal movement
    var input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    
    if input_dir != 0:
        facing_right = input_dir > 0
        velocity.x = input_dir * WALK_SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, WALK_SPEED * 2 * delta)
    
    # Jump
    if Input.is_action_just_pressed("ui_up") and is_on_floor():
        velocity.y = -JUMP_FORCE
        is_jumping = true
        play_animation("jump")
    
    # Check for climb input
    if can_climb and Input.is_action_just_pressed("interact"):
        start_climbing()
    
    # Move and slide
    velocity = move_and_slide(velocity, Vector2.UP)
    
    # Update animations
    update_traversal_animation()
    
    # Check for climb opportunities
    check_climb_opportunities()

func handle_climbing(delta):
    if not climb_target:
        current_state = State.TRAVERSING
        return
    
    # Move toward climb target
    var direction = (climb_target.global_position - global_position).normalized()
    velocity = direction * CLIMB_SPEED
    
    # Climb movement
    move_and_slide(velocity)
    
    # Check if reached climb target
    if global_position.distance_to(climb_target.global_position) < 10:
        complete_climb()

func check_climb_opportunities():
    can_climb = false
    climb_target = null
    
    var rubble = get_tree().get_nodes_in_group("walkable_rubble")
    for chunk in rubble:
        if global_position.distance_to(chunk.global_position) < 80:
            if chunk.has_method("is_climbable") and chunk.is_climbable():
                can_climb = true
                climb_target = chunk
                show_climb_prompt()
                return
    
    hide_climb_prompt()

func show_climb_prompt():
    if climb_prompt:
        climb_prompt.visible = true
        climb_prompt.global_position = climb_target.get_top_position()

func hide_climb_prompt():
    if climb_prompt:
        climb_prompt.visible = false

func start_climbing():
    current_state = State.CLIMBING
    hide_climb_prompt()
    play_animation("climb")

func complete_climb():
    global_position = climb_target.get_top_position()
    current_state = State.TRAVERSING
    velocity = Vector2.ZERO

func walk_to_launch_point():
    current_state = State.ENTERING
    play_animation("walk")

func idle_behavior():
    # Wait for player input during traversal phase
    velocity = Vector2.ZERO
    play_animation("idle")

func walk_to_exit():
    current_state = State.EXITING
    play_animation("walk")

func setup_animations():
    if sprite and sprite.has_method("add_animation"):
        sprite.add_animation("idle")
        sprite.add_animation("walk")
        sprite.add_animation("jump")
        sprite.add_animation("jump_up")
        sprite.add_animation("jump_down")
        sprite.add_animation("climb")

func update_traversal_animation():
    if is_on_floor():
        if abs(velocity.x) > 10:
            play_animation("walk")
        else:
            play_animation("idle")
    else:
        if velocity.y < 0:
            play_animation("jump_up")
        else:
            play_animation("jump_down")

func play_animation(anim_name: String):
    # Update sprite based on animation state
    # For now, just flip based on direction
    if sprite:
        sprite.flip_h = not facing_right

func apply_face_customization(face_texture: Texture):
    if face_sprite:
        face_sprite.texture = face_texture

func complete_room():
    walk_to_exit()
    var room = get_parent()
    if room and room.has_method("load_next_room"):
        room.load_next_room()