extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("Usage: --script res://scripts/tools/diagnose_scene_materials.gd -- <scene_path>...")
		quit(2)
		return

	for scene_path in args:
		_diagnose_scene(String(scene_path))
	quit(0)


func _diagnose_scene(scene_path: String) -> void:
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	if packed_scene == null:
		print("%s | failed to load" % scene_path)
		return

	var root_node := packed_scene.instantiate()
	var counts := {
		"mesh_instances": 0,
		"surfaces": 0,
		"materials": 0,
		"albedo_textures": 0,
		"nonwhite_materials": 0,
	}
	_walk(root_node, counts)
	print("%s | meshes=%d surfaces=%d materials=%d albedo_tex=%d nonwhite=%d" % [
		scene_path,
		counts["mesh_instances"],
		counts["surfaces"],
		counts["materials"],
		counts["albedo_textures"],
		counts["nonwhite_materials"],
	])
	_print_materials(root_node)
	root_node.free()


func _walk(node: Node, counts: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		counts["mesh_instances"] += 1
		var mesh := mesh_instance.mesh
		if mesh != null:
			for surface_index in range(mesh.get_surface_count()):
				counts["surfaces"] += 1
				var material := mesh_instance.get_surface_override_material(surface_index)
				if material == null:
					material = mesh.surface_get_material(surface_index)
				_count_material(material, counts)

	for child in node.get_children():
		_walk(child, counts)


func _count_material(material: Material, counts: Dictionary) -> void:
	if material == null:
		return
	counts["materials"] += 1
	if material is StandardMaterial3D:
		var standard := material as StandardMaterial3D
		if standard.albedo_texture != null:
			counts["albedo_textures"] += 1
		var color := standard.albedo_color
		var delta := absf(color.r - 1.0) + absf(color.g - 1.0) + absf(color.b - 1.0)
		if delta > 0.05:
			counts["nonwhite_materials"] += 1


func _print_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var mesh := mesh_instance.mesh
		if mesh != null:
			for surface_index in range(mesh.get_surface_count()):
				var material := mesh_instance.get_surface_override_material(surface_index)
				if material == null:
					material = mesh.surface_get_material(surface_index)
				var material_name := "<none>" if material == null else material.resource_name
				var color := Color.WHITE
				var has_texture := false
				if material is StandardMaterial3D:
					var standard := material as StandardMaterial3D
					color = standard.albedo_color
					has_texture = standard.albedo_texture != null
				print("  %s surface=%d material=%s color=%s texture=%s" % [
					mesh_instance.name,
					surface_index,
					material_name,
					color,
					has_texture,
				])
	for child in node.get_children():
		_print_materials(child)
