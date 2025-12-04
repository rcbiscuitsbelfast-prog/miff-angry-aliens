extends Node2D

# Vent escape bonus level
class_name BonusVentLevel

# Level configuration
const TIME_LIMIT = 30.0
const HAZARD_DAMAGE = 1

# Level state
var time_remaining = TIME_LIMIT
var level_completed = false
var level_failed = false

# Components
onready var player = $Player
onready var timer = $Timer
onready var time_label = $UI/TimeLabel
onready var hazards = get_tree().get_nodes_in_group("hazards")

func _ready():
	# Initialize player position
	if player and $StartPoint:
		player.global_position = $StartPoint.global_position
	
	# Setup timer
	if timer:
		timer.wait_time = TIME_LIMIT
		timer.connect("timeout", self, "_on_time_up")
		timer.start()
	
	# Connect player to hazards
	connect_hazard_collisions()

func _process(delta):
	if level_completed or level_failed:
		return
	
	# Update timer
	time_remaining -= delta
	time_remaining = max(0, time_remaining)
	
	# Update UI
	update_ui()
	
	# Check time limit
	if time_remaining <= 0:
		fail_bonus_level()

func _physics_process(delta):
	if level_completed or level_failed:
		return
	
	# Check for player reaching exit
	if player and $ExitArea:
		if $ExitArea.overlaps_body(player):
			complete_bonus_level()

func connect_hazard_collisions():
	if not player:
		return
		
	for hazard in hazards:
		if hazard.has_signal("body_entered"):
			hazard.connect("body_entered", self, "_on_hazard_collision", [hazard])

func _on_hazard_collision(body: Node, hazard: Node):
	if body == player:
		# Apply damage or fail immediately depending on hazard type
		match hazard.get("hazard_type"):
			"steam":
				# Steam does gradual damage
				player.take_damage(HAZARD_DAMAGE)
			"fan":
				# Fan pushes player
				var push_direction = hazard.get("push_direction", Vector2.RIGHT)
				player.apply_push(push_direction * 200)
			"electric":
				# Electric hazards cause instant failure
				fail_bonus_level()
			_:
				# Default instant failure
				fail_bonus_level()

func _on_time_up():
	fail_bonus_level()

func complete_bonus_level():
	if level_completed:
		return
		
	level_completed = true
	
	# Stop timer
	if timer:
		timer.stop()
	
	# Show success message
	show_completion_message()
	
	# Award bonus points
	award_bonus_points()

func fail_bonus_level():
	if level_failed:
		return
		
	level_failed = true
	
	# Stop timer
	if timer:
		timer.stop()
	
	# Show failure message
	show_failure_message()

func update_ui():
	if time_label:
		time_label.text = "Time: " + str(int(time_remaining)) + "s"
		
		# Change color based on time remaining
		if time_remaining < 10:
			time_label.modulate = Color.RED
		elif time_remaining < 20:
			time_label.modulate = Color.YELLOW
		else:
			time_label.modulate = Color.WHITE

func show_completion_message():
	# TODO: Show completion UI
	print("Bonus level completed! Time: ", TIME_LIMIT - time_remaining)

func show_failure_message():
	# TODO: Show failure UI
	print("Bonus level failed!")

func award_bonus_points():
	var time_bonus = int(time_remaining * 10)  # 10 points per second remaining
	var total_bonus = 1000 + time_bonus  # Base 1000 + time bonus
	
	# Add to player profile
	var player_profile = get_node("/root/PlayerProfile")
	if player_profile:
		player_profile.update_progress(total_bonus, 0)

func restart_level():
	# Restart the bonus level
	get_tree().reload_current_scene()

func exit_to_main_room():
	# Return to the main room
	get_tree().change_scene("res://Scenes/Rooms/Cafeteria/Cafeteria.tscn")