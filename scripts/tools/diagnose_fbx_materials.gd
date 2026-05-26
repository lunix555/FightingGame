extends SceneTree

const FBX_SCENES := [
	"res://assets/fbx_anim/Idle_Anim1.FBX",
	"res://assets/fbx_anim/Cross_Punch_Anim1.FBX",
	"res://assets/fbx_anim/Mma_Kick_Anim1.FBX",
	"res://assets/fbx_anim/Jump_Anim1.FBX",
	"res://assets/fbx_anim/Fast_Run_Anim.FBX",
	"res://assets/fbx_anim/Fast_Run__1__Anim1.FBX",
]


func _init() -> void:
	for path in FBX_SCENES:
		_diagnose(path)
	quit()


func _diagnose(path: String) -> void:
	var packed_scene := ResourceLoader.load(path) as PackedScene
	if packed_scene == null:
		print("%s | failed to load" % path)
		return

	var root := packed_scene.instantiate()
	var counts := {
		"mesh_instances": 0,
		"surface_slots": 0,
		"materials": 0,
		"albedo_textures": 0,
		"normal_textures": 0,
		"orm_textures": 0,
		"animation_players": 0,
		"animations": 0,
	}
	_walk(root, counts)

	print("%s | meshes=%d surfaces=%d materials=%d albedo_tex=%d normal_tex=%d orm_tex=%d anim_players=%d animations=%d" % [
		path.get_file(),
		counts["mesh_instances"],
		counts["surface_slots"],
		counts["materials"],
		counts["albedo_textures"],
		counts["normal_textures"],
		counts["orm_textures"],
		counts["animation_players"],
		counts["animations"],
	])
	_print_materials(root)
	root.free()


func _walk(node: Node, counts: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		counts["mesh_instances"] += 1
		var mesh := mesh_instance.mesh
		if mesh != null:
			for surface_index in range(mesh.get_surface_count()):
				counts["surface_slots"] += 1
				var material := mesh.surface_get_material(surface_index)
				if material == null:
					material = mesh_instance.get_surface_override_material(surface_index)
				if material != null:
					_count_material(material, counts)

	if node is AnimationPlayer:
		var player := node as AnimationPlayer
		counts["animation_players"] += 1
		counts["animations"] += player.get_animation_list().size()

	for child in node.get_children():
		_walk(child, counts)


func _count_material(material: Material, counts: Dictionary) -> void:
	counts["materials"] += 1
	if material is StandardMaterial3D:
		var standard := material as StandardMaterial3D
		if standard.albedo_texture != null:
			counts["albedo_textures"] += 1
		if standard.normal_texture != null:
			counts["normal_textures"] += 1
		if standard.orm_texture != null:
			counts["orm_textures"] += 1


func _print_materials(root: Node) -> void:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D:
			var mesh_instance := node as MeshInstance3D
			var mesh := mesh_instance.mesh
			if mesh != null:
				for surface_index in range(mesh.get_surface_count()):
					var material := mesh.surface_get_material(surface_index)
					if material == null:
						material = mesh_instance.get_surface_override_material(surface_index)
					var material_name := "<none>" if material == null else material.resource_name
					var color := Color.WHITE
					if material is StandardMaterial3D:
						color = (material as StandardMaterial3D).albedo_color
					print("  surface %d material=%s color=%s" % [surface_index, material_name, color])
		for child in node.get_children():
			stack.append(child)
