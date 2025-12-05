# Sound Integration Guide for Toppler

## Overview
This guide explains how to integrate open-source sound assets into the Toppler game. We'll use Godot's audio system with effects, mixing, and spatial audio.

---

## Recommended Open-Source Sound Resources

### 1. Kenney Audio Assets (Creative Commons CC0)
**URL**: https://kenney.nl/assets/category:Audio

**Free assets include**:
- UI/menu sounds
- Impact and destruction effects
- Ambient backgrounds
- Footsteps and movement
- Victory/completion sounds

**Integration**:
```bash
# Clone as submodule (optional)
git submodule add https://github.com/kenneynl/kenney-assetpack.git Assets/Audio/kenney-pack
```

### 2. OpenGameArt.org
**URL**: https://opengameart.org/

**Search for**:
- Sound Effects (Tags: SFX, Impact, Destruction)
- Background Music
- UI Sounds
- License: CC0, CC-BY, or CC-BY-SA

### 3. Freesound.org
**URL**: https://freesound.org/

**Available with proper attribution**:
- Raw sound effects
- Ambient sounds
- Foley effects

---

## Godot Audio System Setup

### Audio Bus Configuration

Create a master audio bus hierarchy:
```
Master Bus
├── SFX Bus (60% volume)
│   ├── Impact Sounds
│   ├── UI Sounds
│   └── Ambient Sounds
├── Music Bus (40% volume)
│   ├── Background Music
│   └── Combat Music
└── Voice Bus (optional - 50% volume)
```

### Audio Implementation in Toppler

#### 1. Impact Sounds (Destruction)
```gdscript
# In DestructibleProp.gd
export var hit_sound: AudioStream
export var destroy_sound: AudioStream

func play_hit_effect():
    if hit_sound and audio_player:
        audio_player.stream = hit_sound
        audio_player.pitch_scale = rand_range(0.9, 1.1)  # Variation
        audio_player.play()

func play_destruction_effects():
    if destroy_sound and audio_player:
        audio_player.stream = destroy_sound
        audio_player.pitch_scale = rand_range(0.8, 1.0)
        audio_player.play()
```

#### 2. UI Sounds (Menu Navigation)
```gdscript
# In menu systems
export var button_pressed_sound: AudioStream
export var menu_open_sound: AudioStream

func _on_button_pressed():
    if button_pressed_sound:
        var player = AudioStreamPlayer.new()
        player.stream = button_pressed_sound
        player.bus = "UI"
        add_child(player)
        player.play()
        yield(player, "finished")
        player.queue_free()
```

#### 3. Background Music
```gdscript
# In GameManager or room systems
export var background_music: AudioStream

func _ready():
    if background_music and Globals.music_player:
        Globals.music_player.stream = background_music
        Globals.music_player.bus = "Music"
        Globals.music_player.play()
```

#### 4. Ambient Sounds
```gdscript
# In room systems - ambient background
export var ambient_sound: AudioStream
export var ambient_volume: float = -20.0

var ambient_player: AudioStreamPlayer

func setup_ambient():
    if ambient_sound:
        ambient_player = AudioStreamPlayer.new()
        ambient_player.stream = ambient_sound
        ambient_player.bus = "Ambient"
        ambient_player.volume_db = ambient_volume
        ambient_player.bus = "SFX"
        add_child(ambient_player)
        ambient_player.play()
```

---

## Sound Effect Library Setup

### Directory Structure
```
Assets/
├── sounds/
│   ├── sfx/
│   │   ├── impact/
│   │   │   ├── wood_hit.ogg
│   │   │   ├── metal_hit.ogg
│   │   │   ├── stone_hit.ogg
│   │   │   ├── wood_destroy.ogg
│   │   │   ├── metal_destroy.ogg
│   │   │   └── stone_destroy.ogg
│   │   ├── ui/
│   │   │   ├── button_click.ogg
│   │   │   ├── menu_open.ogg
│   │   │   ├── menu_close.ogg
│   │   │   └── select.ogg
│   │   ├── character/
│   │   │   ├── jump.ogg
│   │   │   ├── land.ogg
│   │   │   ├── walk.ogg
│   │   │   └── climb.ogg
│   │   └── environment/
│   │       ├── wind.ogg
│   │       ├── ambient_cafeteria.ogg
│   │       └── completion.ogg
│   └── music/
│       ├── menu_music.ogg
│       ├── cafeteria_music.ogg
│       ├── bonus_music.ogg
│       └── victory_music.ogg
```

---

## Audio Manager Script

```gdscript
# Audio/AudioManager.gd
extends Node

class_name AudioManager

# Audio stream players
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer

# Sound effect library
var sound_library = {}

func _ready():
	setup_audio_buses()
	setup_players()
	load_sound_library()

func setup_audio_buses():
	# Ensure buses exist (can also be set in AudioBusLayout)
	AudioServer.add_bus_point(0)
	AudioServer.set_bus_name(1, "SFX")
	AudioServer.set_bus_name(2, "Music")
	AudioServer.set_bus_mute(2, false)

func setup_players():
	# SFX Player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	# Music Player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Ambient Player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "SFX"
	add_child(ambient_player)

func load_sound_library():
	# Load all sound effects into dictionary for easy access
	var sfx_dir = "res://Assets/sounds/sfx/"
	
	sound_library = {
		"impact": {
			"wood": preload("res://Assets/sounds/sfx/impact/wood_hit.ogg"),
			"metal": preload("res://Assets/sounds/sfx/impact/metal_hit.ogg"),
			"stone": preload("res://Assets/sounds/sfx/impact/stone_hit.ogg"),
		},
		"destroy": {
			"wood": preload("res://Assets/sounds/sfx/impact/wood_destroy.ogg"),
			"metal": preload("res://Assets/sounds/sfx/impact/metal_destroy.ogg"),
			"stone": preload("res://Assets/sounds/sfx/impact/stone_destroy.ogg"),
		},
		"ui": {
			"click": preload("res://Assets/sounds/sfx/ui/button_click.ogg"),
			"select": preload("res://Assets/sounds/sfx/ui/select.ogg"),
			"open": preload("res://Assets/sounds/sfx/ui/menu_open.ogg"),
		},
		"character": {
			"jump": preload("res://Assets/sounds/sfx/character/jump.ogg"),
			"land": preload("res://Assets/sounds/sfx/character/land.ogg"),
			"walk": preload("res://Assets/sounds/sfx/character/walk.ogg"),
		}
	}

func play_sfx(category: String, sound: String, pitch: float = 1.0):
	if sound_library.has(category) and sound_library[category].has(sound):
		sfx_player.stream = sound_library[category][sound]
		sfx_player.pitch_scale = pitch
		sfx_player.play()

func play_impact_sound(material_type: String):
	var pitch = rand_range(0.9, 1.1)
	play_sfx("impact", material_type, pitch)

func play_destroy_sound(material_type: String):
	var pitch = rand_range(0.8, 1.0)
	play_sfx("destroy", material_type, pitch)

func play_music(music_name: String):
	var music_path = "res://Assets/sounds/music/" + music_name + ".ogg"
	if ResourceLoader.exists(music_path):
		music_player.stream = load(music_path)
		music_player.play()

func set_master_volume(volume_db: float):
	AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, volume_db)

func mute_sfx(mute: bool):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), mute)

func mute_music(mute: bool):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), mute)
```

---

## Integration with Existing Systems

### 1. Update DestructibleProp
```gdscript
# In DestructibleProp.gd
func play_hit_effect():
	if audio_manager:
		var material = match_material_type()
		audio_manager.play_impact_sound(material)

func play_destruction_effects():
	if audio_manager:
		var material = match_material_type()
		audio_manager.play_destroy_sound(material)

func match_material_type() -> String:
	match prop_type:
		PropType.LOCKER: return "metal"
		PropType.DESK: return "wood"
		PropType.VENDING_MACHINE: return "metal"
		PropType.BOOKSHELF: return "wood"
		PropType.TABLE: return "wood"
		_: return "wood"
```

### 2. Update StickClone
```gdscript
# In StickClone.gd
func jump():
	audio_manager.play_sfx("character", "jump")
	# ... jump code

func _on_landed():
	audio_manager.play_sfx("character", "land")
```

### 3. Update Menus
```gdscript
# In menu systems
func _on_button_pressed():
	audio_manager.play_sfx("ui", "click")
	# ... button logic
```

---

## Free Sound Asset Sources

### High-Quality CC0 Packs
1. **Kenney Game Assets**: https://kenney.nl/assets
2. **OpenGameArt**: https://opengameart.org/
3. **Freesound.org**: https://freesound.org/ (with license check)
4. **Zapsplat**: https://www.zapsplat.com/ (free with account)
5. **BBC Sound Library**: https://www.bbc.co.uk/sounds/help/terms-of-use (CC BY-NC)

### Music Recommendations
- **Incompetech**: https://incompetech.com/ (CC BY 3.0)
- **Free Music Archive**: https://freemusicarchive.org/
- **Itch.io Music**: https://itch.io/music (various licenses)

---

## Audio Settings & Volume Control

### Add to Project Settings
```ini
[audio]
master_volume = 0.0  # dB
sfx_volume = -5.0
music_volume = -10.0
ambient_volume = -20.0

[game]
sound_effects_enabled = true
music_enabled = true
```

### Player Settings Menu
```gdscript
func create_audio_settings_menu():
	var vbox = VBoxContainer.new()
	
	# Master Volume Slider
	var master_label = Label.new()
	master_label.text = "Master Volume"
	vbox.add_child(master_label)
	
	var master_slider = HSlider.new()
	master_slider.min_value = -40
	master_slider.max_value = 0
	master_slider.value = AudioServer.get_bus_volume_db(0)
	master_slider.connect("value_changed", self, "_on_master_volume_changed")
	vbox.add_child(master_slider)
	
	# SFX Volume Slider
	var sfx_label = Label.new()
	sfx_label.text = "SFX Volume"
	vbox.add_child(sfx_label)
	
	var sfx_slider = HSlider.new()
	sfx_slider.min_value = -40
	sfx_slider.max_value = 0
	sfx_slider.connect("value_changed", self, "_on_sfx_volume_changed")
	vbox.add_child(sfx_slider)
	
	return vbox

func _on_master_volume_changed(value: float):
	AudioServer.set_bus_volume_db(0, value)

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)
```

---

## Performance Tips

1. **Preload critical sounds** in _ready()
2. **Use OGG format** (compressed, Godot-optimized)
3. **Limit simultaneous sounds** to 8-16 per bus
4. **Use pitch variation** to avoid repetitive sounds
5. **Loop ambient sounds** efficiently
6. **Cache frequently used sounds** in AudioManager

---

## Testing Sound Integration

```gdscript
# Debug/AudioTest.gd
func test_all_sounds():
	for category in audio_manager.sound_library.keys():
		for sound in audio_manager.sound_library[category].keys():
			print("Playing: %s/%s" % [category, sound])
			audio_manager.play_sfx(category, sound)
			yield(get_tree(), "idle_frame")
```

---

## Next Steps

1. Download sound assets from recommended sources
2. Place in Assets/sounds/ directory structure
3. Update AudioManager.gd with actual file paths
4. Integrate AudioManager as autoload in Project Settings
5. Update existing systems to use AudioManager
6. Test sound playback in each game phase
7. Adjust volumes in audio bus layout

---

*Sound Integration Guide for Toppler Phase 3*
*Ready for audio implementation*
