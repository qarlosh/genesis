extends Node

var camera: Camera
var globe
var pivots
var input
var gui
var player
var sunlight
var moonlight
var environment: Environment
var graphics_detail_level = 1
var game_over = false

var audio_levelup = preload("res://sfx/LevelUpAgeSFX2.wav")
var audio_place = preload("res://sfx/PlaceSFX3.wav")
var audio_denied = preload("res://sfx/DeniedSFX.wav")

var difficulty = 0


const NATURE_DESTRUCTION_RADIUS = 1.5

var EXCHANGE_PENALTY = 0.25		# % of resources or points lost
								# when transfering from one to the other

var GOD_MODE = false	# for testing purpose, overrides other values. Begin in
						# last era, with 100000 resources, points and population,
						# and resources don't decrease.
						# The values of ONLY_CURRENT_ERA_CONSTRUCTIONS,
						# REPLACE_ONLY_PAST_ERA_CONSTRUCTIONS and POINTS_INCREASE_SPEED
						# are untouched.

var GOD_MODE_FROM_FIRST_ERA = true		# if god mode is ON, it will start from frist Era

var ONLY_CURRENT_ERA_CONSTRUCTIONS = true	# show only constructions of current
											# era in the panel or show also past
											# era constructions

var REPLACE_ONLY_PAST_ERA_CONSTRUCTIONS = true # can replace only constructions of
											# past eras, or can replace also
											# current era constructions

var POINTS_INCREASE_SPEED = 0.20			# points per second and per population

var RESOURCES_DECREASE_SPEED_EASY = 0.25			# resources per second and per population
var RESOURCES_DECREASE_SPEED_MEDIUM = 0.5
var RESOURCES_DECREASE_SPEED_HARD = 0.75

# Initialized in line 470 aprox
var points: float = 0
var resources: float = 0
var population: float = 0

# Eras enumeration
enum {ERA_CAVEMEN, ERA_TRIBAL, ERA_ANCIENT, ERA_MEDIEVAL, ERA_MODERN, ERA_FUTURE, ERA_WIN_GAME}

var timer_seconds = 1

var last_era = ERA_FUTURE # just previous to ERA_WIN_GAME

var era_names = {
		ERA_CAVEMEN: "The Cavemen Era",
		ERA_TRIBAL: "The Tribal Era",
		ERA_ANCIENT: "The Ancient Era",
		ERA_MEDIEVAL: "The Medieval Era",
		ERA_MODERN: "The Modern Era",
		ERA_FUTURE: "The Future Era",
		ERA_WIN_GAME: "The End"
	}

var era_effects = {
		ERA_CAVEMEN:	{fog_depth = 4000,	sunlight_color = "FFFFFF", moonlight_color = "6464FF"},
		ERA_TRIBAL:		{fog_depth = 300,	sunlight_color = "FFFFFF", moonlight_color = "6464FF"},
		ERA_ANCIENT:	{fog_depth = 200,	sunlight_color = "FFFFFF", moonlight_color = "6464FF"},
		ERA_MEDIEVAL:	{fog_depth = 150,	sunlight_color = "FFFFFF", moonlight_color = "6464FF"},
		ERA_MODERN:		{fog_depth = 100,	sunlight_color = "FFFFFF", moonlight_color = "6464FF"},
		ERA_FUTURE:		{fog_depth = 50,	sunlight_color = "FFFFFF", moonlight_color = "6464FF"},
		ERA_WIN_GAME:	{fog_depth = 40,	sunlight_color = "FFFFFF", moonlight_color = "6464FF"}
	}

# Current era
# Initialized in line 470 aprox
var era: int
var era_name: String setget ,era_name_get

# How many constructions have been added
var construction_count: int = 0

# Maximum number of constructions that can be added
var max_constructions: int = 1000000

# Construction types
# NOTE: Some use directly the escn imported from blender, others use an
# inherited scene (tscn), and maybe some use an obj model...
var construction_types = {
	
	# CAVEMEN ERA
	"cave": {
		name = "Cave",
		era = ERA_CAVEMEN,
		resources_cost = 20,
		points_cost = 20,
		population_required = 0,
		population = 3,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 10,
		mesh = preload("res://scene_models/cave.tscn"),
		mesh_scale = 0.4,
		mesh_offset = 0.2,
		image = preload("res://images/cave.png")
	},
	"lake": {
		name = "Lake",
		era = ERA_CAVEMEN,
		resources_cost = 20,
		points_cost = 30,
		population_required = 0,
		population = 0,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 2,
		unlocks_era = 0,
		list_display_order = 20,
		mesh = preload("res://scene_models/Lake.tscn"),
		mesh_scale = 0.1,
		mesh_offset = 0.1,
		image = preload("res://icon.png")
	},
	"stonehenge": {
		name = "Stonehenge",
		era = ERA_CAVEMEN,
		resources_cost = 55,
		points_cost = 30,
		population_required = 9,
		population = 0,
		points_increase_speed_boost = 0.1,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 30,
		mesh = preload("res://scene_models/stonehenge.tscn"),
		mesh_scale = 0.2,
		mesh_offset = 0,
		image = preload("res://images/stonehenge.png")
	},
	"bonfire": {
		name = "Bonfire",
		era = ERA_CAVEMEN,
		resources_cost = 150,
		points_cost = 150,
		population_required = 18,
		population = 0,
		points_increase_speed_boost = 0.01,
		resources_increase_speed = 0,
		unlocks_era = ERA_TRIBAL,
		list_display_order = 40,
		mesh = preload("res://scene_models/Bonfire.tscn"),
		mesh_scale = 0.5,
		mesh_offset = 0,
		image = preload("res://images/bonfire.png")
	},
	
	# TRIBAL ERA
	"tent": {
		name = "Tent",
		era = ERA_TRIBAL,
		resources_cost = 170,
		points_cost = 170,
		population_required = 0,
		population = 6,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 0.0,
		unlocks_era = ERA_MEDIEVAL,
		list_display_order = 110,
		mesh = preload("res://models/Tent.obj"),
		mesh_scale = 0.4,
		mesh_offset = 0,
		image = preload("res://images/tent.png")
	},	
	
	"tribal_pot": {
		name = "Tribal Pot",
		era = ERA_TRIBAL,
		resources_cost = 170,
		points_cost = 190,
		population_required = 0,
		population = 10,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 7.0,
		unlocks_era = 0,
		list_display_order = 120,
		mesh = preload("res://models/TribalPot.escn"),
		mesh_scale = 0.2,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},	

	"sabertooth": {
		name = "Sabertooth Statue",
		era = ERA_TRIBAL,
		resources_cost = 190,
		points_cost = 220,
		population_required = 0,
		population = 10,
		points_increase_speed_boost = 0.2,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 130,
		mesh = preload("res://models/SaberTooth.escn"),
		mesh_scale = 0.6,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},

	# MEDIEVAL ERA
	"castle": {
		name = "Castle",
		era = ERA_MEDIEVAL,
		resources_cost = 800,
		points_cost = 800,
		population_required = 0,
		population = 15,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 0.0,
		unlocks_era = ERA_MODERN,
		list_display_order = 510,
		mesh = preload("res://models/Castle.escn"),
		mesh_scale = 0.2,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	"house": {
		name = "House",
		era = ERA_MEDIEVAL,
		resources_cost = 240,
		points_cost = 240,
		population_required = 0,
		population = 10,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 1020,
		mesh = preload("res://models/House.escn"),
		mesh_scale = 0.25,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	"well": {
		name = "Well",
		era = ERA_MEDIEVAL,
		resources_cost = 500,
		points_cost = 280,
		population_required = 0,
		population = 0,
		points_increase_speed_boost = 0.2,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 150,
		mesh = preload("res://models/Well.escn"),
		mesh_scale = 0.2,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	"medieval_market": {
		name = "Market",
		era = ERA_MEDIEVAL,
		resources_cost = 290,
		points_cost = 320,
		population_required = 0,
		population = 0,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 10,
		unlocks_era = 0,
		list_display_order = 510,
		mesh = preload("res://models/medievalMarket.escn"),
		mesh_scale = 0.7,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	# MODERN ERA
	"apartment": {
		name = "Apartment",
		era = ERA_MODERN,
		resources_cost = 850,
		points_cost = 850,
		population_required = 0,
		population = 30,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 1010,
		mesh = preload("res://models/Apartment.escn"),
		mesh_scale = 0.25,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},	
	
	"factory": {
		name = "Factory",
		era = ERA_MODERN,
		resources_cost = 1200,
		points_cost = 1200,
		population_required = 0,
		population = 0,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 40,
		unlocks_era = 0,
		list_display_order = 1030,
		mesh = preload("res://models/Factory.escn"),
		mesh_scale = 0.2,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	"museum": {
		name = "Museum",
		era = ERA_MODERN,
		resources_cost = 1200,
		points_cost = 1500,
		population_required = 120,
		population = 0,
		points_increase_speed_boost = 0.5,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 1050,
		mesh = preload("res://models/museum.escn"),
		mesh_scale = 0.14,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	"blimp": {
		name = "Blimp",
		era = ERA_MODERN,
		resources_cost = 2500,
		points_cost = 2500,
		population_required = 0,
		population = 0,
		points_increase_speed_boost = 0.3,
		resources_increase_speed = 30,
		unlocks_era = 0,
		list_display_order = 1060,
		mesh = preload("res://models/Blimp.escn"),
		mesh_scale = 0.22,
		mesh_offset = 2,
		image = preload("res://icon.png")
	},

	"rocket": {
		name = "Rocket",
		era = ERA_MODERN,
		resources_cost = 4000,
		points_cost = 4000,
		population_required = 150,
		population = 0,
		points_increase_speed_boost = 1.0,
		resources_increase_speed = 0.0,
		unlocks_era = ERA_FUTURE,
		list_display_order = 1080,
		mesh = preload("res://models/Rocket.escn"),
		mesh_scale = 0.5,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	# FUTURE ERA
	"futuristic_home": {
		name = "Futuristic Home",
		era = ERA_FUTURE,
		resources_cost = 6000,
		points_cost = 5000,
		population_required = 0,
		population = 40,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 0.0,
		unlocks_era = 0,
		list_display_order = 1210,
		mesh = preload("res://models/FuturisticHome.obj"),
		mesh_scale = 0.1,
		mesh_offset = 0,
		image = preload("res://icon.png")
	},
	
	"space_cruiser": {
		name = "Space Cruiser",
		era = ERA_FUTURE,
		resources_cost = 8000,
		points_cost = 8000,
		population_required = 60,
		population = 0,
		points_increase_speed_boost = 0.0,
		resources_increase_speed = 90,
		unlocks_era = ERA_WIN_GAME,
		list_display_order = 1250,
		mesh = preload("res://models/SpaceCruiser.escn"),
		mesh_scale = 0.4,
		mesh_offset = 1.5,
		image = preload("res://icon.png")
	}

}

func era_name_get():
	return era_names[era]


func start_game(values_script):
	# start game, when pressed the start button in the main menu
	
	# create a script from string with construction types properties
	if values_script:
		var script
		script = GDScript.new()
		script.source_code = "extends Object\n\n%s" % values_script
		script.reload()
		var values = script.new()

		if values.timer_seconds != null:
			timer_seconds = values.timer_seconds

		if values.resources != null:
			resources = values.resources
			
		if values.points != null:
			points = values.points
			
		if values.population != null:
			population = values.population
		
		if values.ONLY_CURRENT_ERA_CONSTRUCTIONS != null:
			ONLY_CURRENT_ERA_CONSTRUCTIONS = values.ONLY_CURRENT_ERA_CONSTRUCTIONS

		if values.REPLACE_ONLY_PAST_ERA_CONSTRUCTIONS != null:
			REPLACE_ONLY_PAST_ERA_CONSTRUCTIONS = values.REPLACE_ONLY_PAST_ERA_CONSTRUCTIONS
		
		if values.POINTS_INCREASE_SPEED != null:
			POINTS_INCREASE_SPEED = values.POINTS_INCREASE_SPEED
			
		if values.RESOURCES_DECREASE_SPEED_EASY != null:
			RESOURCES_DECREASE_SPEED_EASY = values.RESOURCES_DECREASE_SPEED_EASY
		if values.RESOURCES_DECREASE_SPEED_MEDIUM != null:
			RESOURCES_DECREASE_SPEED_MEDIUM = values.RESOURCES_DECREASE_SPEED_MEDIUM
		if values.RESOURCES_DECREASE_SPEED_HARD != null:
			RESOURCES_DECREASE_SPEED_HARD = values.RESOURCES_DECREASE_SPEED_HARD

		if values.GOD_MODE != null:
			GOD_MODE = values.GOD_MODE

		if values.GOD_MODE_FROM_FIRST_ERA != null:
			GOD_MODE_FROM_FIRST_ERA = values.GOD_MODE_FROM_FIRST_ERA

		if values.EXCHANGE_PENALTY != null:
			EXCHANGE_PENALTY = values.EXCHANGE_PENALTY
		
		var construction_types = values.construction_types
		for c in self.construction_types:
			if c in construction_types:
				for p in construction_types[c]:
					self.construction_types[c][p] = construction_types[c][p]
	else:
		# reset to default values
		points = 50
		resources = 75
		population = 3
		era = ERA_CAVEMEN
		construction_count = 0

	# God mode?
	if GOD_MODE:
		if not GOD_MODE_FROM_FIRST_ERA:
			era = last_era
		points = 100000
		population = 100000
		resources = 100000
		RESOURCES_DECREASE_SPEED_EASY = 0
		RESOURCES_DECREASE_SPEED_MEDIUM = 0
		RESOURCES_DECREASE_SPEED_HARD = 0

	game_over = false
	
	get_tree().change_scene("res://scenes/main_game.tscn")
	
	$Timer.wait_time = timer_seconds
	$Timer.start()


# lose game
func game_over():
	game_over = true
	environment.adjustment_saturation = 0.2
	environment.adjustment_brightness = 0.7
	gui.get_node("game_over_msg").show()
	$Timer.stop()
	
# "win" game
func win_game():
	game_over = true
	environment.adjustment_saturation = 0.2
	environment.adjustment_brightness = 1.0
	environment.adjustment_contrast = 0.5
	gui.get_node("congrats_msg").show()
	$Timer.stop()


# Main logic here
func _on_Timer_timeout():
	if game_over:
		return

	# apply or calculate each construction behaviors/bonus
	var total_points_increase_speed_boost = 0
	var total_resources_increase_speed = 0
	var pivot
	for pivot in pivots.get_children():
		if pivot.construction:
			total_points_increase_speed_boost = total_points_increase_speed_boost + pivot.construction.points_increase_speed_boost
			total_resources_increase_speed = total_resources_increase_speed + pivot.construction.resources_increase_speed

	# increase points on population
	points = points + (POINTS_INCREASE_SPEED + total_points_increase_speed_boost) * population
	
	# decrease resources on population
	if difficulty == 0:
		resources = resources - RESOURCES_DECREASE_SPEED_EASY * population
	elif difficulty == 1:
		resources = resources - RESOURCES_DECREASE_SPEED_MEDIUM * population
	elif difficulty == 2:
		resources = resources - RESOURCES_DECREASE_SPEED_HARD * population
	
	# increase resources on constructions
	resources = resources + total_resources_increase_speed
	
	if resources < 0:
		resources = 0

	# lose condition: resources or population reaching 0
	if resources <= 0 or population <= 0:
		game_over()

	gui.update_stats_panel()
	gui.update_constructions_panel()


func get_construction_description(construction):
	var description = construction.name
	if construction.points_increase_speed_boost:
		description = description  + "\nPoints boost %d%%" % (construction.points_increase_speed_boost*100)
	if construction.resources_increase_speed:
		description = description  + "\nResources generation %+d" % construction.resources_increase_speed
	if construction.population:
		description = description  + "\nPopulation %+d" % construction.population
	if construction.unlocks_era:
		description = description  + "\nUnlocks: %s" % era_names[construction.unlocks_era]

	if construction.population_required > Global.population:
		description = description  + "\nPopulation required: %d" % construction.population_required
	elif construction.points_cost > Global.points or construction.resources_cost > Global.resources:
		description = description  + "\nNot enough points/resources"

	return description


func apply_era_effects():
	environment.fog_depth_end = era_effects[era].fog_depth
	sunlight.light_color = Color(era_effects[era].sunlight_color)
	moonlight.light_color = Color(era_effects[era].moonlight_color)


func construction_added(construction):
	# update stats
	points = points - construction.points_cost
	resources = resources - construction.resources_cost
	
	population = population + construction.population
	
	# check if unlocking new era (do not unlock twice)
	if construction.unlocks_era and self.era < construction.unlocks_era:
		player.stream = audio_levelup
		player.play()

		self.era = construction.unlocks_era
		apply_era_effects()
		
		# win condition: unlocking ERA_WIN_GAME
		if self.era == ERA_WIN_GAME:
			win_game()
	else:
		player.stream = audio_place
		player.play()
	
	gui.update_stats_panel()
	gui.update_constructions_panel()


func construction_removed(construction):
	# update stats
	population = population - construction.population
	gui.update_stats_panel()
	gui.update_constructions_panel()


func can_acquire_construction(construction):
	# check if conditions to add a new construction are met,
	# like resources and points cost
	if game_over:
		return false
		
	return 	era >= construction.era and\
			points >= construction.points_cost and\
			resources >= construction.resources_cost and\
			population >= construction.population_required


func set_graphics_detail_level(level):
	graphics_detail_level = level
	
	# level: 0, 1 or 2 (low, medium or high)
	if level == 0:
		sunlight.shadow_enabled = false
		ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 2048)
		ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0) # Disabled
		environment.ssao_enabled = false
		environment.glow_enabled = false
	elif level == 1:
		sunlight.shadow_enabled = true
		ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 4096)
		ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1) # PCF5
		environment.ssao_enabled = true
		environment.ssao_quality = Environment.SSAO_QUALITY_LOW
		environment.glow_enabled = true
		environment.glow_bicubic_upscale = false
	elif level == 2:
		sunlight.shadow_enabled = true
		ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 8192)
		ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 2) # PCF13
		environment.ssao_enabled = true
		environment.ssao_quality = Environment.SSAO_QUALITY_HIGH
		environment.glow_enabled = true
		environment.glow_bicubic_upscale = true



# Some helper funcs:

# from https://www.reddit.com/r/godot/comments/8ft84k/get_clicked_object_in_3d/
# cast a ray from camera at mouse position, and get the object colliding with the ray
func get_object_under_mouse():
	var RAY_LENGTH = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = camera.get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	return selection

func delete_children(node):
	var n
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()