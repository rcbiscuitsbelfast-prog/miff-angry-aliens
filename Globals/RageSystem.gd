extends Node

# Rage and combo system for Toppler

signal rage_changed(new_rage, max_rage)
signal combo_changed(combo_count, multiplier)
signal rage_threshold_reached(level)

# Rage system
var current_rage = 0.0
var max_rage = 100.0
var rage_level = 1

# Combo system
var combo_multiplier = 1.0
var props_destroyed_combo = 0
var combo_timer: Timer
var last_destruction_time = 0.0

# Rage thresholds
const RAGE_THRESHOLDS = [25.0, 50.0, 75.0, 100.0]

func _ready():
    setup_combo_timer()

func setup_combo_timer():
    combo_timer = Timer.new()
    add_child(combo_timer)
    combo_timer.wait_time = 2.0  # 2 seconds to continue combo
    combo_timer.one_shot = true
    combo_timer.timeout.connect(self._on_combo_timeout)

func add_destruction_points(prop_value: int, impact_force: float = 0):
    props_destroyed_combo += 1
    
    # Calculate combo multiplier
    combo_multiplier = 1.0 + (props_destroyed_combo - 1) * 0.5
    combo_multiplier = min(combo_multiplier, 5.0)  # Cap at 5x
    
    # Calculate rage gain
    var base_rage = float(prop_value) / 50.0  # Base rage from prop value
    var impact_bonus = impact_force / 1000.0  # Bonus from heavy impacts
    var combo_bonus = (props_destroyed_combo - 1) * 2.0  # Bonus from combo
    
    var rage_gain = base_rage + impact_bonus + combo_bonus
    current_rage = min(current_rage + rage_gain, max_rage)
    
    # Reset combo timer
    combo_timer.start()
    last_destruction_time = OS.get_ticks_msec()
    
    # Check for rage level advancement
    check_rage_thresholds()
    
    # Emit signals
    rage_changed.emit(current_rage, max_rage)
    combo_changed.emit(props_destroyed_combo, combo_multiplier)

func check_rage_thresholds():
    var new_rage_level = 1
    
    for i in range(RAGE_THRESHOLDS.size()):
        if current_rage >= RAGE_THRESHOLDS[i]:
            new_rage_level = i + 2  # +2 because rage_level 1 is < 25
    
    if new_rage_level > rage_level:
        rage_level = new_rage_level
        rage_threshold_reached.emit(rage_level)

func _on_combo_timeout():
    # Reset combo when timer expires
    props_destroyed_combo = 0
    combo_multiplier = 1.0
    combo_changed.emit(0, 1.0)

func get_rage_percentage() -> float:
    return current_rage / max_rage

func is_rage_active() -> bool:
    return current_rage > 0

func get_rage_color() -> Color:
    # Return color based on rage level
    match rage_level:
        1:
            return Color(0.5, 0.8, 1.0)  # Blue - calm
        2:
            return Color(0.8, 1.0, 0.5)  # Yellow - building
        3:
            return Color(1.0, 0.8, 0.2)  # Orange - angry
        4:
            return Color(1.0, 0.4, 0.2)  # Red-orange - very angry
        5:
            return Color(1.0, 0.2, 0.2)  # Red - maximum rage
        _:
            return Color(1.0, 1.0, 1.0)  # White - default

func consume_rage(amount: float) -> bool:
    if current_rage >= amount:
        current_rage -= amount
        rage_changed.emit(current_rage, max_rage)
        
        # Check if rage level decreased
        check_rage_thresholds()
        return true
    return false

func reset_rage():
    current_rage = 0.0
    rage_level = 1
    props_destroyed_combo = 0
    combo_multiplier = 1.0
    combo_timer.stop()
    
    rage_changed.emit(current_rage, max_rage)
    combo_changed.emit(0, 1.0)

func get_combo_description() -> String:
    match props_destroyed_combo:
        0:
            return ""
        1:
            return "1x Combo"
        2:
            return "Double Kill!"
        3:
            return "Triple Kill!"
        4:
            return "DOMINATING!"
        5:
            return "UNSTOPPABLE!"
        _:
            return str(props_destroyed_combo) + "x COMBO!"