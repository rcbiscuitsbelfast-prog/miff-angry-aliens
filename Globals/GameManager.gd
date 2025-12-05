extends Node

# Main Toppler Game Manager
# Orchestrates game flow, room progression, and cosmetics

signal room_started(room_name)
signal room_completed(score, combo)
signal game_state_changed(new_state)

enum GameState { MENU, PLAYING, BONUS_LEVEL, GAME_OVER, PAUSED }
var current_state = GameState.MENU

# Room progression
var current_room_index = 0
var rooms_data = [
    {
        "name": "Cafeteria",
        "scene": "res://Scenes/Rooms/Cafeteria/Cafeteria.tscn",
        "description": "Time to destroy some lunch!",
        "unlocked": true,
        "target_score": 5000
    },
    {
        "name": "Classroom",
        "scene": "res://Scenes/Rooms/Classroom/Classroom.tscn",
        "description": "Smash the school supplies!",
        "unlocked": false,
        "target_score": 7500
    },
    {
        "name": "Computer Lab",
        "scene": "res://Scenes/Rooms/ComputerLab/ComputerLab.tscn",
        "description": "Destroy the tech!",
        "unlocked": false,
        "target_score": 10000
    },
    {
        "name": "Principal Office",
        "scene": "res://Scenes/Rooms/PrincipalOffice/PrincipalOffice.tscn",
        "description": "Redecorating time!",
        "unlocked": false,
        "target_score": 12500
    },
    {
        "name": "Chemistry Lab",
        "scene": "res://Scenes/Rooms/ChemistryLab/ChemistryLab.tscn",
        "description": "Experimental destruction!",
        "unlocked": false,
        "target_score": 15000
    }
]

func unlock_all_rooms():
    for room in rooms_data:
        room["unlocked"] = true

func _ready():
    set_process_unhandled_input(true)

func start_room(room_index: int):
    if room_index >= rooms_data.size():
        print("No more rooms!")
        show_game_complete()
        return
    
    current_room_index = room_index
    var room_data = rooms_data[room_index]
    current_state = GameState.PLAYING
    
    emit_signal("room_started", room_data["name"])
    Globals.goto_scene(room_data["scene"], room_data)

func complete_room(score: int, combo: int):
    emit_signal("room_completed", score, combo)
    
    # Unlock next room
    if current_room_index + 1 < rooms_data.size():
        rooms_data[current_room_index + 1]["unlocked"] = true
    
    # Update player profile
    PlayerProfile.complete_room()
    PlayerProfile.update_progress(score, combo)
    
    # Show room completion screen
    show_room_complete(score)

func show_room_complete(score: int):
    # TODO: Create room completion UI
    print("Room completed! Score: ", score)

func show_game_complete():
    # TODO: Create game completion UI
    print("Game completed!")

func get_unlocked_rooms() -> Array:
    var unlocked = []
    for room in rooms_data:
        if room["unlocked"]:
            unlocked.append(room)
    return unlocked

func get_room_data(index: int) -> Dictionary:
    if index < rooms_data.size():
        return rooms_data[index]
    return {}

func unlock_cosmetic(cosmetic_type: String, name: String):
    PlayerProfile.unlock_cosmetic(cosmetic_type, name)

func _unhandled_input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ESCAPE:
            if current_state == GameState.PLAYING:
                pause_game()
            elif current_state == GameState.PAUSED:
                resume_game()

func pause_game():
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true
        emit_signal("game_state_changed", GameState.PAUSED)

func resume_game():
    if current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false
        emit_signal("game_state_changed", GameState.PLAYING)

func restart_room():
    start_room(current_room_index)