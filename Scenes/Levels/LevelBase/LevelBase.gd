extends Node2D


@onready var vfx_manager = $ParticlesManager
@onready var score = $GUI/Score
@onready var level_completed = $GameEndScreen/LevelCompleted

var scene_parameters = {}


func _init():
	pass


func _post_init(params = {}):
	scene_parameters = params
	
	
func _ready():
	for projectile in get_tree().get_nodes_in_group("projectile"):
		projectile.body_entered.connect(vfx_manager._on_Projectile_body_entered.bind(projectile))


func _on_TouchScreenButton_released():
	get_tree().reload_current_scene()


func _on_ProjectilesLoader_level_finished():
	level_completed.appear(score.score_value)

