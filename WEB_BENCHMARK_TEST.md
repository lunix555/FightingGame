# Fighting State Machine Web Test

The project now starts:

```text
res://scenes/fighting_state_machine_test.tscn
```

The current Web export is available at:

```text
http://127.0.0.1:8000/
```

## Player 1 Controls

- Move: `WASD`
- Buttons: `J K U I O L`
- Examples: `J`, `K`, `U`, `I`, `O`, `S + K`, `D + U`
- Motions: `236J`, `236K`, `214U`, `623I`, `41236L`, `236236O`

The motion notation is numpad style:

```text
7 8 9
4 5 6
1 2 3
```

So `236J` means down, down-forward, forward, then `J`.

## Core Scripts

- `res://scripts/fighting/move_definition.gd`
- `res://scripts/fighting/fighting_input_buffer.gd`
- `res://scripts/fighting/fighter_controller.gd`
- `res://scripts/fighting/fighting_game_test.gd`

## Move Data Resources

Fake move resources are in:

```text
res://data/moves/prototype/
```

Each `.tres` file has editable fields for:

- command motion and button
- startup, active, and recovery frames
- hitstun, blockstun, damage, meter cost
- animation slot key
- VFX key
- SFX key

The controller also has an exported `animation_slots` dictionary as a placeholder for later animation binding.
