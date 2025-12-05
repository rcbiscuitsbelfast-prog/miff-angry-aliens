# Cafeteria Room Implementation
# First complete room for Toppler with lunch-themed destruction

extends "res://Scenes/Rooms/RoomBase.gd"

func _ready():
	# Set room configuration
	room_name = "Cafeteria"
	target_destruction_score = 5000
	has_bonus_level = true
	bonus_level_scene = preload("res://Scenes/BonusLevels/VentEscape.tscn")
	
	# Call parent _ready
	super._ready()
	
	# Setup cafeteria-specific elements
	setup_cafeteria()

func setup_cafeteria():
	# Create dynamic props if not already in scene
	if props_container.get_child_count() == 0:
		spawn_cafeteria_props()

func spawn_cafeteria_props():
	# Create lunch tables
	for i in range(4):
		var table = create_prop(
			DestructibleProp.PropType.TABLE,
			Vector2(200 + i * 150, 350),
			"Table " + str(i + 1),
			100
		)
		props_container.add_child(table)
	
	# Create serving station
	var serving_station = create_prop(
		DestructibleProp.PropType.DESK,
		Vector2(150, 200),
		"Serving Station",
		200
	)
	props_container.add_child(serving_station)
	
	# Create vending machine
	var vending = create_prop(
		DestructibleProp.PropType.VENDING_MACHINE,
		Vector2(700, 300),
		"Vending Machine",
		250
	)
	props_container.add_child(vending)
	
	# Create trophy shelf
	var shelf = create_prop(
		DestructibleProp.PropType.BOOKSHELF,
		Vector2(50, 250),
		"Trophy Shelf",
		150
	)
	props_container.add_child(shelf)

func create_prop(prop_type: int, position: Vector2, name: String, value: int) -> DestructibleProp:
	var prop = preload("res://Objects/Props/DestructibleProp.tscn").instance()
	prop.name = name
	prop.global_position = position
	prop.prop_type = prop_type
	prop.max_hitpoints = 2 + randi() % 2  # 2-3 hitpoints
	prop.current_hitpoints = prop.max_hitpoints
	
	# Connect signals
	prop.connect("prop_destroyed", self, "_on_prop_destroyed", [prop, value])
	prop.connect("prop_damaged", self, "_on_prop_damaged", [prop])
	
	return prop