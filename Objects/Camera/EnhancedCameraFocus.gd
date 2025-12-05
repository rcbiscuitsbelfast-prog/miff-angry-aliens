extends Camera2D

# Enhanced camera focus system for Toppler
# Handles smooth transitions between launch and traversal phases

# Target tracking
var current_target: Node2D
var target_position: Vector2
var follow_speed = 5.0

# Shake effects
var shake_intensity = 0.0
var shake_duration = 0.0
var shake_time = 0.0
var original_offset = Vector2.ZERO

# Zoom control
var default_zoom = Vector2(1.0, 1.0)
var target_zoom = Vector2(1.0, 1.0)
var zoom_speed = 2.0

# Area of interest (AOI) bounds
var aoi_bounds: Rect2
var use_aoi = false

func _ready():
	enabled = true
	original_offset = offset

func _process(delta):
	# Handle shake effects
	update_shake(delta)
	
	# Follow target
	if current_target:
		update_target_position()
		follow_target(delta)
	
	# Handle zoom
	update_zoom(delta)
	
	# Apply area of interest constraints
	if use_aoi:
		constrain_to_aoi()

func set_target(new_target: Node2D):
	current_target = new_target
	
	if current_target:
		# Adjust zoom based on target type
		if current_target.is_in_group("projectile"):
			target_zoom = Vector2(0.8, 0.8)  # Zoom out for launch phase
		elif current_target.is_in_group("player"):
			target_zoom = Vector2(1.2, 1.2)  # Zoom in for traversal phase

func update_target_position():
	if not current_target:
		return
		
	target_position = current_target.global_position

func follow_target(delta: float):
	var target_global_pos = target_position + offset
	
	# Smooth follow
	global_position = global_position.linear_interpolate(target_global_pos, follow_speed * delta)

func update_zoom(delta: float):
	# Smooth zoom transition
	if zoom != target_zoom:
		zoom = zoom.linear_interpolate(target_zoom, zoom_speed * delta)

func add_shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration
	shake_time = 0.0

func update_shake(delta: float):
	if shake_time >= shake_duration:
		if shake_intensity > 0:
			shake_intensity = 0
			offset = original_offset
		return
	
	shake_time += delta
	
	# Calculate shake offset
	var shake_offset = Vector2.ZERO
	shake_offset.x = rand_range(-shake_intensity, shake_intensity)
	shake_offset.y = rand_range(-shake_intensity, shake_intensity)
	
	offset = original_offset + shake_offset
	
	# Decay shake
	var decay_rate = shake_intensity / shake_duration
	shake_intensity = max(0, shake_intensity - decay_rate * delta)

func set_aoi(bounds: Rect2):
	aoi_bounds = bounds
	use_aoi = true

func clear_aoi():
	use_aoi = false

func constrain_to_aoi():
	if not use_aoi:
		return
		
	# Get camera viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	var half_viewport = viewport_size / 2
	
	# Calculate camera bounds
	var camera_left = global_position.x - half_viewport.x / zoom.x
	var camera_right = global_position.x + half_viewport.x / zoom.x
	var camera_top = global_position.y - half_viewport.y / zoom.y
	var camera_bottom = global_position.y + half_viewport.y / zoom.y
	
	# Constrain to AOI
	if camera_left < aoi_bounds.position.x:
		global_position.x = aoi_bounds.position.x + half_viewport.x / zoom.x
	elif camera_right > aoi_bounds.position.x + aoi_bounds.size.x:
		global_position.x = aoi_bounds.position.x + aoi_bounds.size.x - half_viewport.x / zoom.x
	
	if camera_top < aoi_bounds.position.y:
		global_position.y = aoi_bounds.position.y + half_viewport.y / zoom.y
	elif camera_bottom > aoi_bounds.position.y + aoi_bounds.size.y:
		global_position.y = aoi_bounds.position.y + aoi_bounds.size.y - half_viewport.y / zoom.y

func instant_snap_to_target():
	if current_target:
		global_position = current_target.global_position + offset

func set_follow_speed(speed: float):
	follow_speed = speed

func set_zoom_level(zoom_level: float):
	target_zoom = Vector2(zoom_level, zoom_level)

func reset_camera():
	current_target = null
	target_position = global_position
	target_zoom = default_zoom
	zoom = default_zoom
	offset = original_offset
	shake_intensity = 0
	shake_duration = 0
	shake_time = 0
	use_aoi = false