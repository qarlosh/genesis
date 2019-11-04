extends Spatial

func _ready():
	Global.camera = $"camera pivot Y/camera pivot X/Camera"
	Global.player = $player
	Global.input = $input
	Global.gui = $gui
	Global.globe = $globe
	Global.pivots = $globe/pivots
	Global.sunlight = $sunlight
	Global.moonlight = $moonlight
	Global.environment = preload("res://default_env.tres")
	Global.environment.adjustment_saturation = 1.0
	Global.environment.adjustment_brightness = 1.0
	Global.environment.adjustment_contrast = 1.0
	
	# Pivots are defined in the globel model. From Blender, they are
	# defined by placing Empty objects inside a parent Empty called "Pivots".
	# Get these pivots from the globe model and create them.
	var pivot
	for p in $globe/Pivots.get_children():
		pivot = preload("res://scenes/pivot.tscn").instance()
		pivot.translation = p.to_global(Vector3(0, 0, 0))
		$globe/pivots.add_child(pivot)
	
	Global.set_graphics_detail_level(Global.graphics_detail_level)
	Global.apply_era_effects()


func _process(delta):
	# slow sun/sunlight/moonlight rotation
	$sunlight.rotate(Vector3(0, 1, 0), delta * deg2rad(2))
	$moonlight.rotate(Vector3(0, 1, 0), delta * deg2rad(2))
	Global.environment.background_sky_rotation_degrees.y = $sunlight.rotation_degrees.y - 180
