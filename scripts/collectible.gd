extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(deg_to_rad(90)*delta)
	rotate_x(deg_to_rad(45)*delta)


func _on_body_entered(body):
	if body.name=="Player":
		queue_free()
