# New Fighter Assets Documentation

## Overview
The `New/` folder contains a complete set of fighter character sprites that can be used to replace or supplement the current alien characters in the Angry Aliens game.

## Asset Structure

### Fighter Animation Sprites
The fighter character includes the following animation sequences:

#### Idle Animation
- **Frames**: fighter_Idle_0001.png through fighter_Idle_0008.png (8 frames)
- **Use**: Character standing still
- **Recommended FPS**: 8-10

#### Walk Animation  
- **Frames**: fighter_walk_0009.png through fighter_walk_0016.png (8 frames)
- **Use**: Character walking at normal speed
- **Recommended FPS**: 12-15

#### Run Animation
- **Frames**: fighter_run_0017.png through fighter_run_0024.png (8 frames)
- **Use**: Character running/charging
- **Recommended FPS**: 15-20

#### Climb Animation
- **Frames**: fighter_climb_0039.png through fighter_climb_0042.png (4 frames)
- **Use**: Character climbing ladders or surfaces
- **Recommended FPS**: 10-12

#### Dash Animation
- **Frames**: fighter_dash_0033.png through fighter_dash_0038.png (6 frames)
- **Use**: Character dashing/quick movement
- **Recommended FPS**: 20-30

#### Slide Animation
- **Frames**: fighter_slide_0025.png through fighter_slide_0032.png (8 frames)
- **Use**: Character sliding on ground
- **Recommended FPS**: 15-20

#### Hit Animation
- **Frames**: fighter_hit_0048.png through fighter_hit_0051.png (4 frames)
- **Use**: Character taking damage
- **Recommended FPS**: 15-20 (one-shot animation)

#### Death Animation
- **Frames**: fighter_death_0052.png through fighter_death_0061.png (10 frames)
- **Use**: Character being destroyed
- **Recommended FPS**: 15-20 (one-shot animation)

#### Jump Animation
- **Frames**: fighter_jump_0043.png through fighter_jump_0047.png (5 frames)
- **Use**: Character jumping/falling
- **Recommended FPS**: 15-20

### Additional Assets
- **Random UUID PNGs**: Various additional character sprites with UUID names
- These can be used for alternative character variations or special effects

## Implementation Guide

### Option 1: Replace Current Aliens
1. **Update Enemy.gd**: Modify the sprite texture paths to use fighter sprites
2. **Update Level Scenes**: Replace alien sprite references with fighter sprites
3. **Adjust Physics**: Fighter sprites may have different dimensions, adjust collision shapes accordingly

### Option 2: Add as New Enemy Type
1. **Create New Enemy Scene**: Duplicate `Objects/Enemy/Enemy.tscn`
2. **Update Sprites**: Replace alien sprites with fighter sprites
3. **Create New Script**: Extend Enemy.gd for fighter-specific behavior
4. **Add to Levels**: Include new fighter enemy in level scenes

### Option 3: Create Player Character
1. **New Scene**: Create player character scene using fighter sprites
2. **Input Handling**: Add player input controls
3. **Game Mode**: Modify game to support player-controlled character

## Integration Steps

### 1. Sprite Replacement
```gdscript
# In Enemy.gd or new enemy script
func _ready():
    $Sprite.texture = load("res://New/fighter_Idle_0001.png")
    # Set up animation player
    $AnimationPlayer.play("idle")
```

### 2. Animation Setup
```gdscript
# Create AnimatedSprite node with fighter sprites
func setup_animations():
    var idle_frames = []
    for i in range(1, 9):
        idle_frames.append(load("res://New/fighter_Idle_%04d.png" % i))
    
    $AnimatedSprite.frames = SpriteFrames.new()
    $AnimatedSprite.frames.add_animation("idle")
    for frame in idle_frames:
        $AnimatedSprite.frames.add_frame("idle", frame)
```

### 3. Physics Adjustments
- Fighter sprites appear to be ~64x64 pixels (vs current alien sprites)
- Update collision shapes: `RectangleShape2D.extents = Vector2(32, 32)`
- Adjust mass and physics properties as needed

## Scene Integration

### Adding to Existing Levels
1. Open level scene (e.g., `Scenes/Levels/LevelNodes/Level1.tscn`)
2. Replace alien instances with fighter instances
3. Adjust positions and group assignments
4. Test physics interactions

### Creating New Fighter Enemy
1. Create new scene: `Objects/Enemy/FighterEnemy.tscn`
2. Base on Enemy.tscn but use fighter sprites
3. Add animation player for different states
4. Set up proper collision detection

## Technical Notes

- **Import Status**: All fighter sprites now have proper .import files
- **Compatibility**: Compatible with Godot 3.2.x
- **Format**: PNG with transparency
- **Size**: Approximately 64x64 pixels per frame
- **Color Scheme**: Blue/purple themed character with white accents

## Recommended Usage

For best results with the Angry Aliens gameplay:

1. **Use as Enemy Type**: Fighter sprites work well as new enemy variants
2. **Animation States**: Use idle for standing, hit for damage, death for destruction
3. **Physics Integration**: Maintain current physics but adjust for sprite dimensions
4. **Visual Effects**: Can combine with existing VFX system for enhanced gameplay

## Asset Credits

These fighter sprites appear to be from a professional sprite pack. Ensure proper attribution if used in published games.