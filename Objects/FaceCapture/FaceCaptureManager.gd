extends Control

# Face capture system with upload and camera options
class_name FaceCaptureManager

enum CaptureMode { NONE, UPLOAD, CAMERA }
enum Step { MODE_SELECT, CAPTURE, CONFIRM_EYES, CONFIRM_MOUTH, COMPLETE }

# UI Components
@onready var mode_container = $ModeContainer
@onready var capture_container = $CaptureContainer
@onready var confirm_container = $ConfirmContainer
@onready var face_preview = $ConfirmContainer/FacePreview
@onready var eye_point1 = $ConfirmContainer/EyePoint1
@onready var eye_point2 = $ConfirmContainer/EyePoint2
@onready var mouth_point = $ConfirmContainer/MouthPoint
@onready var upload_button = $ModeContainer/UploadButton
@onready var camera_button = $ModeContainer/CameraButton
@onready var capture_button = $CaptureContainer/CaptureButton
@onready var back_button = $ConfirmContainer/BackButton
@onready var confirm_eyes_button = $ConfirmContainer/ConfirmEyesButton
@onready var confirm_mouth_button = $ConfirmContainer/ConfirmMouthButton
@onready var finish_button = $ConfirmContainer/FinishButton
@onready var camera_viewport = $CaptureContainer/CameraViewport

# Capture state
var current_mode = CaptureMode.NONE
var current_step = Step.MODE_SELECT
var captured_texture: Texture2D
var face_points: Dictionary = {}

signal face_captured(face_data)

func _ready():
	setup_ui()
	setup_point_dragging()
	hide_all_containers()
	mode_container.show()

func setup_ui():
	# Connect button signals
	upload_button.pressed.connect(self._on_upload_pressed)
	camera_button.pressed.connect(self._on_camera_pressed)
	capture_button.pressed.connect(self._on_capture_pressed)
	back_button.pressed.connect(self._on_back_pressed)
	confirm_eyes_button.pressed.connect(self._on_confirm_eyes_pressed)
	confirm_mouth_button.pressed.connect(self._on_confirm_mouth_pressed)
	finish_button.pressed.connect(self._on_finish_pressed)

func setup_point_dragging():
	# Setup draggable points for face feature identification
	setup_point_drag(eye_point1, "left_eye")
	setup_point_drag(eye_point2, "right_eye")
	setup_point_drag(mouth_point, "mouth")

func setup_point_drag(point_node: Control, point_name: String):
	# Make point draggable
	point_node.gui_input.connect(self._on_point_drag.bind(point_node, point_name))

func _on_point_drag(event: InputEvent, point_node: Control, point_name: String):
	if event is InputEventMouseButton and event.pressed:
		# Start dragging
		set_process(true)
	elif event is InputEventMouseButton and not event.pressed:
		# Stop dragging
		set_process(false)
	elif event is InputEventMouseMotion and event.button_mask == BUTTON_LEFT:
		# Update point position
		point_node.rect_global_position = event.global_position

func _process(delta):
	# Handle point dragging during mouse motion
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		# Points already follow mouse via event handler
		pass

func hide_all_containers():
	mode_container.hide()
	capture_container.hide()
	confirm_container.hide()

func _on_upload_pressed():
	current_mode = CaptureMode.UPLOAD
	show_upload_dialog()

func _on_camera_pressed():
	current_mode = CaptureMode.CAMERA
	start_camera_capture()

func _on_capture_pressed():
	capture_from_camera()

func _on_back_pressed():
	match current_step:
		Step.CONFIRM_EYES, Step.CONFIRM_MOUTH:
			current_step = Step.MODE_SELECT
			hide_all_containers()
			mode_container.show()

func _on_confirm_eyes_pressed():
	save_eye_positions()
	current_step = Step.CONFIRM_MOUTH
	update_confirm_ui()

func _on_confirm_mouth_pressed():
	save_mouth_position()
	current_step = Step.COMPLETE
	update_confirm_ui()

func _on_finish_pressed():
	finalize_face_capture()

func show_upload_dialog():
	var file_dialog = FileDialog.new()
	add_child(file_dialog)
	
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter("*.png ; PNG Images")
	file_dialog.add_filter("*.jpg ; JPEG Images")
	file_dialog.rect_size = Vector2(800, 600)
	
	file_dialog.file_selected.connect(self._on_file_selected.bind(file_dialog))
	file_dialog.popup_centered()

func _on_file_selected(path: String, dialog: FileDialog):
	dialog.queue_free()
	load_uploaded_image(path)

func load_uploaded_image(path: String):
	var image = Image.new()
	var error = image.load(path)
	
	if error == OK:
		var texture = ImageTexture2D.new()
		texture.create_from_image(image)
		set_captured_texture(texture)
	else:
		print("Error loading image: ", error)

func start_camera_capture():
	# For now, redirect to upload since camera requires additional setup
	print("Camera capture requires additional setup - using upload")
	show_upload_dialog()

func capture_from_camera():
	if camera_viewport:
		var texture = camera_viewport.get_texture()
		set_captured_texture(texture)

func set_captured_texture(texture: Texture2D):
	captured_texture = texture
	current_step = Step.CONFIRM_EYES
	hide_all_containers()
	confirm_container.show()
	update_confirm_ui()
	
	# Set face preview
	if face_preview:
		face_preview.texture = texture

func update_confirm_ui():
	match current_step:
		Step.CONFIRM_EYES:
			confirm_eyes_button.show()
			confirm_mouth_button.hide()
			finish_button.hide()
			eye_point1.show()
			eye_point2.show()
			mouth_point.hide()
		Step.CONFIRM_MOUTH:
			confirm_eyes_button.hide()
			confirm_mouth_button.show()
			finish_button.hide()
			eye_point1.show()
			eye_point2.show()
			mouth_point.show()
		Step.COMPLETE:
			confirm_eyes_button.hide()
			confirm_mouth_button.hide()
			finish_button.show()
			eye_point1.show()
			eye_point2.show()
			mouth_point.show()

func save_eye_positions():
	face_points["left_eye"] = eye_point1.rect_position
	face_points["right_eye"] = eye_point2.rect_position

func save_mouth_position():
	face_points["mouth"] = mouth_point.rect_position

func finalize_face_capture():
	var face_data = {
		"texture": captured_texture,
		"points": face_points
	}
	
	# Save to player profile
	var player_profile = get_node("/root/PlayerProfile")
	if player_profile:
		player_profile.set_face_texture(captured_texture)
		player_profile.set_face_points(face_points)
	
	face_captured.emit(face_data)
	
	# Return to main menu
	get_tree().change_scene("res://Scenes/TopplerMenu/EnhancedTopplerMenu.tscn")

func reset_capture():
	captured_texture = null
	face_points.clear()
	current_step = Step.MODE_SELECT
	current_mode = CaptureMode.NONE
	hide_all_containers()
	mode_container.show()