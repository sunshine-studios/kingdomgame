extends Node2D

# Note: Global variables are now managed by GameState autoload

# Scene management
var current_scene: Node = null

# UI References - Now referencing scene nodes
@onready var debug_panel: Control = $DebugPanel
@onready var debug_label: Label = $DebugPanel/DebugLabel
@onready var load_portrait_dialogue_button: Button = $LoadPortraitDialogueButton
@onready var load_policy_button: Button = $LoadPolicyButton
@onready var load_navigation_button: Button = $LoadNavigationButton

func _ready():
	print("Main Root initialized")
	setup_ui_connections()
	update_debug_display()

func setup_ui_connections():
	# Connect button signal - UI elements are now in the scene tree
	if load_portrait_dialogue_button:
		load_portrait_dialogue_button.pressed.connect(_on_load_portrait_dialogue_pressed)
	if load_policy_button:
		load_policy_button.pressed.connect(_on_load_policy_pressed)
	if load_navigation_button:
		load_navigation_button.pressed.connect(_on_load_navigation_pressed)

func update_debug_display():
	return

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Enter key for testing
		return
	elif event.is_action_pressed("ui_cancel"):  # Escape key for testing
		return
	elif event is InputEventKey and event.pressed:
		return

func toggle_debug_panel():
	if debug_panel:
		debug_panel.visible = !debug_panel.visible
		print("Debug panel toggled: ", debug_panel.visible)

func _on_load_scene_01_pressed():
	load_chapter_scene("res://scenes/chapter01_scene01.tscn")

func _on_load_portrait_dialogue_pressed():
	load_chapter_scene("res://scenes/portrait_dialogue_tool_v02.tscn")

func _on_load_policy_pressed():
	load_chapter_scene("res://scenes/kingdom_policy.tscn")

func _on_load_navigation_pressed():
	load_chapter_scene("res://scenes/navigation_scene.tscn")

func load_chapter_scene(scene_path: String):
	print("Loading scene: ", scene_path)
	
	# Clear current scene if it exists
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	# Load new scene
	var scene_resource = load(scene_path)
	if scene_resource:
		current_scene = scene_resource.instantiate()
		add_child(current_scene)
		
		# Ensure debug panel stays on top by moving it to front
		if debug_panel:
			move_child(debug_panel, get_child_count() - 1)
		
		print("Scene loaded successfully: ", scene_path)
		update_debug_display()
	else:
		print("Failed to load scene: ", scene_path)
