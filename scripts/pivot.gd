extends Spatial

# NOTE: The pivot x and z coords should not be 0. At least they should be 0.001,
# because if not, it will not align correctly when using the look_at function.

# Can replace constructions?
const CAN_REPLACE = true

# the assigned construction, if any
var construction = null

# the construction Node (MeshInstance or PackedScene instance)
var _construction_node = null

func _ready():
	# Listen to input object_clicked signal
	var input = get_tree().get_root().get_node("Spatial/input")
	input.connect("object_clicked", self, "_on_object_clicked")


func _on_object_clicked(collider, construction):
	if Global.game_over:
		return
	
	if collider == self:
		# "construction" is only passed when drag'n drop. Else, use the selected one
		if construction == null:
			if Global.gui.selected_construction_item != null:
				try_put_construction(Global.gui.selected_construction_item)
		else:
			try_put_construction(construction)


func try_put_construction(construction):
	# try to add construction in pivot
	if Global.game_over:
		return
	
	# check if can acquire this construction (points, resources...)
	if not Global.can_acquire_construction(construction):
		Global.player.stream = Global.audio_denied
		Global.player.play()
		return

	# check if it is replacing a previous construction, and in that case
	# remove that.
	# Check also if replacement is allowed.
	var replacing = false
	if self.construction != null:
		if	CAN_REPLACE and\
				(not Global.REPLACE_ONLY_PAST_ERA_CONSTRUCTIONS or\
				self.construction.era < construction.era):
			self.remove_construction()
			replacing = true
		else:
			Global.player.stream = Global.audio_denied
			Global.player.play()
			return

	if Global.construction_count >= Global.max_constructions and not replacing:
		Global.player.stream = Global.audio_denied
		Global.player.play()
		return

	self.construction = construction

	# remove the pivot mesh
	if $CollisionShape/pivot != null:
		$CollisionShape/pivot.queue_free()
	
	# put construction mesh in pivot position, and align to glove surface
	var node
	if construction.mesh is Mesh:
		node = MeshInstance.new()
		node.mesh = construction.mesh
	elif construction.mesh is PackedScene:
		node = construction.mesh.instance()
	add_child(node)
	
	# Align to globe surface
	node.look_at(Global.globe.to_global(Vector3(0, 0, 0)) , Vector3(0, 1, 0))
	node.rotate_object_local(Vector3(1, 0, 0), deg2rad(90))
	
	# fine tune position and scale
	node.translate_object_local(Vector3(0, 1, 0) * construction.mesh_offset)
	node.scale = Vector3(1, 1, 1) * construction.mesh_scale

	self._construction_node = node
	
	# destroy near nature
	for o in Global.globe.get_node("Nature").get_children():
		if (o.to_global(Vector3(0, 0, 0)) - to_global(Vector3(0, 0, 0))).length() < Global.NATURE_DESTRUCTION_RADIUS:
			o.queue_free()

	
	Global.construction_added(construction)
	
	# keep construction counter
	Global.construction_count = Global.construction_count + 1


func remove_construction():
	if self.construction == null:
		return
	
	# keep construction counter
	Global.construction_count = Global.construction_count - 1
	
	Global.construction_removed(construction)
	
	# remove construction mesh
	self._construction_node.queue_free()
	self._construction_node = null
	
	self.construction = null
