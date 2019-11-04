extends Control

var construction setget construction_set


func get_drag_data(position):
	return {"data_type": "construction", "construction": construction}
	

func construction_set(value):
	construction = value
	$image.texture = construction.image
	$points_cost.text = str(value.points_cost)
	$resources_cost.text = str(value.resources_cost)
	$description.text = Global.get_construction_description(construction)

	# check requirements
	if 		construction.population_required > Global.population or\
			construction.points_cost > Global.points or\
			construction.resources_cost > Global.resources:
		$description.add_color_override("font_color", Color("606060"))
	else:
		$description.add_color_override("font_color", Color("FFFFFF"))


func _on_StructureItem_gui_input(event):
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == BUTTON_LEFT:
			if (event as InputEventMouseButton).pressed:
				Global.gui.select_structure_item(construction)
