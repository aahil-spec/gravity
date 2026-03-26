extends CharacterBody3D

@export var speed=6.0
@export var jump_velocity=8.0
var gravity_strength=9.8
var gravity_dir=Vector3.DOWN
var gravity_list=[
	Vector3.DOWN,
	Vector3.UP,
	Vector3.LEFT,
	Vector3.RIGHT
]
var current_index=0
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
	if Input.is_action_just_pressed("switch_gravity"):
		switch_gravity()
	var input_dir=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var direction=(transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized()
	var fall_vel=velocity.project(gravity_dir)
	var walk_vel=direction*speed
	velocity=walk_vel+fall_vel
	move_and_slide()
	
func switch_gravity():
	current_index+=1
	if current_index>=gravity_list.size():
		current_index=0
		
	gravity_dir=gravity_list[current_index]
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
	tween.tween_property(self,"transform:basis",target_basis,0.4).set_trans(Tween.TRANS_SINE)
