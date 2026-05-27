import os
import shutil
import traceback
import unreal


REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ACTION_LIBRARY_ROOT = os.environ.get(
    "ACTION_LIBRARY_ROOT",
    os.path.join(REPO_ROOT, "external_packs", "incoming", "action_library_source"),
)
OUTPUT_ROOT = os.path.join(REPO_ROOT, "external_packs", "incoming", "action_library_retargeted")
UE_ROOT = "/Game/Imported/ActionLibrary"


CHARACTERS = {
    "kashandella_qishi": {
        "display": "Kashandella Knight",
        "model": "kashandella_qishi.fbx",
        "animation_files": {
            "idle": "huxi.fbx",
            "walk": "zou.fbx",
            "run": "pao.fbx",
            "punch": "AS_FireballSpell.FBX",
            "kick": "AS_GroundManaShot.FBX",
            "jump": "Jump.fbx",
            "crouch": "Idle Crouching.fbx",
            "crouch_enter": "Standing To Crouched.fbx",
            "crouch_exit": "Standing.fbx",
            "crouch_kick": "CrouchingKick.fbx",
            "crouch_punch": "CrouchingPunch.fbx",
            "hurricane_kick": "Hurricane Kick.fbx",
            "hit": "Head Hit.fbx",
            "crouch_hit": "CrouchHit.fbx",
            "cast_spell": "AS_CastSpell.FBX",
            "ground_mana_shot": "AS_GroundManaShot.FBX",
            "levitating_fireball_cast": "AS_LevitatingFireballCast.FBX",
            "mana_cast_shot": "AS_ManaCastShot.FBX",
            "fireball_spell": "AS_FireballSpell.FBX",
        },
    },
    "wela_fashi": {
        "display": "Wela Mage",
        "model": "wela_fashi.fbx",
        "animation_files": {
            "idle": "huxi.fbx",
            "walk": "zou.fbx",
            "run": "pao.fbx",
            "punch": "AS_MagicStrike2.FBX",
            "kick": "AS_StaffBlast+Fireball.FBX",
            "jump": "Jump.fbx",
            "crouch": "Idle Crouching.fbx",
            "crouch_enter": "Standing To Crouched.fbx",
            "crouch_exit": "Standing.fbx",
            "crouch_kick": "CrouchingKick.fbx",
            "crouch_punch": "CrouchingPunch.fbx",
            "hurricane_kick": "Hurricane Kick.fbx",
            "hit": "Head Hit.fbx",
            "crouch_hit": "CrouchHit.fbx",
            "levitating_magic_strike": "AS_LevitatingMagicStrike_.FBX",
            "magic_strike": "AS_MagicStrike2.FBX",
            "revelation": "AS_Revelation.FBX",
            "staff_blast_fireball": "AS_StaffBlast+Fireball.FBX",
            "inverted_spin_kick": "shoujidaodi.fbx",
            "dual_energy_blast": "AS_DualEnergyBlas.FBX",
            "fireball_charge": "AS_FireballCharge.FBX",
        },
    },
}


def log(message):
    unreal.log("ACTION_LIBRARY {}".format(message))


def ensure_dir(path):
    os.makedirs(path, exist_ok=True)


def ensure_ue_dir(path):
    if not unreal.EditorAssetLibrary.does_directory_exist(path):
        unreal.EditorAssetLibrary.make_directory(path)


def clean_ue_dir(path):
    if unreal.EditorAssetLibrary.does_directory_exist(path):
        unreal.EditorAssetLibrary.delete_directory(path)
    unreal.EditorAssetLibrary.make_directory(path)


def clean_disk_dir(path):
    if os.path.isdir(path):
        shutil.rmtree(path)
    os.makedirs(path, exist_ok=True)


def find_source_file(filename):
    target = filename.lower()
    matches = []
    for root, _dirs, files in os.walk(ACTION_LIBRARY_ROOT):
        for file_name in files:
            if file_name.lower() == target:
                matches.append(os.path.join(root, file_name))
    if not matches:
        raise RuntimeError("Missing source FBX named: {}".format(filename))
    matches.sort()
    return matches[0]


def first_asset_of_type(folder, cls):
    registry = unreal.AssetRegistryHelpers.get_asset_registry()
    assets = registry.get_assets_by_path(folder, recursive=True)
    for data in assets:
        asset = data.get_asset()
        if isinstance(asset, cls):
            return asset
    return None


def import_skeletal_mesh(slug, fbx_path):
    if not os.path.exists(fbx_path):
        raise RuntimeError("Missing model FBX: {}".format(fbx_path))
    mesh_dir = "{}/{}/Model".format(UE_ROOT, slug)
    clean_ue_dir(mesh_dir)

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
    task.filename = fbx_path
    task.destination_path = mesh_dir
    task.destination_name = slug
    task.automated = True
    task.save = True
    task.replace_existing = True
    task.options = options
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
    log("{} imported model objects: {}".format(slug, ", ".join(task.imported_object_paths)))

    mesh = first_asset_of_type(mesh_dir, unreal.SkeletalMesh)
    if mesh is None:
        raise RuntimeError("{} import did not produce a SkeletalMesh".format(slug))
    return mesh


def get_skeleton(mesh):
    skeleton = mesh.get_editor_property("skeleton")
    if skeleton is None:
        raise RuntimeError("SkeletalMesh has no skeleton: {}".format(mesh.get_path_name()))
    return skeleton


def import_animation(slug, slot, fbx_path, skeleton):
    if not os.path.exists(fbx_path):
        raise RuntimeError("Missing animation FBX: {}".format(fbx_path))
    anim_dir = "{}/{}/Animations".format(UE_ROOT, slug)
    ensure_ue_dir(anim_dir)

    options = unreal.FbxImportUI()
    options.import_as_skeletal = True
    options.import_mesh = False
    options.import_animations = True
    options.import_materials = False
    options.import_textures = False
    options.skeleton = skeleton
    options.override_animation_name = "{}_{}".format(slug, slot)
    try:
        options.mesh_type_to_import = unreal.FBXImportType.FBXIT_ANIMATION
    except Exception:
        pass

    task = unreal.AssetImportTask()
    task.filename = fbx_path
    task.destination_path = anim_dir
    task.destination_name = "{}_{}".format(slug, slot)
    task.automated = True
    task.save = True
    task.replace_existing = True
    task.options = options
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks([task])
    log("{} imported {} objects: {}".format(slug, slot, ", ".join(task.imported_object_paths)))

    target_name = "{}_{}".format(slug, slot)
    for path in task.imported_object_paths:
        asset = unreal.EditorAssetLibrary.load_asset(path)
        if isinstance(asset, unreal.AnimSequence):
            return asset
    asset = unreal.EditorAssetLibrary.load_asset("{}/{}".format(anim_dir, target_name))
    if isinstance(asset, unreal.AnimSequence):
        return asset
    asset = first_asset_of_type(anim_dir, unreal.AnimSequence)
    if asset is None:
        raise RuntimeError("{} {} import did not produce an AnimSequence".format(slug, slot))
    return asset


def fbx_options():
    options = unreal.FbxExportOption()
    options.ascii = False
    options.collision = False
    options.level_of_detail = False
    options.force_front_x_axis = True
    options.export_preview_mesh = False
    return options


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


def export_character(slug, mesh, animations):
    out_dir = os.path.join(OUTPUT_ROOT, slug)
    anim_out_dir = os.path.join(out_dir, "animations")
    clean_disk_dir(out_dir)
    ensure_dir(anim_out_dir)
    export_asset(
        mesh,
        os.path.join(out_dir, "{}_base.fbx".format(slug)),
        unreal.SkeletalMeshExporterFBX(),
        fbx_options(),
    )
    for slot, anim in animations.items():
        export_asset(
            anim,
            os.path.join(anim_out_dir, "{}.fbx".format(slot)),
            unreal.AnimSequenceExporterFBX(),
            fbx_options(),
        )


def import_and_export_character(slug, config):
    mesh_path = os.path.join(ACTION_LIBRARY_ROOT, config["model"])
    mesh = import_skeletal_mesh(slug, mesh_path)
    skeleton = get_skeleton(mesh)
    animations = {}
    for slot, filename in config["animation_files"].items():
        source_path = find_source_file(filename)
        log("{} uses {} -> {}".format(slug, slot, source_path))
        animations[slot] = import_animation(slug, slot, source_path, skeleton)
    export_character(slug, mesh, animations)


def main():
    if not os.path.isdir(ACTION_LIBRARY_ROOT):
        raise RuntimeError("Missing action library root: {}".format(ACTION_LIBRARY_ROOT))
    ensure_ue_dir(UE_ROOT)
    ensure_dir(OUTPUT_ROOT)
    for slug, config in CHARACTERS.items():
        log("Processing {} ({})".format(slug, config["display"]))
        import_and_export_character(slug, config)
    log("Complete: {}".format(OUTPUT_ROOT))


try:
    main()
except Exception as exc:
    unreal.log_error("ACTION_LIBRARY failed: {}\n{}".format(exc, traceback.format_exc()))
    raise
finally:
    unreal.SystemLibrary.quit_editor()
