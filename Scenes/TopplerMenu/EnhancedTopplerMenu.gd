extends Control

# Enhanced Toppler Main Menu
# Monetization, face customization, and game options

onready var title = $Title
onready var play_button = $VBoxContainer/PlayButton
onready var customize_button = $VBoxContainer/CustomizeButton
onready var options_button = $VBoxContainer/OptionsButton
onready var unlock_button = $VBoxContainer/UnlockButton
onready var face_display = $FaceDisplay

# Face customization
onready var face_emotion = $FaceDisplay/EmotionWheel
onready var face_accessories = $FaceDisplay/AccessoriesPanel

# Monetization
var ads_removed = false
var premium_unlocked = false

func _ready():
    setup_ui()
    update_face_display()
    check_monetization_status()
    
    # Start background music
    if Globals.music_player:
        Globals.music_player.play()

func setup_ui():
    # Basic setup for menu
    anchors_mode = Control.ANCHORS_MODE_KEEP_SIZE
    
    # Connect all buttons
    if play_button:
        play_button.connect("pressed", self, "_on_play_pressed")
    if customize_button:
        customize_button.connect("pressed", self, "_on_customize_pressed")
    if options_button:
        options_button.connect("pressed", self, "_on_options_pressed")
    if unlock_button:
        unlock_button.connect("pressed", self, "_on_unlock_pressed")

func update_face_display():
    if face_display and PlayerProfile.face_texture:
        face_display.texture = PlayerProfile.face_texture
    
    # Update emotion and accessories
    update_face_details()

func update_face_details():
    # Update emotion wheel
    if face_emotion:
        face_emotion.current_emotion = PlayerProfile.get("current_emotion", "happy")
        face_emotion.update_emotion_display()
    
    # Update accessories panel
    if face_accessories:
        face_accessories.current_moustache = PlayerProfile.get("current_moustache", "none")
        face_accessories.current_wig = PlayerProfile.get("current_wig", "none")
        face_accessories.current_glasses = PlayerProfile.get("current_glasses", "none")
        face_accessories.update_accessories_display()

func check_monetization_status():
    # Check if ads have been removed
    ads_removed = PlayerProfile.get("ads_removed", false)
    premium_unlocked = PlayerProfile.get("premium_unlocked", false)
    
    # Update button texts based on monetization
    update_monetization_buttons()

func update_monetization_buttons():
    if unlock_button:
        if premium_unlocked:
            unlock_button.text = "PREMIUM UNLOCKED"
            unlock_button.modulate = Color.GREEN
        else:
            unlock_button.text = "REMOVE ADS ($4.99)"
            unlock_button.modulate = Color.YELLOW

func _on_play_pressed():
    Globals.goto_scene("res://Scenes/RoomSelection/RoomSelection.tscn")

func _on_customize_pressed():
    # Show menu with face capture and cosmetics options
    show_customization_menu()

func _on_options_pressed():
    show_options_dialog()

func _on_unlock_pressed():
    if premium_unlocked:
        # Already unlocked - show status
        show_premium_status()
    else:
        # Show purchase dialog
        show_purchase_dialog()

func show_customization_menu():
    # Create a dialog with face capture and cosmetics options
    var dialog = AcceptDialog.new()
    dialog.title = "Customize"
    dialog.window_title = "Customization Menu"
    dialog.rect_size = Vector2(400, 300)
    
    var vbox = VBoxContainer.new()
    vbox.add_constant_override("separation", 20)
    
    # Title
    var title_label = Label.new()
    title_label.text = "What would you like to customize?"
    title_label.align = Label.ALIGN_CENTER
    vbox.add_child(title_label)
    
    # Face Capture Button
    var face_capture_btn = Button.new()
    face_capture_btn.text = "Capture New Face"
    face_capture_btn.custom_minimum_size = Vector2(300, 50)
    face_capture_btn.connect("pressed", self, "_on_face_capture_pressed")
    vbox.add_child(face_capture_btn)
    
    # Cosmetics Button
    var cosmetics_btn = Button.new()
    cosmetics_btn.text = "Customize Cosmetics"
    cosmetics_btn.custom_minimum_size = Vector2(300, 50)
    cosmetics_btn.connect("pressed", self, "_on_cosmetics_pressed")
    vbox.add_child(cosmetics_btn)
    
    # Emotions Button
    var emotions_btn = Button.new()
    emotions_btn.text = "Change Face Emotion"
    emotions_btn.custom_minimum_size = Vector2(300, 50)
    emotions_btn.connect("pressed", self, "_on_emotions_pressed")
    vbox.add_child(emotions_btn)
    
    dialog.add_child(vbox)
    add_child(dialog)
    dialog.popup_centered()

func _on_face_capture_pressed():
    # Load face capture scene
    get_tree().change_scene("res://Scenes/FaceCapture/FaceCaptureScene.tscn")

func _on_cosmetics_pressed():
    # Load cosmetics menu
    var cosmetics_menu = load("res://Scenes/CosmeticMenu/CosmeticMenuScene.tscn").instance()
    add_child(cosmetics_menu)
    cosmetics_menu.connect("menu_closed", self, "_on_cosmetic_menu_closed")

func _on_emotions_pressed():
    show_face_customization_dialog()

func _on_cosmetic_menu_closed():
    # Update face display when cosmetics change
    update_face_display()

func show_face_customization_dialog():
    var dialog = AcceptDialog.new()
    dialog.title = "Customize Your Face"
    dialog.window_title = "Face Customization"
    
    var vbox = VBoxContainer.new()
    
    # Emotion selection
    var emotion_label = Label.new()
    emotion_label.text = "Face Emotion:"
    vbox.add_child(emotion_label)
    
    var emotion_hbox = HBoxContainer.new()
    
    var emotions = ["happy", "angry", "sad", "surprised", "wink", "tongue_out"]
    for emotion in emotions:
        var btn = Button.new()
        btn.text = emotion.capitalize()
        btn.custom_minimum_size = Vector2(80, 30)
        if emotion == PlayerProfile.get("current_emotion", "happy"):
            btn.modulate = Color.YELLOW
        btn.connect("pressed", self, "_on_emotion_selected", [emotion])
        emotion_hbox.add_child(btn)
    
    vbox.add_child(emotion_hbox)
    
    # Accessories selection
    var accessories_label = Label.new()
    accessories_label.text = "\nAccessories:"
    vbox.add_child(accessories_label)
    
    # Moustache selection
    var moustache_hbox = HBoxContainer.new()
    var moustaches = ["none", "handlebar", "walrus", "pencil", "chevron"]
    for moustache in moustaches:
        var btn = Button.new()
        btn.text = moustache.capitalize()
        btn.custom_minimum_size = Vector2(80, 25)
        if moustache == PlayerProfile.get("current_moustache", "none"):
            btn.modulate = Color.YELLOW
        btn.connect("pressed", self, "_on_moustache_selected", [moustache])
        moustache_hbox.add_child(btn)
    
    vbox.add_child(moustache_hbox)
    
    # Wig selection
    var wig_hbox = HBoxContainer.new()
    var wigs = ["none", "afro", "mohawk", "ponytail", "spiky"]
    for wig in wigs:
        var btn = Button.new()
        btn.text = wig.capitalize()
        btn.custom_minimum_size = Vector2(80, 25)
        if wig == PlayerProfile.get("current_wig", "none"):
            btn.modulate = Color.YELLOW
        btn.connect("pressed", self, "_on_wig_selected", [wig])
        wig_hbox.add_child(btn)
    
    vbox.add_child(wig_hbox)
    
    # Glasses selection
    var glasses_hbox = HBoxContainer.new()
    var glasses = ["none", "sunglasses", "reading", "safety", "monocle"]
    for glasses_type in glasses:
        var btn = Button.new()
        btn.text = glasses_type.capitalize()
        btn.custom_minimum_size = Vector2(80, 25)
        if glasses_type == PlayerProfile.get("current_glasses", "none"):
            btn.modulate = Color.YELLOW
        btn.connect("pressed", self, "_on_glasses_selected", [glasses_type])
        glasses_hbox.add_child(btn)
    
    vbox.add_child(glasses_hbox)
    
    # Face capture button
    var capture_btn = Button.new()
    capture_btn.text = "📷 Capture Face"
    capture_btn.connect("pressed", self, "_on_face_capture_pressed")
    vbox.add_child(capture_btn)
    
    dialog.add_child(vbox)
    dialog.popup_centered_ratio(0.6)

func show_options_dialog():
    var dialog = AcceptDialog.new()
    dialog.title = "Game Options"
    dialog.window_title = "Settings"
    
    var vbox = VBoxContainer.new()
    
    # Camera options
    var camera_label = Label.new()
    camera_label.text = "Camera Settings:"
    vbox.add_child(camera_label)
    
    var camera_hbox = HBoxContainer.new()
    
    var shake_btn = Button.new()
    shake_btn.text = "Screen Shake: " + ("ON" if PlayerProfile.get("screen_shake", true) else "OFF")
    shake_btn.connect("pressed", self, "_on_shake_toggled")
    camera_hbox.add_child(shake_btn)
    
    var follow_btn = Button.new()
    follow_btn.text = "Smooth Follow: " + ("ON" if PlayerProfile.get("smooth_follow", true) else "OFF")
    follow_btn.connect("pressed", self, "_on_follow_toggled")
    camera_hbox.add_child(follow_btn)
    
    vbox.add_child(camera_hbox)
    
    # Audio settings
    var audio_label = Label.new()
    audio_label.text = "\nAudio Settings:"
    vbox.add_child(audio_label)
    
    var audio_hbox = HBoxContainer.new()
    
    var music_btn = Button.new()
    music_btn.text = "Music: " + ("ON" if PlayerProfile.get("music_enabled", true) else "OFF")
    music_btn.connect("pressed", self, "_on_music_toggled")
    audio_hbox.add_child(music_btn)
    
    var sfx_btn = Button.new()
    sfx_btn.text = "SFX: " + ("ON" if PlayerProfile.get("sfx_enabled", true) else "OFF")
    sfx_btn.connect("pressed", self, "_on_sfx_toggled")
    audio_hbox.add_child(sfx_btn)
    
    vbox.add_child(audio_hbox)
    
    # Reset progress button
    var reset_btn = Button.new()
    reset_btn.text = "\nReset All Progress"
    reset_btn.modulate = Color.RED
    reset_btn.connect("pressed", self, "_on_reset_progress")
    vbox.add_child(reset_btn)
    
    dialog.add_child(vbox)
    dialog.popup_centered_ratio(0.5)

func show_purchase_dialog():
    var dialog = AcceptDialog.new()
    dialog.title = "Remove Ads"
    dialog.dialog_text = "Remove all ads and unlock premium features?\n\n• All rooms unlocked immediately\n• Exclusive cosmetics\n• Face filters and effects\n• No more interruptions!"
    
    dialog.add_button("Remove Ads - $4.99", self, "_on_purchase_confirmed")
    dialog.add_cancel_button("Cancel")
    
    dialog.popup_centered_ratio(0.4)

func show_premium_status():
    var dialog = AcceptDialog.new()
    dialog.title = "Premium Status"
    dialog.dialog_text = "You have Premium! 🎉\n\n• All rooms unlocked\n• Exclusive cosmetics\n• No ads\n• Face filters unlocked\n\nThank you for your support!"
    
    dialog.add_button("OK")
    dialog.popup_centered_ratio(0.4)

func _on_emotion_selected(emotion: String):
    PlayerProfile.set("current_emotion", emotion)
    update_face_display()

func _on_moustache_selected(moustache: String):
    PlayerProfile.set("current_moustache", moustache)
    update_face_display()

func _on_wig_selected(wig: String):
    PlayerProfile.set("current_wig", wig)
    update_face_display()

func _on_glasses_selected(glasses_type: String):
    PlayerProfile.set("current_glasses", glasses_type)
    update_face_display()

func _on_face_capture_pressed():
    PlayerProfile.capture_face_from_camera()
    update_face_display()

func _on_shake_toggled():
    var current = PlayerProfile.get("screen_shake", true)
    PlayerProfile.set("screen_shake", !current)
    # Could restart options dialog to update button text

func _on_follow_toggled():
    var current = PlayerProfile.get("smooth_follow", true)
    PlayerProfile.set("smooth_follow", !current)

func _on_music_toggled():
    var current = PlayerProfile.get("music_enabled", true)
    PlayerProfile.set("music_enabled", !current)
    if Globals.music_player:
        if !current:
            Globals.music_player.stop()
        else:
            Globals.music_player.play()

func _on_sfx_toggled():
    var current = PlayerProfile.get("sfx_enabled", true)
    PlayerProfile.set("sfx_enabled", !current)

func _on_reset_progress():
    # Reset all player progress
    PlayerProfile.reset_profile()
    
    # Show confirmation
    var dialog = AcceptDialog.new()
    dialog.title = "Progress Reset"
    dialog.dialog_text = "All progress has been reset!\n\n• All rooms relocked\n• Cosmetics reset\n• Face data cleared"
    
    dialog.add_button("OK")
    dialog.popup_centered_ratio(0.4)

func _on_purchase_confirmed():
    # Simulate purchase - in real implementation, this would connect to store
    premium_unlocked = true
    ads_removed = true
    PlayerProfile.set("premium_unlocked", true)
    PlayerProfile.set("ads_removed", true)
    
    # Unlock all rooms
    var game_manager = get_node("/root/GameManager")
    if game_manager:
        game_manager.unlock_all_rooms()
    
    # Update UI
    update_monetization_buttons()
    
    # Show success message
    var dialog = AcceptDialog.new()
    dialog.title = "Purchase Complete!"
    dialog.dialog_text = "Premium unlocked! 🎉\n\nAll rooms and features now available!"
    
    dialog.add_button("Awesome!")
    dialog.popup_centered_ratio(0.4)