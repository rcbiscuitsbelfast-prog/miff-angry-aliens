extends Node2D


@onready var level_placeholder = $Level1


func _ready():
    var params = get_parent().scene_parameters
    if !params:
        return
    var level: PackedScene = load(Globals.get_level_path(params.level))
    Globals.current_level_index = params.level
    level_placeholder.replace_by(level)
    
    
