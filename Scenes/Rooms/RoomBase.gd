extends Node2D

# Base class for Toppler rooms
class_name Room

# Room configuration
@export var room_name: String = "Untitled Room"
@export var target_destruction_score: int = 5000
@export var has_bonus_level: bool = false
@export(PackedScene) var bonus_level_scene

# Room state
var current_destruction_score = 0
var all_props_destroyed = false

# Room components
@onready var spawn_point = $SpawnPoint
@onready var exit_door = $ExitDoor
@onready var props_container = $Props
@onready var face_launcher = $FaceLauncher
@onready var player_spawn = $PlayerSpawn

# Systems
@onready var rage_system = $RageSystem
@onready var camera_focus = $CameraFocus

func _ready():
    # Connect signals
    setup_room_connections()
    
    # Initialize systems
    initialize_room()

func setup_room_connections():
    # Connect face launcher slingshot
    if face_launcher:
        var slingshot = face_launcher.get_node_or_null("Slingshot")
        if slingshot:
            slingshot.projectile_launched.connect(self._on_projectile_launched)
    
    # Connect exit door
    if exit_door:
        exit_door.body_entered.connect(self._on_exit_reached)
        exit_door.door_unlocked.connect(self._on_exit_door_unlocked)
    
    # Connect all destructible props
    if props_container:
        for prop in props_container.get_children():
            if prop is DestructibleProp:
                prop.prop_destroyed.connect(self._on_prop_destroyed)
                prop.prop_damaged.connect(self._on_prop_damaged)

func initialize_room():
    # Reset room state
    current_destruction_score = 0
    all_props_destroyed = false
    
    # Reset rage system
    if rage_system:
        rage_system.reset_rage()
    
    # Setup camera for launch phase
    if camera_focus:
        camera_focus.set_target(face_launcher)

func _on_prop_destroyed(prop: DestructibleProp, impact_force: float):
    var prop_value = calculate_prop_value(prop)
    current_destruction_score += prop_value
    
    # Add to rage system
    if rage_system:
        rage_system.add_destruction_points(prop_value, impact_force)
    
    # Check if all props are destroyed
    check_room_completion()

func _on_prop_damaged(prop: DestructibleProp, damage: int):
    # Handle prop damage (visual effects, etc.)
    pass

func calculate_prop_value(prop: DestructibleProp) -> int:
    # Calculate score based on prop type and condition
    var base_value = 100
    
    match prop.prop_type:
        DestructibleProp.PropType.LOCKER:
            base_value = 150
        DestructibleProp.PropType.DESK:
            base_value = 120
        DestructibleProp.PropType.VENDING_MACHINE:
            base_value = 200
        DestructibleProp.PropType.BOOKSHELF:
            base_value = 80
        DestructibleProp.PropType.TABLE:
            base_value = 100
    
    # Bonus for pristine destruction (if prop wasn't damaged before)
    var damage_percentage = 1.0 - (float(prop.current_hitpoints) / float(prop.max_hitpoints))
    if damage_percentage < 0.3:  # Less than 30% damaged
        base_value = int(base_value * 1.5)  # 50% bonus for pristine kill
    
    return base_value

func check_room_completion():
    # Check if target score reached
    if current_destruction_score >= target_destruction_score:
        all_props_destroyed = true
        unlock_exit()
        
        # Check for bonus level
        if has_bonus_level and bonus_level_scene:
            trigger_bonus_level()

func unlock_exit():
    if exit_door and exit_door.has_method("unlock"):
        exit_door.unlock()

func _on_exit_door_unlocked():
    pass

func trigger_bonus_level():
    # Transition to bonus vent level
    if bonus_level_scene:
        get_tree().change_scene_to(bonus_level_scene.resource_path)

func _on_exit_reached(body: Node):
    if body.has_method("complete_room"):
        body.complete_room()
    
    # Load next room or return to menu
    load_next_room()

func load_next_room():
    # TODO: Implement room progression
    print("Room completed! Score: ", current_destruction_score)
    get_tree().change_scene("res://Scenes/RoomSelection/RoomSelection.tscn")

func start_traversal_phase():
    # Called when face projectile phase ends
    # Spawn stick clone for traversal
    if player_spawn:
        var player = preload("res://Objects/StickClone/StickClone.tscn").instantiate()
        player.global_position = player_spawn.global_position
        add_child(player)
        
        # Switch camera to player
        if camera_focus:
            camera_focus.set_target(player)
        
        # Apply face customization
        var player_profile = get_node("/root/PlayerProfile")
        if player_profile and player_profile.face_texture:
            player.apply_face_customization(player_profile.face_texture)

func get_destruction_percentage() -> float:
    return float(current_destruction_score) / float(target_destruction_score)

func get_remaining_score() -> int:
    return max(0, target_destruction_score - current_destruction_score)

func _on_projectile_launched(projectile: Projectile):
    if projectile:
        projectile.body_entered.connect(self._on_projectile_collision.bind(projectile))

func _on_projectile_collision(body: Node, projectile: Projectile):
    if projectile and body is DestructibleProp:
        if body.has_method("take_damage"):
            var impact_force = projectile.linear_velocity.length()
            body.take_damage(impact_force, projectile)