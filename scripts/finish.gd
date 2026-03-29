extends Area3D

@onready var win_ui=$WinUI

func _ready():
	win_ui.hide()

func _on_body_entered(body):
	if body.name=="Player":
		win_ui.show()
		get_tree().paused=true
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
