extends Control

# Room Selection menu for Toppler
# Shows available rooms and cosmetic options

onready var room_container = $VBoxContainer
onready var profile_button = $ProfileButton
onready var player_face = $ProfileSection/FaceDisplay

var room_buttons = []

func _ready():
	setup_ui()
	update_player_profile_display()
	create_room_buttons()

func setup_ui():
	# Basic setup for the menu
	anchors_mode = Control.ANCHORS_MODE_KEEP_SIZE
	
	# Connect profile button
	if profile_button:
		profile_button.connect("pressed", self, "_on_profile_pressed")

func create_room_buttons():
	# Get unlocked rooms from game manager
	var unlocked_rooms = GameManager.get_unlocked_rooms()
	
	for i in range(unlocked_rooms.size()):
		var room_data = unlocked_rooms[i]
		var btn = create_room_button(room_data, i)
		if room_container:
			room_container.add_child(btn)
		room_buttons.append(btn)

func create_room_button(room_data: Dictionary, index: int) -> Button:
	var btn = Button.new()
	btn.text = room_data["name"] + "\n" + room_data["description"] + "\nTarget: " + str(room_data["target_score"])
	btn.custom_minimum_size = Vector2(200, 80)
	btn.connect("pressed", self, "_on_room_selected", [index])
	return btn

func update_player_profile_display():
	if PlayerProfile.face_texture and player_face:
		player_face.texture = PlayerProfile.face_texture
	
	# Update cosmetics display
	update_cosmetics_display()

func update_cosmetics_display():
	# Display current cosmetics
	var hat_label = $ProfileSection/HatLabel
	var glasses_label = $ProfileSection/GlassesLabel
	
	if hat_label:
		hat_label.text = "Hat: " + PlayerProfile.current_hat
	if glasses_label:
		glasses_label.text = "Glasses: " + ("None" if PlayerProfile.current_glasses == null else PlayerProfile.current_glasses)

func _on_room_selected(index: int):
	# Start the selected room
	GameManager.start_room(index)

func _on_profile_pressed():
	# Open cosmetic/profile customization
	show_cosmetics_menu()

func show_cosmetics_menu():
	# Create a simple cosmetics panel
	var dialog = AcceptDialog.new()
	dialog.title = "Customize Your Face"
	
	var vbox = VBoxContainer.new()
	
	# Hat selection
	var hat_label = Label.new()
	hat_label.text = "Hats:"
	vbox.add_child(hat_label)
	
	for hat_name in PlayerProfile.unlocked_hats:
		var btn = Button.new()
		btn.text = hat_name
		if hat_name == PlayerProfile.current_hat:
			btn.modulate = Color.yellow
		btn.connect("pressed", self, "_on_hat_selected", [hat_name])
		vbox.add_child(btn)
	
	# Glasses selection
	var glasses_label = Label.new()
	glasses_label.text = "\nGlasses:"
	vbox.add_child(glasses_label)
	
	for glasses_name in PlayerProfile.unlocked_glasses:
		var btn = Button.new()
		btn.text = glasses_name
		if glasses_name == PlayerProfile.current_glasses:
			btn.modulate = Color.yellow
		btn.connect("pressed", self, "_on_glasses_selected", [glasses_name])
		vbox.add_child(btn)
	
	dialog.add_child(vbox)
	dialog.popup_centered_ratio(0.5)

func _on_hat_selected(hat_name: String):
	PlayerProfile.equip_hat(hat_name)
	update_cosmetics_display()

func _on_glasses_selected(glasses_name: String):
	PlayerProfile.equip_glasses(glasses_name)
	update_cosmetics_display()

func _on_face_capture_pressed():
	# Trigger face capture (camera or upload)
	PlayerProfile.capture_face_from_camera()
	update_player_profile_display()