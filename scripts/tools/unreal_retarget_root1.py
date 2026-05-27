import os
import traceback
import unreal


REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ROOT1_FBX = os.environ.get(
    "ROOT1_FBX",
    os.path.join(REPO_ROOT, "external_packs", "incoming", "root1_source", "root1.fbx"),
)
OUTPUT_ROOT = os.path.join(REPO_ROOT, "external_packs", "incoming", "root1_retargeted")

UE_IMPORT_DIR = "/Game/Imported/Root1"
UE_RETARGET_DIR = "/Game/Imported/Root1Retarget"
SOURCE_MESH_PATH = "/Game/CombatMagicAnims/Demo/Mannequins/Meshes/SKM_Manny_Simple"
SOURCE_ANIMS = {
    "idle": "/Game/CombatMagicAnims/Demo/Mannequins/Anims/Unarmed/MM_Idle",
    "run": "/Game/CombatMagicAnims/Demo/Mannequins/Anims/Unarmed/Jog/MF_Unarmed_Jog_Fwd",
    "punch": "/Game/CombatMagicAnims/Demo/Mannequins/Anims/Unarmed/Attack/MM_Attack_01",
    "kick": "/Game/CombatMagicAnims/Demo/Mannequins/Anims/Unarmed/Attack/MM_Attack_02",
    "jump": "/Game/CombatMagicAnims/Demo/Mannequins/Anims/Unarmed/Jump/MM_Jump",
}


def log(message):
    unreal.log("ROOT1_RETARGET {}".format(message))


def ensure_dir(path):
    os.makedirs(path, exist_ok=True)


def ensure_ue_dir(path):
    if not unreal.EditorAssetLibrary.does_directory_exist(path):
        unreal.EditorAssetLibrary.make_directory(path)


def load_asset(path, expected_type=None):
    asset = unreal.EditorAssetLibrary.load_asset(path)
    if asset is None:
        raise RuntimeError("Missing Unreal asset: {}".format(path))
    if expected_type is not None and not isinstance(asset, expected_type):
        raise RuntimeError("Unexpected asset type for {}: {}".format(path, type(asset)))
    return asset


def first_asset_of_type(folder, cls):
    registry = unreal.AssetRegistryHelpers.get_asset_registry()
    assets = registry.get_assets_by_path(folder, recursive=True)
    for data in assets:
        asset = data.get_asset()
        if isinstance(asset, cls):
            return asset
    return None


def import_root1_mesh():
    ensure_ue_dir(UE_IMPORT_DIR)
    existing = first_asset_of_type(UE_IMPORT_DIR, unreal.SkeletalMesh)
    if existing is not None:
        log("Using existing imported root1 mesh: {}".format(existing.get_path_name()))
        return existing

    if not os.path.exists(ROOT1_FBX):
        raise RuntimeError("Missing root1 FBX: {}".format(ROOT1_FBX))

    options = unreal.FbxImportUI()
    options.import_as_skeletal = True
    options.import_mesh = True
    options.import_animations = False
    options.import_materials = True
    options.import_textures = True
    options.create_physics_asset = False
    try:
        options.mesh_type_to_import = unreal.FBXImportType.FBXIT_SKELETAL_MESH
    except Exception:
        pass

    task = unreal.AssetImportTask()
    task.filename = ROOT1_FBX
    task.destination_path = UE_IMPORT_DIR
    task.destination_name = "root1"
    task.automated = True
    task.save = True
    task.replace_existing = True
    task.options = options

    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
    if task.imported_object_paths:
        log("Imported root1 objects: {}".format(", ".join(task.imported_object_paths)))

    mesh = first_asset_of_type(UE_IMPORT_DIR, unreal.SkeletalMesh)
    if mesh is None:
        raise RuntimeError("root1 import did not produce a SkeletalMesh")
    return mesh


def create_or_load_ik_rig(asset_name, mesh):
    ensure_ue_dir(UE_RETARGET_DIR)
    path = "{}/{}".format(UE_RETARGET_DIR, asset_name)
    existing = unreal.EditorAssetLibrary.load_asset(path)
    if isinstance(existing, unreal.IKRigDefinition):
        rig = existing
    else:
        rig = unreal.IKRigDefinitionFactory.create_new_ik_rig_asset(UE_RETARGET_DIR, asset_name)
        if rig is None:
            rig = unreal.AssetToolsHelpers.get_asset_tools().create_asset(
                asset_name,
                UE_RETARGET_DIR,
                unreal.IKRigDefinition,
                None,
            )
    controller = unreal.IKRigController.get_controller(rig)
    controller.set_skeletal_mesh(mesh)
    try:
        controller.apply_auto_generated_retarget_definition()
    except Exception as exc:
        log("Auto retarget definition skipped for {}: {}".format(asset_name, exc))
        add_basic_chains(controller)
    unreal.EditorAssetLibrary.save_loaded_asset(rig)
    return rig


def add_chain_safe(controller, name, start, end):
    try:
        if name in [str(x) for x in controller.get_retarget_chains()]:
            return
    except Exception:
        pass
    try:
        controller.add_retarget_chain(name, start, end, "")
    except Exception:
        try:
            controller.add_retarget_chain(name)
            controller.set_retarget_chain_start_bone(name, start)
            controller.set_retarget_chain_end_bone(name, end)
        except Exception as exc:
            log("Failed chain {} {}->{}: {}".format(name, start, end, exc))


def add_basic_chains(controller):
    skeleton_bones = []
    try:
        mesh = controller.get_skeletal_mesh()
        skeleton = mesh.get_editor_property("skeleton")
        ref = skeleton.get_reference_pose()
        skeleton_bones = [str(bone.name).lower() for bone in ref]
    except Exception:
        pass

    def has(name):
        return name.lower() in skeleton_bones

    root = "pelvis" if has("pelvis") else "root"
    try:
        controller.set_retarget_root(root)
    except Exception:
        pass
    for name, start, end in [
        ("Spine", "spine_01", "neck_01"),
        ("Head", "neck_01", "head"),
        ("LeftArm", "upperarm_l", "hand_l"),
        ("RightArm", "upperarm_r", "hand_r"),
        ("LeftLeg", "thigh_l", "ball_l"),
        ("RightLeg", "thigh_r", "ball_r"),
    ]:
        if has(start) and has(end):
            add_chain_safe(controller, name, start, end)


def retarget_enum(name):
    enum = unreal.RetargetSourceOrTarget
    for candidate in [name, name.upper(), name.capitalize()]:
        if hasattr(enum, candidate):
            return getattr(enum, candidate)
    raise RuntimeError("Missing RetargetSourceOrTarget.{}".format(name))


def create_or_load_retargeter(source_rig, target_rig, source_mesh, target_mesh):
    ensure_ue_dir(UE_RETARGET_DIR)
    asset_name = "RTG_CombatMagic_to_root1"
    path = "{}/{}".format(UE_RETARGET_DIR, asset_name)
    retargeter = unreal.EditorAssetLibrary.load_asset(path)
    if not isinstance(retargeter, unreal.IKRetargeter):
        factory = unreal.IKRetargetFactory()
        retargeter = unreal.AssetToolsHelpers.get_asset_tools().create_asset(
            asset_name,
            UE_RETARGET_DIR,
            unreal.IKRetargeter,
            factory,
        )
    controller = unreal.IKRetargeterController.get_controller(retargeter)
    source_enum = retarget_enum("SOURCE")
    target_enum = retarget_enum("TARGET")
    controller.set_ik_rig(source_enum, source_rig)
    controller.set_ik_rig(target_enum, target_rig)
    controller.set_preview_mesh(source_enum, source_mesh)
    controller.set_preview_mesh(target_enum, target_mesh)
    try:
        controller.add_default_ops()
    except Exception as exc:
        log("add_default_ops skipped: {}".format(exc))
    try:
        controller.auto_map_chains(unreal.AutoMapChainType.FUZZY, True)
    except Exception as exc:
        log("auto_map_chains skipped: {}".format(exc))
    unreal.EditorAssetLibrary.save_loaded_asset(retargeter)
    return retargeter


def asset_data(path):
    data = unreal.EditorAssetLibrary.find_asset_data(path)
    if not data.is_valid():
        raise RuntimeError("Missing asset data: {}".format(path))
    return data


def run_batch_retarget(retargeter, source_mesh, target_mesh):
    ensure_ue_dir("{}/Output".format(UE_RETARGET_DIR))
    inputs = unreal.IKRetargetBatchOperationInputs()
    inputs.assets_to_retarget = [asset_data(path) for path in SOURCE_ANIMS.values()]
    inputs.source_mesh = source_mesh
    inputs.target_mesh = target_mesh
    inputs.ik_retarget_asset = retargeter
    inputs.target_path = "{}/Output".format(UE_RETARGET_DIR)
    inputs.prefix = "root1_"
    inputs.use_source_path = False
    inputs.include_referenced_assets = False
    inputs.overwrite_existing_files = True
    result = unreal.IKRetargetBatchOperation.run_batch_retarget(inputs)
    log("Batch retarget result count: {}".format(len(result)))
    return [data.get_asset() for data in result]


def export_asset(asset, filename, exporter, options=None):
    task = unreal.AssetExportTask()
    task.object = asset
    task.filename = filename
    task.automated = True
    task.prompt = False
    task.replace_identical = True
    task.exporter = exporter
    if options is not None:
        task.options = options
    ok = unreal.Exporter.run_asset_export_task(task)
    if not ok:
        raise RuntimeError("Export failed: {}".format(filename))
    log("Exported {}".format(filename))


def fbx_options():
    options = unreal.FbxExportOption()
    options.ascii = False
    options.collision = False
    options.level_of_detail = False
    options.force_front_x_axis = True
    options.export_preview_mesh = False
    return options


def export_results(target_mesh, retargeted_assets):
    ensure_dir(OUTPUT_ROOT)
    ensure_dir(os.path.join(OUTPUT_ROOT, "animations"))
    export_asset(
        target_mesh,
        os.path.join(OUTPUT_ROOT, "root1_base.fbx"),
        unreal.SkeletalMeshExporterFBX(),
        fbx_options(),
    )

    by_name = {asset.get_name(): asset for asset in retargeted_assets if isinstance(asset, unreal.AnimSequence)}
    for slot, source_path in SOURCE_ANIMS.items():
        source_name = source_path.rsplit("/", 1)[-1]
        candidates = [
            "root1_{}".format(source_name),
            source_name,
        ]
        asset = None
        for candidate in candidates:
            if candidate in by_name:
                asset = by_name[candidate]
                break
        if asset is None:
            output_asset = unreal.EditorAssetLibrary.load_asset("{}/Output/root1_{}".format(UE_RETARGET_DIR, source_name))
            if isinstance(output_asset, unreal.AnimSequence):
                asset = output_asset
        if asset is None:
            raise RuntimeError("Missing retargeted animation for {} ({})".format(slot, source_name))
        export_asset(
            asset,
            os.path.join(OUTPUT_ROOT, "animations", "{}.fbx".format(slot)),
            unreal.AnimSequenceExporterFBX(),
            fbx_options(),
        )


def main():
    target_mesh = import_root1_mesh()
    source_mesh = load_asset(SOURCE_MESH_PATH, unreal.SkeletalMesh)
    source_rig = create_or_load_ik_rig("IK_CombatMagic_Manny", source_mesh)
    target_rig = create_or_load_ik_rig("IK_root1", target_mesh)
    retargeter = create_or_load_retargeter(source_rig, target_rig, source_mesh, target_mesh)
    retargeted = run_batch_retarget(retargeter, source_mesh, target_mesh)
    export_results(target_mesh, retargeted)
    log("Complete: {}".format(OUTPUT_ROOT))


try:
    main()
except Exception as exc:
    unreal.log_error("ROOT1_RETARGET failed: {}\n{}".format(exc, traceback.format_exc()))
    raise
finally:
    unreal.SystemLibrary.quit_editor()
