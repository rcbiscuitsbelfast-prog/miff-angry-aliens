# Fighter Enemy Integration Example

This file demonstrates how to integrate the new fighter enemy into your Angry Aliens game.

## Quick Integration Steps

### 1. Add Fighter Enemy to Level
Open any level scene (e.g., `Level1.tscn`) and add:

```gdscript
# Add as instance in the level scene
[node name="FighterEnemy1" parent="LevelNodes" instance=ExtResource( "path_to_fighter_enemy" )]
position = Vector2( 400, 300 )
groups = [ "enemies" ]
```

### 2. Update Project Classes
Add to `project.godot` global script classes:

```ini
[section]
"base": "Enemy",
"class": "FighterEnemy", 
"language": "GDScript",
"path": "res://Objects/Enemy/FighterEnemy.gd"
```

### 3. Use in Level Design
- Fighter enemies are tougher than regular aliens (health: 100 vs default)
- They have animated states: idle, hit, death
- Can be placed alongside regular aliens for variety

## Testing Integration

1. Open `Level1.tscn`
2. Replace one alien instance with `FighterEnemy.tscn`
3. Test that slingshot physics work correctly
4. Verify destruction animations play properly
5. Check scoring system works with new enemy type

## Customization Options

### Health Points
```gdscript
# In FighterEnemy.gd or level scene
export var health = 150  # Make even tougher
```

### Damage Thresholds
```gdscript
export var damage_threshold = 1200  # Require more force to destroy
```

### Animation Speed
```gdscript
# In setup_animations() method
animation_player.add_animation("idle", create_animation(idle_frames, 12, true))  # Faster idle
```

## Visual Effects Integration

The fighter enemy works with existing VFX systems:

- **Destruction**: Uses same debris system as regular enemies
- **Hit Effects**: Can trigger hit animations and particles
- **Score Display**: Integrates with existing score popup system

## Performance Considerations

- Fighter sprites are slightly larger than alien sprites
- Consider using fighter enemies sparingly for performance
- Animation system is optimized but adds slight overhead

## Game Balance

Recommended balance adjustments:
- Fighter enemies worth more points (200-500 vs 100 for regular aliens)
- Longer respawn times if implementing enemy waves
- Consider making them "boss" type enemies in later levels