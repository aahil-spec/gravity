extends CharacterBody3D

@export var speed=7.0
@export var jump_velocity=5.0
var gravity_strength=15.0
var gravity_dir=Vector3.DOWN
@onready var camera=$Camera3D
var mouse_sens=0.003
func _ready():
	up_direction=-gravity_dir

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode ==Input.MOUSE_MODE_CAPTURED:
		rotate_object_local(Vector3.UP,-event.relative.x*mouse_sens)
		camera.rotate_object_local(Vector3.RIGHT,-event.relative.y*mouse_sens)
		camera.rotation.x=clamp(camera.rotation.x,deg_to_rad(-85),deg_to_rad(85))
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity+=up_direction*jump_velocity
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if not is_on_floor():
		velocity+=gravity_dir*gravity_strength*delta
	if Input.is_action_just_pressed("grav_down"):set_gravity(Vector3.DOWN)
	if Input.is_action_just_pressed("grav_up"):set_gravity(Vector3.UP)
	if Input.is_action_just_pressed("grav_left"):set_gravity(Vector3.LEFT)
	if Input.is_action_just_pressed("grav_right"):set_gravity(Vector3.RIGHT)
	var input_dir=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var direction=(transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized()
	var fall_vel=velocity.project(gravity_dir)
	var walk_vel=direction*speed
	velocity=walk_vel+fall_vel
	move_and_slide()
	if global_position.y<-15.0:
		global_position=Vector3(0,5,0)
		velocity=Vector3.ZERO
		set_gravity(Vector3.DOWN)
	
func set_gravity(new_dir:Vector3):
	if gravity_dir==new_dir:
		return
	gravity_dir=new_dir
	up_direction=-gravity_dir
	align_with_gravity()
func align_with_gravity():
	var new_up=-gravity_dir
	var current_forward=-transform.basis.z
	if abs(current_forward.dot(new_up))>0.99:
		current_forward=transform.basis.y
	var new_right=new_up.cross(current_forward).normalized()
	var new_forward=new_right.cross(new_up).normalized()
	var target_basis=Basis(new_right,new_up,-new_forward)
	
	var tween=create_tween()
	tween.tween_property(self, "quaternion", target_basis.get_rotation_quaternion(), 0.4).set_trans(Tween.TRANS_SINE)
