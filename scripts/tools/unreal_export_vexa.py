import os
import unreal


REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUTPUT_ROOT = os.path.join(REPO_ROOT, "external_packs", "incoming", "vexa")

ASSETS = {
    "base": "/Game/Vefects/Stylized_Female_Character_Vexa/SK/Vefects_Vexa",
    "animations": {
        "idle": "/Game/Vefects/Stylized_Female_Character_Vexa/Animations/Idle_Vexa",
        "run": "/Game/Vefects/Stylized_Female_Character_Vexa/Animations/Dash_Vexa",
        "punch": "/Game/Vefects/Stylized_Female_Character_Vexa/Animations/SwordAttack_Vexa",
        "kick": "/Game/Vefects/Stylized_Female_Character_Vexa/Animations/SwordSlash_Vexa",
        "jump": "/Game/Vefects/Stylized_Female_Character_Vexa/Animations/Jump01_Vexa",
    },
    "textures": {
        "body": "/Game/Vefects/Stylized_Female_Character_Vexa/Textures/Body/Vexa_Body_Base_Color",
        "hair": "/Game/Vefects/Stylized_Female_Character_Vexa/Textures/Hair/Vexa_Hair_Base_Color",
        "outfit": "/Game/Vefects/Stylized_Female_Character_Vexa/Textures/Jacket/Vexa_Jacket_Base_Color",
    },
}


def ensure_dir(path):
    os.makedirs(path, exist_ok=True)


def load_asset(path):
    asset = unreal.EditorAssetLibrary.load_asset(path)
    if asset is None:
        raise RuntimeError("Missing Unreal asset: {}".format(path))
    return asset


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
    unreal.log("Exported {}".format(filename))


def fbx_options():
    options = unreal.FbxExportOption()
    options.ascii = False
    options.collision = False
    options.level_of_detail = False
    return options


def main():
    ensure_dir(OUTPUT_ROOT)
    ensure_dir(os.path.join(OUTPUT_ROOT, "animations"))
    ensure_dir(os.path.join(OUTPUT_ROOT, "textures"))

    base = load_asset(ASSETS["base"])
    export_asset(
        base,
        os.path.join(OUTPUT_ROOT, "vexa_base.fbx"),
        unreal.SkeletalMeshExporterFBX(),
        fbx_options(),
    )

    for slot, path in ASSETS["animations"].items():
        animation = load_asset(path)
        export_asset(
            animation,
            os.path.join(OUTPUT_ROOT, "animations", "{}.fbx".format(slot)),
            unreal.AnimSequenceExporterFBX(),
            fbx_options(),
        )

    for slot, path in ASSETS["textures"].items():
        texture = load_asset(path)
        export_asset(
            texture,
            os.path.join(OUTPUT_ROOT, "textures", "{}.png".format(slot)),
            unreal.TextureExporterPNG(),
        )

    unreal.log("Vexa export complete: {}".format(OUTPUT_ROOT))


try:
    main()
except Exception as exc:
    unreal.log_error("Vexa export failed: {}".format(exc))
    raise
finally:
    if hasattr(unreal, "SystemLibrary"):
        unreal.SystemLibrary.quit_editor()
