extends Area3D

# 1. Drag your next level file here in the Inspector
@export_file("*.tscn") var next_level_path: String

# 2. Drag your "LEVEL COMPLETE" UI node here in the Inspector
@export var level_complete_ui: Control 

func _ready():
	# 🛡️ THE FIX: This hides the text automatically when the game starts
	if level_complete_ui:
		level_complete_ui.hide()

func _on_body_entered(body):
	# Check if the thing that touched the zone is the Player
	if body.name == "Player":
		print("Goal reached!")
		
		# Now we show it because the player actually won!
		if level_complete_ui:
			level_complete_ui.show()
		
		# Wait for 2 seconds so they can see the message
		await get_tree().create_timer(2.0).timeout
		
		# Move to the next level
		if next_level_path != "" and next_level_path != null:
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("Error: No next level path selected in the Inspector!")
