extends Area3D

@export_file("*.tscn") var next_level_path: String

@export var level_complete_ui: Control 

func _ready():
	if level_complete_ui:
		level_complete_ui.hide()

func _on_body_entered(body):
	if body.name == "Player":
		print("Goal reached!")
		
		if level_complete_ui:
			level_complete_ui.show()

		await get_tree().create_timer(2.0).timeout

		if next_level_path != "" and next_level_path != null:
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("Error: No next level path selected in the Inspector!")
