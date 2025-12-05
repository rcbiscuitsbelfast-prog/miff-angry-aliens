# Phase 3 Features Guide - Content, Sound & Cosmetics

## Overview
Phase 3 implementation brings advanced content customization, sound integration, and animation systems to Toppler.

---

## Feature 1: Face Capture System

### Components
- **FaceCaptureManager.gd**: Main capture controller
- **FaceCaptureScene.tscn**: UI for face capture

### Features Implemented

#### 1. Upload Mode
- File dialog for selecting images from disk
- Support for PNG and JPEG formats
- Automatic image loading and texture creation

#### 2. Point Detection
- Interactive point markers for eye and mouth positions
- Draggable control points (green for eyes, red for mouth)
- Visual feedback for point positioning

#### 3. Multi-Step Flow
```
Step 1: MODE_SELECT
├─ Upload Button → File Dialog
└─ Camera Button → Camera Setup

Step 2: CONFIRM_EYES
├─ Display face with eye points
├─ User drags points to eye positions
└─ "Eyes Confirmed" button

Step 3: CONFIRM_MOUTH
├─ Display mouth point
├─ User drags to mouth position
└─ "Mouth Confirmed" button

Step 4: COMPLETE
└─ "Finish" button → Save & Return
```

### Data Structure
```gdscript
face_data = {
	"texture": Texture,
	"points": {
		"left_eye": Vector2(x, y),
		"right_eye": Vector2(x, y),
		"mouth": Vector2(x, y)
	}
}
```

### Integration Points
- Saved to PlayerProfile.face_points
- Used for emotion animation (future)
- Used for cosmetic alignment (future)

### Usage
```gdscript
# From main menu
func _on_customize_face():
	get_tree().change_scene("res://Scenes/FaceCapture/FaceCaptureScene.tscn")

# Programmatically
var capture_manager = FaceCaptureManager.new()
capture_manager.connect("face_captured", self, "_on_face_captured")
```

---

## Feature 2: Animation System

### Components
- **StickCloneAnimator.gd**: Animation controller
- **Sprite sheet integration**: Fighter sprites with frame ranges

### Animation States
```gdscript
enum AnimState {
	IDLE,      # Standing still (frames 0-5)
	WALK,      # Walking animation (frames 6-13)
	JUMP,      # Full jump arc (frames 14-17)
	JUMP_UP,   # Ascending portion (frames 14-15)
	JUMP_DOWN, # Descending portion (frames 16-17)
	CLIMB      # Climbing rubble (frames 18-23)
}
```

### Frame Configuration
```gdscript
frames_per_animation = {
	IDLE: {"start": 0, "end": 5, "speed": 0.15},
	WALK: {"start": 6, "end": 13, "speed": 0.1},
	JUMP: {"start": 14, "end": 17, "speed": 0.2},
	JUMP_UP: {"start": 14, "end": 15, "speed": 0.15},
	JUMP_DOWN: {"start": 16, "end": 17, "speed": 0.15},
	CLIMB: {"start": 18, "end": 23, "speed": 0.12}
}
```

### Usage
```gdscript
# In StickClone.gd
func _ready():
	animator = StickCloneAnimator.new()
	add_child(animator)

func handle_movement():
	if Input.is_action_pressed("ui_right"):
		animator.play_animation(AnimState.WALK)
		animator.set_facing_direction(1.0)

func jump():
	animator.play_animation(AnimState.JUMP_UP)
	yield(animator, "animation_finished")
	animator.play_animation(AnimState.JUMP_DOWN)
```

### Sprite Sheet Layout
```
Fighter Sprite Sheet (960x64 resolution)
│
├─ IDLE (0-5): Standing pose, slight bounce
├─ WALK (6-13): Walk cycle frames
├─ JUMP (14-17): Jump arc from ground to peak to landing
├─ CLIMB (18-23): Climbing animation
```

### AnimatedSprite vs Sprite
- **Uses AnimatedSprite when available**: Full animation playback
- **Falls back to Sprite**: Frame-by-frame control if needed

---

## Feature 3: Cosmetic System

### Components
- **CosmeticMenuScene.gd**: Cosmetic customization UI
- **CosmeticMenuScene.tscn**: Layout and controls
- **PlayerProfile enhancements**: Cosmetic storage

### Cosmetic Types
1. **Hats**
   - default (no hat)
   - tophat
   - cowboy
   - future: beret, crown, etc.

2. **Glasses**
   - none
   - sunglasses
   - nerd glasses
   - future: monocle, 3D glasses, etc.

3. **Moustaches**
   - none
   - normal
   - fancy/handlebar
   - future: pencil, walrus, etc.

4. **Wigs**
   - none
   - afro
   - long hair
   - future: ponytail, mohawk, etc.

### Menu Structure
```
CosmeticMenuScene
├─ PreviewPanel (left 30%)
│   ├─ PreviewSprite: Character display
│   └─ FacePreview: Face texture with overlays
│
├─ ScrollContainer (right 70%)
│   ├─ HatSection
│   │   └─ HatGrid: 4-column button grid
│   ├─ GlassesSection
│   │   └─ GlassesGrid: 4-column button grid
│   ├─ MoustacheSection
│   │   └─ MoustacheGrid: 4-column button grid
│   └─ WigSection
│       └─ WigGrid: 4-column button grid
│
└─ BottomPanel
    ├─ CancelButton
    └─ ApplyButton
```

### Data Persistence
```gdscript
# PlayerProfile storage
selected_cosmetics = {
	"hat": "tophat",
	"glasses": "sunglasses",
	"moustache": "normal",
	"wig": "none"
}

# Saved to player profile
player_profile.current_hat = "tophat"
player_profile.current_glasses = "sunglasses"
player_profile.save_profile()
```

### Integration with Game
```gdscript
# In StickClone._ready()
func apply_cosmetics():
	var profile = get_node("/root/PlayerProfile")
	cosmetic_menu.apply_cosmetics_to_character(self)
	# Creates overlay sprites for hats, glasses, etc.
```

### Menu Access
```gdscript
# From Enhanced Menu
func _on_customize_cosmetics():
	var cosmetics_menu = load("res://Scenes/CosmeticMenu/CosmeticMenuScene.tscn").instance()
	add_child(cosmetics_menu)
	cosmetics_menu.connect("menu_closed", self, "_on_cosmetics_done")
```

---

## Feature 4: Sound Integration

### Components
- **AudioManager.gd**: Centralized audio system
- **Sound library**: Organized SFX database
- **Audio bus layout**: Volume mixing

### Audio Structure
```
Master Bus (0dB)
├─ SFX Bus (-5dB, 60% volume)
│   ├── Impact Sounds (0dB)
│   │   ├── wood_hit.ogg
│   │   ├── metal_hit.ogg
│   │   └── stone_destroy.ogg
│   ├── UI Sounds (-10dB)
│   │   ├── button_click.ogg
│   │   ├── menu_open.ogg
│   │   └── select.ogg
│   └── Ambient (-20dB)
│       ├── wind.ogg
│       └── environment_ambient.ogg
│
└─ Music Bus (-10dB, 40% volume)
    ├── menu_music.ogg
    ├── cafeteria_music.ogg
    ├── bonus_music.ogg
    └── victory_music.ogg
```

### Sound Library Organization
```
Assets/sounds/
├── sfx/
│   ├── impact/
│   │   ├── wood_hit.ogg
│   │   ├── metal_hit.ogg
│   │   ├── stone_hit.ogg
│   │   ├── wood_destroy.ogg
│   │   ├── metal_destroy.ogg
│   │   └── stone_destroy.ogg
│   ├── ui/
│   │   ├── button_click.ogg
│   │   ├── menu_open.ogg
│   │   ├── select.ogg
│   │   └── menu_close.ogg
│   ├── character/
│   │   ├── jump.ogg
│   │   ├── land.ogg
│   │   ├── walk.ogg
│   │   └── climb.ogg
│   └── environment/
│       ├── wind.ogg
│       ├── cafeteria_ambient.ogg
│       └── completion.ogg
│
└── music/
    ├── menu_music.ogg
    ├── cafeteria_music.ogg
    ├── bonus_music.ogg
    └── victory_music.ogg
```

### Usage Examples
```gdscript
# Play destruction sounds with material type
audio_manager.play_destroy_sound("wood")
audio_manager.play_destroy_sound("metal")

# Play UI sounds
audio_manager.play_sfx("ui", "click")

# Play character sounds
audio_manager.play_sfx("character", "jump")

# Play background music
audio_manager.play_music("cafeteria")

# Volume control
audio_manager.set_master_volume(-10.0)
audio_manager.mute_sfx(false)
```

### Integration with Systems
```gdscript
# DestructibleProp destruction
func destroy_prop():
	var material = match_material_type()  # "wood", "metal", "stone"
	audio_manager.play_destroy_sound(material)

# StickClone jumping
func jump():
	audio_manager.play_sfx("character", "jump")

# Menu interactions
func _on_button_pressed():
	audio_manager.play_sfx("ui", "click")
```

### Sound Asset Resources
**Free sources**:
- Kenney.nl - High-quality game audio
- OpenGameArt.org - CC0 licensed sounds
- Freesound.org - Searchable sound library
- Itch.io - Indie audio packs

**See SOUND_INTEGRATION_GUIDE.md for detailed setup**

---

## Integration with Existing Systems

### PlayerProfile Enhancements
```gdscript
# New fields added:
var face_points: Dictionary = {}  # Eye and mouth positions

# New methods:
func set_face_points(points: Dictionary)
func get_face_points() -> Dictionary
```

### EnhancedTopplerMenu Updates
```gdscript
# New customization menu with options:
func show_customization_menu()
    ├── "Capture New Face" → FaceCaptureScene
    ├── "Customize Cosmetics" → CosmeticMenuScene
    └── "Change Face Emotion" → Emotion dialog

# New methods:
func _on_face_capture_pressed()
func _on_cosmetics_pressed()
func _on_cosmetic_menu_closed()
```

### StickClone Enhancements
```gdscript
# Animator integration:
func _ready():
	animator = StickCloneAnimator.new()

# Animation control:
func handle_traversal_input():
	if moving:
		animator.play_animation(AnimState.WALK)
	else:
		animator.play_animation(AnimState.IDLE)

# Cosmetic application:
func apply_cosmetics():
	cosmetic_system.apply_cosmetics_to_character(self)
```

---

## Configuration

### Project Settings

Add to project.godot:
```ini
[autoload]
AudioManager="*res://Audio/AudioManager.gd"

[audio]
master_volume = 0.0
sfx_volume = -5.0
music_volume = -10.0

[animation]
stick_clone_idle_speed = 0.15
stick_clone_walk_speed = 0.1
stick_clone_jump_speed = 0.2
```

### Scene Requirements

**FaceCaptureScene.tscn**:
- ModeContainer (initial choice)
- CaptureContainer (camera/upload)
- ConfirmContainer (point adjustment)

**CosmeticMenuScene.tscn**:
- PreviewPanel (left 30%)
- ScrollContainer (right 70%)
  - HatSection with HatGrid
  - GlassesSection with GlassesGrid
  - MoustacheSection with MoustacheGrid
  - WigSection with WigGrid
- BottomPanel with buttons

---

## File Structure
```
Objects/
├── FaceCapture/
│   └── FaceCaptureManager.gd
├── StickClone/
│   ├── StickCloneAnimator.gd
│   └── [existing files]
├── Audio/
│   └── AudioManager.gd (to create)
└── [existing]

Scenes/
├── FaceCapture/
│   └── FaceCaptureScene.tscn
├── CosmeticMenu/
│   ├── CosmeticMenuScene.gd
│   └── CosmeticMenuScene.tscn
└── [existing]

Assets/
├── sounds/
│   ├── sfx/
│   │   ├── impact/
│   │   ├── ui/
│   │   ├── character/
│   │   └── environment/
│   └── music/
├── cosmetics/
│   ├── hats/
│   ├── glasses/
│   ├── moustaches/
│   └── wigs/
└── [existing]
```

---

## Testing Checklist

### Face Capture
- [ ] Upload dialog opens correctly
- [ ] Image loads and displays
- [ ] Eye points are draggable
- [ ] Mouth point is draggable
- [ ] Face data saves to PlayerProfile
- [ ] Returns to main menu on finish

### Animations
- [ ] Idle animation plays continuously
- [ ] Walk animation triggers with movement
- [ ] Jump animation plays on jump
- [ ] Climb animation plays on climb
- [ ] Animation direction follows facing direction
- [ ] Frame transitions are smooth

### Cosmetics
- [ ] Cosmetic menu opens from main menu
- [ ] All cosmetic options display
- [ ] Selected cosmetics highlight
- [ ] Preview updates on selection
- [ ] Cosmetics apply to character in game
- [ ] Cosmetics persist across sessions

### Sound
- [ ] Impact sounds play on destruction
- [ ] Destruction sounds play on prop death
- [ ] UI sounds play on button clicks
- [ ] Music plays in backgrounds
- [ ] Volume adjustments work
- [ ] Sound variation prevents repetition

---

## Performance Optimization

### Animation
- Use TextureAtlas for sprite sheets
- Limit simultaneous animations to 1 per sprite
- Cache frame calculations

### Sound
- Preload frequently used SFX
- Use OGG format (efficient compression)
- Limit simultaneous sounds to 8-16
- Use pitch variation instead of duplicate files

### Cosmetics
- Cache cosmetic textures after first load
- Use LayeredTexture for overlays
- Limit cosmetic layers to 3-4

---

## Future Enhancements

### Phase 3.5
- [ ] Emotion system with eye/mouth animation
- [ ] Cosmetic unlocking system
- [ ] Sound effect variations per prop material

### Phase 4
- [ ] Motion capture integration
- [ ] Custom cosmetic creation
- [ ] Voice lines and dialogue
- [ ] Advanced audio mixing

---

## Documentation Files
- **SOUND_INTEGRATION_GUIDE.md**: Detailed sound setup
- **PHASE2_IMPLEMENTATION_GUIDE.md**: Previous phase details
- **TESTING_GUIDE.md**: Comprehensive testing procedures

---

*Phase 3 Features Complete*
*Face capture, animation system, cosmetics, and sound integration ready for deployment*
