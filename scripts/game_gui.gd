extends Control

var selected_construction_item = null

func can_drop_data(position, data):
	if Global.game_over:
		return false

	return data.data_type == "construction"

# Can place constructions also by drag'n drop
func drop_data(position, data):
	var sel = Global.get_object_under_mouse()
	if sel:
		Global.input.emit_signal("object_clicked", sel.collider, data.construction)

# called when some stat, value, etc changes
func update_stats_panel():
	$stats_panel/population.text = "%d" % Global.population
	$stats_panel/points.text = "%d" % Global.points
	$stats_panel/resources.text = "%d" % Global.resources
	$era.text = Global.era_name
	$era_progress.max_value = Global.last_era
	$era_progress.value = Global.era
	

func _construction_types_sort(c1, c2):
	return Global.construction_types[c1].list_display_order < Global.construction_types[c2].list_display_order

func update_constructions_panel():
	Global.delete_children($constructions_panel/VBoxContainer)
	
	# sort by list_display_order property
	var sorted_constructions = Global.construction_types.keys()
	sorted_constructions.sort_custom(self, "_construction_types_sort")
	
	var node
	for c in sorted_constructions:
		
		# check the era
		if		Global.ONLY_CURRENT_ERA_CONSTRUCTIONS and\
				Global.construction_types[c].era != Global.era:
			continue
			
		if Global.construction_types[c].era > Global.era:
			continue
		
		# check required population (do nothing... item grayed if not met)
		if Global.construction_types[c].population_required > Global.population:
			pass

		node = preload("res://scenes/structure_item.tscn").instance()
		node.construction = Global.construction_types[c]
		$constructions_panel/VBoxContainer.add_child(node)
	
	select_structure_item(selected_construction_item)


func _ready():
	update_stats_panel()
	update_constructions_panel()


func _on_swap_50_res_to_points_pressed():
	if Global.game_over:
		return

	var resources = Global.resources * 0.5
	Global.points = Global.points + resources * (1 - Global.EXCHANGE_PENALTY)
	Global.resources = Global.resources - resources


func _on_swap_50_points_to_res_pressed():
	if Global.game_over:
		return

	var points = Global.points * 0.5
	Global.resources = Global.resources + points * (1 - Global.EXCHANGE_PENALTY)
	Global.points = Global.points - points


func select_structure_item(construction):
	selected_construction_item = construction
	var found = false
	for o in $constructions_panel/VBoxContainer.get_children():
		if o.construction == construction:
			o.get_node("selected").show()
			found = true
		else:
			o.get_node("selected").hide()
	if not found:
		selected_construction_item = null


func _on_goto_menu_btn_pressed():
	get_tree().change_scene("res://scenes/main_menu.tscn")
