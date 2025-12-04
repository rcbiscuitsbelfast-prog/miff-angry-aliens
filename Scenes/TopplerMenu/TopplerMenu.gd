extends Control

# Toppler Main Menu
# Satirical school destruction game menu

onready var title = $Title
onready var play_button = $VBoxContainer/PlayButton
onready var settings_button = $VBoxContainer/SettingsButton
onready var exit_button = $VBoxContainer/ExitButton
onready var face_display = $FaceDisplay

func _ready():
	# Setup UI
	setup_buttons()
	update_face_display()
	
	# Start background music
	if Globals.music_player:
		Globals.music_player.play()

func setup_buttons():
	if play_button:
		play_button.connect("pressed", self, "_on_play_pressed")
	if settings_button:
		settings_button.connect("pressed", self, "_on_settings_pressed")
	if exit_button:
		exit_button.connect("pressed", self, "_on_exit_pressed")

func update_face_display():
	if face_display and PlayerProfile.face_texture:
		face_display.texture = PlayerProfile.face_texture

func _on_play_pressed():
	# Go to room selection
	Globals.goto_scene("res://Scenes/RoomSelection/RoomSelection.tscn")

func _on_settings_pressed():
	# Open settings menu
	show_settings_dialog()

func _on_exit_pressed():
	get_tree().quit()

func show_settings_dialog():
	var dialog = AcceptDialog.new()
	dialog.title = "Settings"
	dialog.dialog_text = "Settings menu coming soon!\nVolume, graphics, etc."
	add_child(dialog)
	dialog.popup_centered_ratio(0.4)