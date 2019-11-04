extends Spatial


func _on_startbutton_pressed():
	# try load construction types properties from file
	# IMPORTANT: it is used to allow team members tune gameplay without
	# using Godot.
	# Enable only for testing because it can pose a security risk.
	var values = null
	if false:
		var f = File.new()
		var err = f.open("./values.txt", File.READ)
		if err == OK:
			values = f.get_as_text()
			f.close()

	Global.start_game(values)


func _on_quitbutton_pressed():
	get_tree().quit()


func _on_easy_pressed():
	$easy.pressed = true
	$medium.pressed = false
	$hard.pressed = false
	Global.difficulty = 0

func _on_medium_pressed():
	$easy.pressed = false
	$medium.pressed = true
	$hard.pressed = false
	Global.difficulty = 1

func _on_hard_pressed():
	$easy.pressed = false
	$medium.pressed = false
	$hard.pressed = true
	Global.difficulty = 2
