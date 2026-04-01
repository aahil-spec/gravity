extends Control

@onready var input_box = $LineEdit
@onready var http_request = $HTTPRequest

# Note: Remember to delete this key and generate a new one in Google AI Studio 
# when you are done making the game, since it got posted in the chat!
const API_KEY = "AIzaSyAZd7SaABIXvLhPoqdNefVw9Sa0E2nK9WE"

const URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key="

func _ready():
	http_request.request_completed.connect(_on_internet_reply)

func _on_button_pressed():
	var player_text = input_box.text
	
	var rules = "You are an expert 3D level designer for a parkour game. "
	rules += "The player is aiming at the exact start of a gap. "
	rules += "STRICT RULES: 1. The FIRST block MUST be at exactly X: 0, Y: 0, Z: 0. "
	rules += "2. Max jump distance is 4 units (keep Z spacing tight in the -Z direction). "
	rules += "3. Keep X values between -2 and 2 so it forms a straight line. "
	rules += "4. If asked for a 'bridge', EVERY block must have exactly Y: 0. "
	rules += "Reply ONLY with a raw JSON array. NO markdown."
	
	var body = JSON.stringify({
		"system_instruction": {"parts": [{"text": rules}]},
		"contents": [{"parts": [{"text": player_text}]}]
	})
	
	var headers = ["Content-Type: application/json"]
	http_request.request(URL + API_KEY, headers, HTTPClient.METHOD_POST, body)
	input_box.text = "Thinking..." 

func _on_internet_reply(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	var json_data = JSON.parse_string(response_text)
	
	if not json_data.has("candidates"):
		print("API Error: ", response_text)
		input_box.text = "Error! Check Output log."
		return
		
	var gemini_json_string = json_data["candidates"][0]["content"]["parts"][0]["text"]
	gemini_json_string = gemini_json_string.replace("```json", "").replace("```", "").strip_edges()
	
	var block_list = JSON.parse_string(gemini_json_string)
	
	if block_list == null:
		print("Failed to parse JSON: ", gemini_json_string)
		input_box.text = "Gemini messed up the formatting!"
		return
	
	self.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# --- NEW CROSSHAIR SPAWN LOGIC ---
	var spawn_origin = Vector3.ZERO
	
	# Find the player in the world
	var player = get_tree().current_scene.get_node_or_null("Player") 
	
	if player != null:
		var aim_ray = player.get_node_or_null("Camera3D/AimRay")
		
		# If the laser hits a wall/floor, use that exact spot!
		if aim_ray != null and aim_ray.is_colliding():
			spawn_origin = aim_ray.get_collision_point()
		else:
			# Fallback: If looking at the empty sky, spawn 5 meters forward
			spawn_origin = player.global_position + (player.global_transform.basis.z * -5)

# Build the blocks!
	for block in block_list:
		var new_box = CSGBox3D.new()
		new_box.use_collision = true
		
		# 1. ADD IT TO THE WORLD FIRST!
		get_tree().current_scene.add_child(new_box)
		
		# 2. THEN MOVE IT TO THE CROSSHAIR!
		new_box.global_position = spawn_origin + Vector3(block["x"], block["y"], block["z"])
		
		# If bouncy, make it green
		if block.has("bouncy") and block["bouncy"] == true:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0, 1, 0)
			new_box.material = mat
			
		get_tree().current_scene.add_child(new_box)
		
# This listens for you pressing the TAB key
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if self.visible:
			# If it's open, close it and hide the mouse
			self.hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			# If it's closed, open it, show the mouse, and clear the old text!
			self.show()
			input_box.text = "" 
			input_box.grab_focus() # Automatically puts your typing cursor in the box
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
