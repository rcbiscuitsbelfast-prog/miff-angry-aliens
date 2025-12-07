extends ColorRect

@export var enabled: bool = false

func _ready():
	set_process(enabled)
	visible = enabled

func _process(delta: float) -> void:
	$Label.text = str(Performance.get_monitor(Performance.TIME_FPS)) + " FPS"
