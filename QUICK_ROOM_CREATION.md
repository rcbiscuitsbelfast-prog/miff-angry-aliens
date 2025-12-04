# Quick Room Creation Guide

## Add a New Room in 5 Minutes

### Step 1: Create Room Script
```bash
# Copy Cafeteria.gd to new room name
cp Scenes/Rooms/Cafeteria/Cafeteria.gd Scenes/Rooms/Classroom/Classroom.gd
```

### Step 2: Rename the Script
```gdscript
# Change "class_name" if needed (optional)
extends "res://Scenes/Rooms/RoomBase.gd"

# Update room config in _ready()
func _ready():
    room_name = "Classroom"  # Change this
    target_destruction_score = 7500  # Increase difficulty
    # ... rest of setup
```

### Step 3: Create Props Function
```gdscript
func spawn_classroom_props():
    # Student desks
    for i in range(8):
        var desk = create_prop(
            DestructibleProp.PropType.DESK,
            Vector2(150 + i * 80, 300 + (i % 2) * 100),
            "Desk " + str(i + 1),
            80
        )
        props_container.add_child(desk)
    
    # Add whiteboard
    var whiteboard = create_prop(
        DestructibleProp.PropType.BOOKSHELF,
        Vector2(700, 150),
        "Whiteboard",
        150
    )
    props_container.add_child(whiteboard)
```

### Step 4: Create Room Scene
```bash
# Duplicate and rename scene
cp Scenes/Rooms/Cafeteria/Cafeteria.tscn Scenes/Rooms/Classroom/Classroom.tscn
```

### Step 5: Update Scene References
- Open Classroom.tscn in editor
- Change script path to Classroom.gd
- Update background if desired

### Step 6: Register Room
```gdscript
# In GameManager.gd
rooms_data = [
    # ... existing rooms
    {
        "name": "Classroom",
        "scene": "res://Scenes/Rooms/Classroom/Classroom.tscn",
        "description": "Smash the school supplies!",
        "unlocked": false,  # Unlock when previous room completed
        "target_score": 7500
    }
]
```

---

## Room Template

All rooms inherit from RoomBase and have this structure:

```gdscript
extends "res://Scenes/Rooms/RoomBase.gd"

func _ready():
    room_name = "Your Room Name"
    target_destruction_score = 5000
    has_bonus_level = true
    bonus_level_scene = preload("res://Scenes/BonusLevels/VentEscape.tscn")
    super._ready()
    setup_your_room()

func setup_your_room():
    if props_container.get_child_count() == 0:
        spawn_your_props()

func spawn_your_props():
    # Create and add props here
    var prop = create_prop(
        DestructibleProp.PropType.LOCKER,
        Vector2(x, y),
        "Prop Name",
        score_value
    )
    props_container.add_child(prop)
```

---

## Available Prop Types

```gdscript
DestructibleProp.PropType:
  LOCKER           # Metal, resistant (150 points)
  DESK             # Wooden, normal (120 points)
  VENDING_MACHINE  # Heavy, very resistant (200 points)
  BOOKSHELF        # Fragile, easy break (80 points)
  TABLE            # Standard resistance (100 points)
```

---

## Environment Ideas

### Computer Lab
```gdscript
# Monitors on desks
for i in range(5):
    props += create_prop(DESK, position, "Computer " + str(i), 120)

# Server rack (vending machine = heavy)
props += create_prop(VENDING_MACHINE, position, "Server", 250)

# Filing cabinets (shelves)
props += create_prop(BOOKSHELF, position, "Cabinet", 100)
```

### Principal Office
```gdscript
# Fancy desk
props += create_prop(DESK, position, "Mahogany Desk", 180)

# Filing cabinets
props += create_prop(BOOKSHELF, position, "Cabinet", 120)

# Sitting area
for i in range(3):
    props += create_prop(TABLE, position, "Table " + str(i), 100)

# Award case
props += create_prop(BOOKSHELF, position, "Awards", 90)
```

### Chemistry Lab
```gdscript
# Lab benches (desks)
for i in range(4):
    props += create_prop(DESK, position, "Lab Bench", 150)

# Chemical cabinet (vending = expensive)
props += create_prop(VENDING_MACHINE, position, "Cabinet", 300)

# Glassware (bookshelf = fragile)
props += create_prop(BOOKSHELF, position, "Glassware", 120)

# Storage locker
props += create_prop(LOCKER, position, "Storage", 140)
```

---

## Difficulty Progression

```
Cafeteria (Beginner)
  target_score: 5000
  avg_prop_hits: 2

Classroom (Easy)
  target_score: 7500
  avg_prop_hits: 2-3

Computer Lab (Medium)
  target_score: 10000
  avg_prop_hits: 3

Principal Office (Hard)
  target_score: 12500
  avg_prop_hits: 3-4

Chemistry Lab (Expert)
  target_score: 15000
  avg_prop_hits: 4+
```

---

## Quick Commands

```bash
# Duplicate cafeteria files to new room
mkdir Scenes/Rooms/YourRoom
cp Scenes/Rooms/Cafeteria/Cafeteria.gd Scenes/Rooms/YourRoom/YourRoom.gd
cp Scenes/Rooms/Cafeteria/Cafeteria.tscn Scenes/Rooms/YourRoom/YourRoom.tscn

# Edit and customize, then register in GameManager
```

---

## Testing Your Room

1. Add room to `GameManager.rooms_data`
2. Set `"unlocked": true` temporarily
3. Press F5 in Godot
4. Select your room from menu
5. Test destruction, traversal, exit
6. Adjust prop difficulty as needed
7. Set `"unlocked": false` when done

---

That's it! You can create a new complete room in under 5 minutes!