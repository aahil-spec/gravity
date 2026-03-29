extends Area3D

func _on_body_entered(body):
	if body.name =="Player":
		body.global_position=Vector3(0,5,0)
		body.velocity=Vector3.ZERO
		body.set_gravity(Vector3.DOWN)
