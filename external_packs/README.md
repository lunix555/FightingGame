# External Character Pack Intake

This folder is for character packs downloaded from Fab, Unity Asset Store, itch.io, or other stores.

Do not commit raw store downloads. Put them under:

```text
external_packs/incoming/<character_slug>/
```

Then use the importer helper to copy and convert the final runtime files into:

```text
assets/characters/<character_slug>/
```

## Required runtime files

For a fighting-game-ready character, prepare at least:

- One rigged base model: `.glb` preferred, `.fbx` accepted if `tools/fbx2gltf` is available locally.
- Idle animation.
- Run animation.
- Punch or slash animation.
- Kick or second attack animation.
- Jump animation if available.
- Texture files: body, head, eye, hair, outfit, or a smaller set if the model uses fewer materials.

Unreal-only `.uasset` files cannot be consumed by Godot directly. Export them from Unreal Editor as FBX/PNG first. Unity `.unitypackage` files should be unpacked or imported into Unity, then export or copy the source FBX/GLB and textures.

## Import example

```powershell
.\scripts\tools\prepare_external_character_pack.ps1 `
  -Slug akira `
  -Name "Akira" `
  -SourceDir external_packs\incoming\akira `
  -Base Character.fbx `
  -Idle Animations\Idle.fbx `
  -Run Animations\Run.fbx `
  -Punch Animations\Punch.fbx `
  -Kick Animations\Kick.fbx `
  -Jump Animations\Jump.fbx `
  -AnimationName "Unreal Take" `
  -TextureMap @{
    body = "Textures\Body.png"
    head = "Textures\Head.png"
    eye = "Textures\Eyes.png"
    hair = "Textures\Hair.png"
    outfit = "Textures\Outfit.png"
  }
```

The helper writes a roster snippet to `external_packs/generated/<slug>_roster_snippet.gd`. Review that snippet, paste it into `CHARACTER_ROSTER`, then run Godot import and validation.

## Validation

```powershell
& $env:GODOT_BIN --headless --editor --path . --quit
& $env:GODOT_BIN --headless --path . --check-only --script res://scripts/fighting/fighting_game_test.gd
```

For a single animation scene:

```powershell
& $env:GODOT_BIN --headless --path . --script res://scripts/tools/validate_character_visual.gd -- res://assets/characters/<slug>/animations/<clip>.glb "Unreal Take"
```

## Unreal Retarget Helper

`scripts/tools/unreal_retarget_root1.py` imports a target FBX, builds temporary IK Rig/Retargeter assets in the Unreal export project, retargets the selected CombatMagic animation clips, and exports FBX files back to `external_packs/incoming/root1_retargeted/`.

Set `ROOT1_FBX` before launching Unreal if the target FBX is not already staged at `external_packs/incoming/root1_source/root1.fbx`.
