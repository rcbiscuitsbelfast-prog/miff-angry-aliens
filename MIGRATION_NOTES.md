# Godot 3.2.x to 4.x Migration Notes

## Project Migration Completed

This document tracks the changes made during the migration from Godot 3.2.x to Godot 4.x.

### Major Changes

#### 1. Project Configuration (project.godot)
- Updated `config_version` from 4 to 5
- Removed `_global_script_classes` (Godot 4 auto-detects class_name)
- Updated input events format:
  - `scancode` → `physical_keycode`
  - Added `window_id`, `key_label`, and updated event properties
- Updated rendering settings:
  - `quality/driver/driver_name="GLES2"` → `renderer/rendering_method="gl_compatibility"`
  - Added `renderer/rendering_method.mobile="gl_compatibility"`
  - Updated texture compression settings for mobile

#### 2. GDScript Syntax Changes

**Export Variables:**
- `export var` → `@export var`
- `export(Type) var name` → `@export var name: Type`
- `export(int) var` → `@export var name: int`
- `export(bool) var` → `@export var name: bool`

**Onready Variables:**
- `onready var` → `@onready var`

**Type Hints:**
- `Texture` → `Texture2D`
- `Sprite` → `Sprite2D`
- `Position2D` → `Marker2D`
- `KinematicBody2D` → `CharacterBody2D`

**Function Changes:**
- `instance()` → `instantiate()`
- `rand_range()` → `randf_range()` for floats
- `randi()` → `randi()` (unchanged but context-aware)
- `get_size()` → `get_width()` / `get_height()` (for Texture2D)
- `find_node()` → `find_child(name, recursive, owned)`
- `get_tree().change_scene()` → `get_tree().change_scene_to_file()`
- `File.new().file_exists()` → `FileAccess.file_exists()`
- `.xform()` → `*` operator for Transform2D multiplication

**Signal Handling:**
- `emit_signal("signal_name", args)` → `signal_name.emit(args)`
- `connect("signal", object, "method")` → `.signal_name.connect(object.method)`
- `connect("signal", object, "method", [args])` → `.signal_name.connect(object.method.bind(args))`

**Yield to Await:**
- `yield(get_tree(), "idle_frame")` → `await get_tree().process_frame`
- `yield(get_tree().create_timer(x), "timeout")` → `await get_tree().create_timer(x).timeout`
- `yield(object, "signal_name")` → `await object.signal_name`

#### 3. Node API Changes

**CharacterBody2D (formerly KinematicBody2D):**
- `move_and_slide(velocity, up_direction)` → `move_and_slide()` (velocity is now a property)
- Added `up_direction` property (set in `_enter_tree()`)
- `velocity` is now a built-in property instead of a custom variable

**RigidBody2D:**
- `mode = RigidBody2D.MODE_STATIC` → `freeze = true`
- `mode = RigidBody2D.MODE_RIGID` → `freeze = false`
- `apply_impulse(offset, impulse)` → `apply_impulse(impulse, offset)` (parameters swapped) or `apply_central_impulse(impulse)`
- `get_colliding_bodies()` → `get_contact_count()` (for checking collisions)

**Tween:**
- Old Tween node API completely replaced
- `Tween.new()` and manual tween management → `create_tween()` returns SceneTween
- `tween.interpolate_property(...)` → `tween.tween_property(...).set_trans().set_ease()`
- Tweens now use method chaining

**Vector2:**
- `.clamped(length)` → `.limit_length(length)`
- `.snapped(step)` still works in Godot 4

#### 4. Mobile-Specific Changes

**Touch Input:**
- Touch input handling remains largely the same
- `InputEventScreenTouch` and `InputEventScreenDrag` still work
- `emulate_touch_from_mouse` setting retained for testing

**Performance:**
- Using GL Compatibility renderer for better mobile performance
- Updated texture compression for mobile (ETC2/ASTC)

### Files Modified

**Core System Files:**
- `project.godot` - Project configuration
- `Globals/Globals.gd` - Scene management, file access
- `Globals/PlayerProfile.gd` - Signal emissions, property setters
- `Globals/GameManager.gd` - Signal emissions
- `Globals/RageSystem.gd` - Signal emissions

**Player/Character:**
- `Objects/StickClone/StickClone.gd` - CharacterBody2D migration, move_and_slide changes
- `Objects/FaceProjectile/FaceProjectile.gd` - Signal connections, texture API
- `Objects/Projectile/Projectile.gd` - RigidBody2D API, signal emissions

**Game Objects:**
- `Objects/Props/DestructibleProp.gd` - Signal emissions, rand_range, instance/instantiate
- `Objects/Obstacles/Obstacle.gd` - Texture2D types
- `Objects/Rubble/RubbleChunk.gd` - RigidBody2D mode, Tween API
- `Objects/Slingshot/Slingshot.gd` - RigidBody2D, Tween API, transform operations
- `Objects/Slingshot/InputArea.gd` - Signal emissions

**UI/Scenes:**
- `Scenes/MainMenu/Clouds.gd` - find_node to find_child, Texture2D API
- `Objects/Score/Score.gd` - Sprite2D types, yield to await
- Various menu and UI files - signal connections

### Automated Migration Scripts Used

1. `migrate_godot4.sh` - Bash script for basic syntax replacements
2. `migrate_signals.py` - Python script for emit_signal migrations
3. `migrate_connects.py` - Python script for .connect() call migrations
4. `migrate_yield.py` - Python script for yield to await migrations

### Known Issues and Manual Fixes Required

1. **Custom get_class() methods** - Renamed to avoid conflicts with built-in Object.get_class()
   - `get_class()` → `get_projectile_class()`, `get_prop_class()`, etc.

2. **Scene files (.tscn)** - Will need to be opened in Godot 4 editor to auto-convert
   - Node type changes will be detected and updated
   - Some properties may need manual adjustment

3. **Export presets** - Mobile export presets need to be reconfigured in Godot 4 editor

### Testing Checklist

- [ ] Project opens in Godot 4 without errors
- [ ] Main menu loads and displays correctly
- [ ] Face capture system works
- [ ] Slingshot mechanics work with touch input
- [ ] Projectile physics and collisions work
- [ ] DestructibleProp damage and destruction work
- [ ] RubbleChunk settling and climbing work
- [ ] StickClone platformer movement works
- [ ] Room completion and progression works
- [ ] Audio plays correctly
- [ ] Mobile touch input works on device
- [ ] Performance is acceptable on mobile

### Next Steps

1. Open project in Godot 4.x editor
2. Allow editor to auto-convert scene files
3. Fix any remaining errors reported by editor
4. Test all gameplay systems
5. Configure mobile export presets
6. Test on actual mobile devices
7. Adjust performance settings as needed

### References

- [Godot 4 Migration Guide](https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.html)
- [GDScript 2.0 Changes](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
