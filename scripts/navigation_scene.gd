extends Node2D

func _ready():
	print("Navigation Scene initialized")

func _on_left_button_pressed():
	get_tree().change_scene_to_file("res://scenes/townsquare.tscn")
	print("Left button pressed - Coming Soon!")

func _on_middle_button_pressed():
	print("Middle button pressed - Loading Kingdom Policy")
	get_tree().change_scene_to_file("res://scenes/kingdom_policy.tscn")

func _on_right_button_pressed():
	get_tree().change_scene_to_file("res://scenes/diplomacyscreen.tscn")
	print("Right button pressed - Coming Soon!")
