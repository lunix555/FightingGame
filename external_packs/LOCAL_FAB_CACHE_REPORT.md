# Local Fab Cache Report

The local Fab cache currently contains several potentially useful assets, but the usable character and animation content is stored as Unreal `.uasset` files. Godot cannot import `.uasset` directly.

## Usable After Unreal Export

- `Stylized Female Character / Vexa`
  - Has a stylized full-proportion female character.
  - Cache lists idle, dash, jump, sword attack, sword slash, damage and death animation assets.
  - Exported through the local Unreal install and imported into `res://assets/characters/vexa/`.

- `CiciToon Hayakawa`
  - Has an anime cel-shaded character, textures and several idle/pose animation assets.
  - The visible animation set is not fighting-focused.
  - Needs Unreal export to FBX/PNG before Godot import.

- `Combat Magic Animations`
  - Animation pack with fireball charge, fireball spell, magic defend, unarmed attacks, dash, jump, walk, jog, hit reactions and death assets.
  - Animation pack only. Needs Unreal export and retargeting.

- `RamsterZ Free Anims Volume 1`
  - Animation pack with hand-to-hand idle, kicks, punch combos and paired attacks.
  - Animation pack only. Needs Unreal export and retargeting.

## Current Tooling

This machine has a runnable local Unreal Editor, so Unreal `.uasset` packs can be exported before Godot import.
Use `scripts/tools/unreal_export_vexa.py` as the reference exporter: export the selected SkeletalMesh, AnimSequence and textures into `external_packs/incoming/<slug>/`, then run `scripts/tools/prepare_external_character_pack.ps1` to convert them into runtime `res://assets/characters/<slug>/` assets.

Do not reference the Fab cache or other developer-machine absolute paths from runtime Godot resources.
