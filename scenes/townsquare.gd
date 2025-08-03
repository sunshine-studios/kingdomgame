extends Node2D


func _on_back_button_pressed() -> void:
	print("back button pressed - Loading Navigation ")
	get_tree().change_scene_to_file("res://scenes/navigation_scene.tscn")
	pass # Replace with function body.
	pass # Replace with function body.
