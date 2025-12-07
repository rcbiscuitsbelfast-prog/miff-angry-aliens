""" Detect touch inputs and dispatch signals to the Slingshot node.
"""
extends Area2D

signal slingshot_released
signal slingshot_grabbed
signal slingshot_moved

var touch = false

@onready var rest_position = get_parent().get_node("RestPosition")


func _ready():
    visible = true


func _input(event):
    if event is InputEventScreenTouch:
        if not event.is_pressed():
            slingshot_released.emit()
            touch = false

    if event is InputEventScreenDrag:
        if touch:
            slingshot_moved.emit(event.position)


func _on_InputArea_input_event(viewport, event: InputEvent, shape_idx):
    if event is InputEventScreenTouch:
        if event.is_pressed():
            slingshot_grabbed.emit()
            touch = true
