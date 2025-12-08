extends Control

# Cosmetic customization menu
class_name CosmeticMenu

# UI References
@onready var hat_container = $ScrollContainer/VBoxContainer/HatSection/HatGrid
@onready var glasses_container = $ScrollContainer/VBoxContainer/GlassesSection/GlassesGrid
@onready var moustache_container = $ScrollContainer/VBoxContainer/MoustacheSection/MoustacheGrid
@onready var wig_container = $ScrollContainer/VBoxContainer/WigSection/WigGrid
@onready var preview_sprite = $PreviewPanel/PreviewSprite
@onready var face_preview = $PreviewPanel/FacePreview
@onready var apply_button = $BottomPanel/ApplyButton
@onready var cancel_button = $BottomPanel/CancelButton

# Cosmetic data
var selected_cosmetics = {
	"hat": "default",
	"glasses": "none",
	"moustache": "none",
	"wig": "none"
}

var cosmetic_textures = {
	"hats": {
		"default": preload("res://Assets/cosmetics/hats/default.png"),
		"tophat": preload("res://Assets/cosmetics/hats/tophat.png"),
		"cowboy": preload("res://Assets/cosmetics/hats/cowboy.png"),
	},
	"glasses": {
		"none": null,
		"sunglasses": preload("res://Assets/cosmetics/glasses/sunglasses.png"),
		"nerd": preload("res://Assets/cosmetics/glasses/nerd.png"),
	},
	"moustaches": {
		"none": null,
		"normal": preload("res://Assets/cosmetics/moustaches/normal.png"),
		"fancy": preload("res://Assets/cosmetics/moustaches/fancy.png"),
	},
	"wigs": {
		"none": null,
		"afro": preload("res://Assets/cosmetics/wigs/afro.png"),
		"long": preload("res://Assets/cosmetics/wigs/long.png"),
	}
}

signal cosmetics_applied(cosmetics)
signal menu_closed

func _ready():
	setup_ui()
	load_player_cosmetics()
	update_preview()

func setup_ui():
	# Connect button signals
	apply_button.pressed.connect(self._on_apply_pressed)
	cancel_button.pressed.connect(self._on_cancel_pressed)
	
	# Create cosmetic option buttons
	setup_cosmetic_buttons("hat", hat_container)
	setup_cosmetic_buttons("glasses", glasses_container)
	setup_cosmetic_buttons("moustache", moustache_container)
	setup_cosmetic_buttons("wig", wig_container)

func setup_cosmetic_buttons(cosmetic_type: String, container: GridContainer):
	var texture_key = cosmetic_type + "s" if cosmetic_type != "glasses" else "glasses"
	var textures = cosmetic_textures.get(texture_key, {})
	
	for cosmetic_name in textures.keys():
		var button = Button.new()
		button.text = cosmetic_name.capitalize()
		button.custom_minimum_size = Vector2(80, 80)
		button.pressed.connect(self._on_cosmetic_selected.bind(cosmetic_type, cosmetic_name))
		container.add_child(button)

func _on_cosmetic_selected(cosmetic_type: String, cosmetic_name: String):
	selected_cosmetics[cosmetic_type] = cosmetic_name
	update_preview()

func load_player_cosmetics():
	var player_profile = get_node("/root/PlayerProfile")
	if player_profile:
		selected_cosmetics["hat"] = player_profile.current_hat
		selected_cosmetics["glasses"] = player_profile.current_glasses
		selected_cosmetics["moustache"] = player_profile.current_moustache
		selected_cosmetics["wig"] = player_profile.current_wig

func update_preview():
	# Update face preview with current cosmetics applied
	if face_preview:
		var face_texture = get_node("/root/PlayerProfile").face_texture
		if face_texture:
			face_preview.texture = face_texture
	
	# Draw cosmetic overlays on preview
	redraw_cosmetics_overlay()

func redraw_cosmetics_overlay():
	# Clear and redraw cosmetics
	if preview_sprite:
		# Apply hat
		if selected_cosmetics["hat"] != "default":
			var hat_texture = cosmetic_textures["hats"].get(selected_cosmetics["hat"])
			if hat_texture:
				# In a full implementation, overlay hat texture on preview
				pass
		
		# Apply glasses
		if selected_cosmetics["glasses"] != "none":
			var glasses_texture = cosmetic_textures["glasses"].get(selected_cosmetics["glasses"])
			if glasses_texture:
				pass
		
		# Apply moustache
		if selected_cosmetics["moustache"] != "none":
			var moustache_texture = cosmetic_textures["moustaches"].get(selected_cosmetics["moustache"])
			if moustache_texture:
				pass
		
		# Apply wig
		if selected_cosmetics["wig"] != "none":
			var wig_texture = cosmetic_textures["wigs"].get(selected_cosmetics["wig"])
			if wig_texture:
				pass

func _on_apply_pressed():
	# Save cosmetics to player profile
	var player_profile = get_node("/root/PlayerProfile")
	if player_profile:
		player_profile.current_hat = selected_cosmetics["hat"]
		player_profile.current_glasses = selected_cosmetics["glasses"]
		player_profile.current_moustache = selected_cosmetics["moustache"]
		player_profile.current_wig = selected_cosmetics["wig"]
		player_profile.save_profile()
		player_profile.cosmetics_updated.emit()
	
	cosmetics_applied.emit(selected_cosmetics)
	hide_menu()

func _on_cancel_pressed():
	hide_menu()

func hide_menu():
	menu_closed.emit()
	queue_free()

func show_menu():
	show()

func apply_cosmetics_to_character(stick_clone: Node):
	# Apply the selected cosmetics to a character sprite
	if not stick_clone:
		return
	
	var cosmetics_data = selected_cosmetics.duplicate()
	
	# Apply each cosmetic layer
	for cosmetic_type in cosmetics_data.keys():
		var cosmetic_name = cosmetics_data[cosmetic_type]
		if cosmetic_name == "default" or cosmetic_name == "none":
			continue
		
		# Get texture for cosmetic
		var texture_key = cosmetic_type + "s" if cosmetic_type != "glasses" else "glasses"
		var texture = cosmetic_textures.get(texture_key, {}).get(cosmetic_name)
		
		if texture:
			# Create overlay sprite for cosmetic
			var overlay = Sprite.new()
			overlay.texture = texture
			overlay.name = cosmetic_type + "_overlay"
			stick_clone.add_child(overlay)
