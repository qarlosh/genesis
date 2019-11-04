extends Node

# two parameters: 1. The object clicked, 2. The construction tu put [optional]
signal object_clicked

var dragging = false
var drag_last_pos: Vector2
var globe: Spatial
var cam_pivot_y: Spatial
var cam_pivot_x: Spatial
var camera: Camera

func _ready():
	globe = get_node("../globe")
	cam_pivot_y = get_node("../camera pivot Y")
	cam_pivot_x = get_node("../camera pivot Y/camera pivot X")
	camera = get_node("../camera pivot Y/camera pivot X/Camera")


func _input(event):	
	# (Mouse in viewport coordinates)
	if event is InputEventMouseButton:

		# mouse left click
		if (event as InputEventMouseButton).button_index == BUTTON_LEFT:
			if (event as InputEventMouseButton).pressed:
				if not Global.game_over:
					var sel = Global.get_object_under_mouse()
					if sel:
						emit_signal("object_clicked", sel.collider, null)

		# start globe rotation by dragging
		if (event as InputEventMouseButton).button_index in [BUTTON_RIGHT, BUTTON_MIDDLE]:
			if (event as InputEventMouseButton).pressed:
				dragging = true
				drag_last_pos = get_viewport().get_mouse_position()
			else:
				dragging = false
		
		# zoom out using wheel
		if (event as InputEventMouseButton).button_index == BUTTON_WHEEL_DOWN:
			camera.fov = min(camera.fov + 2, 70)
			
		# zoom in using wheel
		if (event as InputEventMouseButton).button_index == BUTTON_WHEEL_UP:
			camera.fov = max(camera.fov - 2, 20)
		

	# handle globe rotation by dragging
	elif event is InputEventMouseMotion:
		if dragging:
			# drag speed depending on camera fov (zoom). 50 is "normal"
			var multiplier = 0.3 * camera.fov / 50
			var a = event.position - drag_last_pos
			cam_pivot_y.rotate(Vector3(0, 1, 0), -multiplier * deg2rad(a.x))
			cam_pivot_x.rotate(Vector3(1, 0, 0), -multiplier * deg2rad(a.y))
			cam_pivot_x.rotation.x = clamp(cam_pivot_x.rotation.x, deg2rad(-60), deg2rad(60))
			drag_last_pos = event.position

	elif event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
	elif event.is_action_pressed("low_detail"):
		Global.set_graphics_detail_level(0)
	elif event.is_action_pressed("medium_detail"):
		Global.set_graphics_detail_level(1)
	elif event.is_action_pressed("high_detail"):
		Global.set_graphics_detail_level(2)
