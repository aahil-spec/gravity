extends Control

@onready var input_box = $LineEdit
@onready var http_request = $HTTPRequest

# 🎨 MATERIAL SLOTS (Drag and drop your .tres files here in the Inspector!)
@export var regular_material: Material
@export var bouncy_material: Material

# 🛑 Paste your fresh API key here!
const API_KEY = "AIzaSyAZd7SaABIXvLhPoqdNefVw9Sa0E2nK9WE"
const URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key="

func _ready():
	http_request.request_completed.connect(_on_internet_reply)
	hide_terminal()

# ⌨️ THE TAB TOGGLE
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if self.visible:
			hide_terminal()
		else:
			show_terminal()

func show_terminal():
	self.show()
	input_box.text = ""
	input_box.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_terminal():
	self.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_button_pressed():
	var player_text = input_box.text
	var rules = "You are an expert 3D level designer. "
	rules += "1. The FIRST block MUST be at 0,0,0. "
	rules += "2. Every block MUST be in the negative Z direction (e.g. -2, -4, -6) to go FORWARD. "
	rules += "3. For a flat bridge, Y MUST be 0. "
	rules += "4. Reply ONLY with a raw JSON array of objects. No markdown."
	
	var body = JSON.stringify({
		"system_instruction": {"parts": [{"text": rules}]},
		"contents": [{"parts": [{"text": player_text}]}]
	})
	
	var headers = ["Content-Type: application/json"]
	http_request.request(URL + API_KEY, headers, HTTPClient.METHOD_POST, body)
	input_box.text = "Thinking..." 

func _on_internet_reply(_result, response_code, _headers, body):
	var response_text = body.get_string_from_utf8()
	
	if response_code != 200:
		input_box.text = "API Error! Check Key."
		return
		
	var json_data = JSON.parse_string(response_text)
	if json_data == null or not json_data.has("candidates"):
		input_box.text = "AI Error!"
		return

	var raw_text = json_data["candidates"][0]["content"]["parts"][0]["text"]
	raw_text = raw_text.replace("```json", "").replace("```", "").strip_edges()
	
	var block_list = JSON.parse_string(raw_text)
	
	# Handle cases where Gemini wraps the array in a dictionary
	if block_list is Dictionary:
		for key in block_list:
			if block_list[key] is Array:
				block_list = block_list[key]
				break

	if typeof(block_list) != TYPE_ARRAY:
		input_box.text = "AI Formatting Error!"
		return

	hide_terminal()
	
	# --- FIND PLAYER AND SPAWN POINT ---
	var player = get_tree().current_scene.get_node_or_null("Player") 
	var spawn_origin = Vector3.ZERO
	
	if player == null:
		return

	var aim_ray = player.get_node_or_null("Camera3D/AimRay")
	if aim_ray != null and aim_ray.is_colliding():
		spawn_origin = aim_ray.get_collision_point()
	else:
		# Fallback: 2 meters in front of feet
		spawn_origin = player.global_position + (player.global_transform.basis.z * -2)
		spawn_origin.y -= 1.0 

	# --- BUILD BLOCKS ---
	for block in block_list:
		if typeof(block) != TYPE_DICTIONARY: continue
		
		var new_box = CSGBox3D.new()
		new_box.use_collision = true
		new_box.size = Vector3(2, 1, 2)
		
		# Add to scene FIRST
		get_tree().current_scene.add_child(new_box)
		
		# Position math (Rotated based on player's face direction)
		# Subtracting 0.5 makes the TOP of the block level with the floor/crosshair
		var local_offset = Vector3(block.get("x", 0), block.get("y", 0) - 0.5, block.get("z", 0))
		var rotated_offset = player.global_transform.basis * local_offset
		
		new_box.global_position = spawn_origin + rotated_offset
		
		# Assign Textures from the Inspector slots
		if block.get("bouncy", false) == true:
			new_box.material = bouncy_material 
		else:
			new_box.material = regular_material
