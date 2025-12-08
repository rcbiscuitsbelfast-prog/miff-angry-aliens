@tool
extends TextureButton

@export var text: String:
    set(value):
        _set_btn_text(value)


func _ready():
    pressed.connect(_on_pressed)


func _unhandled_input(event):
    if disabled:
        return
    # fix button on smartphone
    if event is InputEventScreenTouch:
        if _is_btn_pressed(self, event):
            pressed.emit()


func _is_btn_pressed(btn: BaseButton, event: InputEventScreenTouch):
    if not event is InputEventScreenTouch:
        print("ERROR: Event ", event, " is not InputEventScreenTouch")
        return
    if Rect2(btn.get_global_rect().position, btn.size).has_point(event.position):
        return true


func _on_pressed():
    $AudioStreamPlayer.play()


func _set_btn_text(value):
    # fix issue #20 in develop branch
    var label = get_node_or_null("Label")
    if label == null:
        return
    label.text = value
    text = value

