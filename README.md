# FightingGame

Godot 4 Web 端 3D 横版格斗游戏原型，用于验证网页端 1V1 格斗的角色模型、动作、特效、音效、UI、输入和 Docker 静态资源包流程。

## 工程信息

- 工程根目录：仓库根目录，也就是包含 `project.godot` 的目录。
- Godot 工程文件：`project.godot`
- 主场景：`res://scenes/fighting_state_machine_test.tscn`
- 主要战斗脚本：`res://scripts/fighting/fighting_game_test.gd`
- 角色控制器：`res://scripts/fighting/fighter_controller.gd`
- 招式资源：`res://data/moves/prototype/*.tres`
- Web 导出目录：`exports/web`

## 引擎环境

- 推荐引擎：Godot `4.6.2.stable`
- 渲染模式：`GL Compatibility`
- 物理引擎：`Jolt Physics`
- Web 导出预设名：`Web`

建议把 Godot 可执行文件加入 `PATH`，或者在本机设置一个环境变量：

```powershell
$env:GODOT_BIN = "你的 Godot 4.6.2 可执行文件路径"
```

检查脚本：

```powershell
& $env:GODOT_BIN --headless --path . --check-only --script res://scripts/fighting/fighting_game_test.gd
```

如果已经把 Godot 加入 `PATH`，也可以直接：

```powershell
godot --headless --path . --check-only --script res://scripts/fighting/fighting_game_test.gd
```

导出 Web：

```powershell
& $env:GODOT_BIN --headless --path . --export-release Web exports/web/index.html
```

## Docker 环境

Docker 镜像只打包 `exports/web`，不会把工程源码、FBX 源文件、下载缓存一起放进最终镜像。镜像内使用 Go 静态文件服务器托管 Godot Web 包。

构建镜像：

```powershell
docker build -t godot-fighting-web:latest .
```

本地运行：

```powershell
docker run --rm -p 8080:80 godot-fighting-web:latest
```

打开：

```text
http://127.0.0.1:8080/
```

如果使用已有测试容器 `godot-fighting-web-test`，重新导出后可以直接刷新容器内容：

```powershell
docker start godot-fighting-web-test
docker cp exports/web/. godot-fighting-web-test:/www/
```

## 资源路径规则

提交到 Git 的资源引用不要使用开发机绝对路径。代码、`.tres`、场景和文档示例里应优先使用：

- Godot 工程路径：`res://assets/...`
- 仓库相对路径：`assets/...`

不要提交 Windows 盘符路径、Unix 根目录路径或 `file` 协议路径。外部 DCC 工具导出的临时路径只允许留在本机笔记或未提交脚本里。

## 多角色资源

多角色入口在 `scripts/fighting/fighting_game_test.gd` 的 `CHARACTER_ROSTER`。每个角色可以单独配置：

- `portrait`：选人头像。
- `move_folder`：这个角色自己的招式 `.tres` 目录。
- `visual.base`：基础角色 FBX。
- `visual.animations`：动作槽到 FBX 的映射。
- `visual.textures`：材质槽到贴图的映射。

建议每个角色准备独立目录，例如：

```text
assets/characters/akame/model/Character_Base.FBX
assets/characters/akame/anim/Idle.FBX
assets/characters/akame/anim/Punch.FBX
assets/characters/akame/textures/body.png
data/moves/akame/*.tres
```

`CHARACTER_ROSTER` 示例：

```gdscript
{
	"name": "新角色",
	"style": "远程牵制",
	"color": Color(0.7, 0.9, 1.0),
	"portrait": "res://assets/characters/new_character/portrait.png",
	"move_folder": "res://data/moves/new_character",
	"visual": {
		"base": "res://assets/characters/new_character/model/Character_Base.FBX",
		"animations": {
			"idle": "res://assets/characters/new_character/anim/Idle.FBX",
			"punch": "res://assets/characters/new_character/anim/Punch.FBX",
			"kick": "res://assets/characters/new_character/anim/Kick.FBX",
			"jump": "res://assets/characters/new_character/anim/Jump.FBX",
			"run": "res://assets/characters/new_character/anim/Run.FBX",
		},
		"textures": {
			"body": "res://assets/characters/new_character/textures/body.png",
			"face": "res://assets/characters/new_character/textures/face.png",
			"face_detail": "res://assets/characters/new_character/textures/face.png",
			"eye": "res://assets/characters/new_character/textures/eye.png",
			"hair": "res://assets/characters/new_character/textures/hair.png",
			"mayu": "res://assets/characters/new_character/textures/face.png",
			"tail": "res://assets/characters/new_character/textures/tail.png",
		},
	},
}
```

没有写的字段会回退到 `DEFAULT_CHARACTER_VISUAL_PROFILE`。战斗角色和选人界面的模型预览都会读取同一份角色配置。

招式到动作槽的对应关系在 `scripts/fighting/fighter_controller.gd` 的 `MOVE_VISUALS`，例如 `anim_fireball -> punch`、`anim_heavy_kick -> kick`。新增动作槽后，需要同时扩展角色的 `visual.animations` 和 `MOVE_VISUALS`。

仓库里已放入一套通过动画检查后接入的 Dawn Mage 测试角色：

- 资源目录：`assets/characters/dawn_mage/`
- 授权说明：`assets/characters/dawn_mage/README.md`
- 当前接入角色：`Dawn Mage`
- 使用文件：`assets/characters/dawn_mage/anime_female_mage.glb`
- 已验证动画：`combat_idle_01`、`combat_run_01`、`combat_attack_01`、`combat_attack_02`、`combat_spin_up_01`、`combat_defeat_01`、`combat_get_up_01`

新角色接入前可以先跑验证脚本，确认模型内真的有要映射的动画：

```powershell
& $env:GODOT_BIN --headless --path . --script res://scripts/tools/validate_character_visual.gd -- res://assets/characters/dawn_mage/anime_female_mage.glb combat_idle_01 combat_run_01 combat_attack_01 combat_attack_02
```

## 招式、特效和飞行道具

招式数据在 `data/moves/prototype/*.tres`，每个 `.tres` 是一个 `MoveDefinition`。

常用字段：

- `motion` / `button`：搓招和按键。
- `damage` / `chip_damage` / `meter_cost`：伤害、防御削血、气消耗。
- `projectile_enabled`：是否发射飞行道具。
- `projectile_speed` / `projectile_vertical_speed` / `projectile_gravity`：飞行道具轨迹。
- `effect_style`：特效类型，例如 `fireball`、`heavy_fireball`、`slash`、`ice_pillar`。
- `effect_texture_path`：特效贴图路径，必须使用 `res://`。
- `effect_color` / `effect_impact_color`：飞行和命中特效颜色。
- `animation_key`：连接到角色动作槽。
- `vfx_key` / `sfx_key`：命中特效和音效 key。

特效贴图默认放在：

- `assets/vfx/kenney_particle_full/`
- `assets/vfx/kenney_particle_pack/`
- `assets/vfx/opengameart_spells/`

飞行道具渲染逻辑在 `scripts/fighting/fighting_projectile.gd`。如果只是换火球、冰柱、斩击贴图，优先改 `.tres` 的 `effect_texture_path`。

## 音效和 BGM

音效文件默认放在：

- `assets/audio/kenney_impact/`
- `assets/audio/kenney_combat/`
- `assets/audio/kenney_ui/`

音效 key 到文件路径的映射在 `scripts/fighting/fighting_game_test.gd` 的 `SOUND_PATHS`。最简单的替换方式是覆盖同名 `.ogg` 文件；如果新增文件名，需要把新路径加进 `SOUND_PATHS`，再在招式 `.tres` 的 `sfx_key` 里引用。

当前菜单和战斗 BGM 是代码生成的循环音频，在 `fighting_game_test.gd` 的 `_generated_bgm()` 和 `_bgm_*()` 系列函数里。浏览器 Web 端会要求第一次点击或按键后才能播放音频，项目里已经做了输入后解锁。

## UI 和地图

UI 图片路径在 `fighting_game_test.gd` 顶部的 `UI_TEX_*` 常量：

- 按钮、面板：`assets/ui/kenney_sci_fi/`
- 血条、气条、星标：`assets/ui/kenney/`

地图资源放在 `assets/backgrounds/`。地图列表在 `fighting_game_test.gd` 的 `STAGE_DEFINITIONS`，新增地图时需要补：

- `name`
- `subtitle`
- `preview`
- `root`
- `layers`

## 授权注意

仓库里的免费素材目录通常带有 `LICENSE.txt` 或 `ATTRIBUTION.txt`，提交或发布前需要保留对应授权说明。用户自带模型、贴图、动作资源需要单独确认授权，不能默认当作可商用素材。

## 常见问题

- Web 端刚打开没声音：先点击页面或按任意键，浏览器允许音频后 BGM/SFX 才会播放。
- 导出后网页还是旧版本：清浏览器缓存，或给 URL 加版本参数，例如 `?v=20260526-test`。
- FBX 动作不对：优先检查动作 FBX 是否带多余网格、骨架是否一致、root 朝向是否和基础模型一致。
- Docker 里内容没更新：先重新 Godot Web 导出，再 `docker cp exports/web/. godot-fighting-web-test:/www/` 或重新 `docker build`。

## 必杀/超必杀演出配置

当前原型支持“先播角色的简单挥拳动作，命中且对方没有防御成功后进入全屏演出，演出结束再结算伤害”的流程。后续导入影片资源后，只需要在招式 `.tres` 或角色的 `move_overrides` 中配置项目内路径。

推荐把演出影片放在：

```text
assets/cinematics/<character_id>/<move_id>/
```

招式资源可调字段：

- `cinematic_enabled`：是否进入全屏演出。只有明确设为 `true` 的招式会触发，地波、波动拳、升龙等小技能默认不触发。
- `cinematic_video_path`：演出影片路径，例如 `res://assets/cinematics/akame/236236J/special.ogv`。
- `cinematic_duration_frames`：没有影片或需要固定演出时间时使用的持续帧数。
- `cinematic_damage`：演出结束时结算的伤害；填 `-1` 时使用招式自身 `damage`。
- `startup_frames` / `active_frames` / `recovery_frames`：起手、判定、收招。
- `damage` / `chip_damage` / `meter_cost`：普通伤害、防御削血、气槽消耗。

每个角色也可以在 `CHARACTER_ROSTER` 里覆盖自己的速度和招式数值，例如：

```gdscript
{
	"name": "Fast Fighter",
	"move_folder": "res://data/moves/fast_fighter",
	"stats": {
		"walk_speed": 3.0,
		"dash_speed": 7.2,
		"jump_speed": 5.4,
	},
	"move_overrides": {
		"236236J": {
			"startup_frames": 5,
			"recovery_frames": 16,
			"damage": 80,
			"cinematic_damage": 140,
			"cinematic_duration_frames": 150,
			"cinematic_video_path": "res://assets/cinematics/fast_fighter/236236J/special.ogv",
		},
		"6246K": {
			"startup_frames": 12,
			"recovery_frames": 34,
			"damage": 160,
			"cinematic_damage": 280,
			"cinematic_duration_frames": 210,
			"cinematic_video_path": "res://assets/cinematics/fast_fighter/6246K/super.ogv",
		},
	},
}
```

这样可以做出“移动快、起手快但伤害低”的角色，也可以做“移动慢、起手慢但演出伤害高”的角色。资源路径请保持 `res://...`，不要写开发机绝对路径。
