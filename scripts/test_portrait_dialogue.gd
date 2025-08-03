extends Node2D

var dialogue_scene = preload("res://scenes/portrait_dialogue_v2.tscn")
var current_dialogue = null

func _ready():
	print("Portrait Dialogue Test Scene Loaded")
	print("Press 1, 2, or 3 to test different dialogues")

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		clear_dialogue()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				start_dialogue(0)
			KEY_2:
				start_dialogue(1)
			KEY_3:
				start_dialogue(2)

func start_dialogue(dialogue_id: int):
	# Clear any existing dialogue
	clear_dialogue()
	
	# Create new dialogue instance
	current_dialogue = dialogue_scene.instantiate()
	current_dialogue.dialogue_id = dialogue_id
	current_dialogue.type_speed = 0.03  # Slightly faster for testing
	
	# Connect to the finished signal
	current_dialogue.dialogue_finished.connect(_on_dialogue_finished)
	
	# Add to scene
	add_child(current_dialogue)
	
	print("Started dialogue ID: ", dialogue_id)

func clear_dialogue():
	if current_dialogue:
		current_dialogue.queue_free()
		current_dialogue = null
		print("Dialogue cleared")

func _on_dialogue_finished():
	print("Dialogue finished!")
	# Automatically remove dialogue when finished
	clear_dialogue() 