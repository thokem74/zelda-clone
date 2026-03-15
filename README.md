# Zelda Clone Prototype (Godot 4.6)

Small, beginner-friendly top-down 2D action-RPG vertical slice inspired by **A Link to the Past**.

## Included Features
- 8-direction top-down movement with 4-direction facing
- Sword swing with short melee hitbox
- Slime enemy with chase AI, contact damage cooldown, knockback, and death
- HUD with hearts + quest objective text
- Dialogue box with line-by-line advance
- Elder NPC quest flow (`not_started` -> `started` -> `item_acquired` -> `completed`)
- Two maps (Overworld + Cave), scene transitions, and spawn points
- Chest + key pickup + gate unlock flag support

## Project Tree

```text
project.godot
README.md
assets/placeholders/
scenes/
  Main.tscn
  player/Player.tscn
  enemies/Slime.tscn
  npc/NPC.tscn
  maps/Overworld.tscn
  maps/Cave.tscn
  ui/HUD.tscn
  ui/DialogueBox.tscn
  world/Door.tscn
  world/Chest.tscn
  world/Pickup.tscn
scripts/
  autoload/Game.gd
  autoload/QuestManager.gd
  autoload/DialogueManager.gd
  autoload/SceneRouter.gd
  player/player.gd
  player/sword_hitbox.gd
  enemies/slime.gd
  npc/npc.gd
  ui/hud.gd
  ui/dialogue_box.gd
  world/door.gd
  world/chest.gd
  world/pickup.gd
  world/gate.gd
data/
  dialogue/elder.json
  quests/lost_key.json
  items/items.json
```

## Setup Instructions

1. Open `project.godot` in Godot 4.6.
2. Confirm Autoloads are registered:
   - `Game`
   - `QuestManager`
   - `DialogueManager`
   - `SceneRouter`
3. Confirm Input Map actions:
   - `move_up` (W)
   - `move_down` (S)
   - `move_left` (A)
   - `move_right` (D)
   - `attack` (J)
   - `interact` (E)
4. Run project (`scenes/Main.tscn`).
5. Drop in sprites/tiles and create animations named in scripts:
   - Player: `idle_up/down/side`, `walk_up/down/side`, `attack_up/down/side`
   - Slime: `idle`, `move`
   - Chest: `closed`, `open`

## Scene Structures (Node Hierarchies)

### Main.tscn
- Main (Node)
  - Overworld (instance)

### Player.tscn
- Player (CharacterBody2D)
  - AnimatedSprite2D
  - CollisionShape2D
  - Hurtbox (Area2D)
    - CollisionShape2D
  - SwordHitbox (Area2D)
    - CollisionShape2D

### Slime.tscn
- Slime (CharacterBody2D)
  - AnimatedSprite2D
  - CollisionShape2D
  - ContactHitbox (Area2D)
    - CollisionShape2D

### NPC.tscn
- NPC (Node2D)
  - Sprite2D
  - InteractArea (Area2D)
    - CollisionShape2D

### Overworld.tscn
- Overworld (Node2D)
  - Ground (TileMapLayer)
  - Props (TileMapLayer)
  - SpawnPoints (Node2D)
    - player_start (Marker2D)
    - from_cave (Marker2D)
  - Player (instance)
  - Elder (NPC instance)
  - CaveEntrance (Door instance)
  - Gate (StaticBody2D + gate script)
  - HUD (instance)
  - DialogueBox (instance)

### Cave.tscn
- Cave (Node2D)
  - Ground (TileMapLayer)
  - Props (TileMapLayer)
  - SpawnPoints (Node2D)
    - from_overworld (Marker2D)
    - to_chest (Marker2D)
  - Player (instance)
  - ExitDoor (Door instance)
  - SlimeA (instance)
  - SlimeB (instance)
  - TreasureChest (instance)
  - HUD (instance)
  - DialogueBox (instance)

### HUD.tscn
- HUD (CanvasLayer)
  - MarginContainer
    - VBoxContainer
      - HeartsLabel
      - ObjectiveLabel

### DialogueBox.tscn
- DialogueBox (CanvasLayer)
  - PanelContainer
    - MarginContainer
      - VBoxContainer
        - Speaker
        - Line

### Door.tscn
- Door (Area2D)
  - CollisionShape2D

### Chest.tscn
- Chest (Node2D)
  - AnimatedSprite2D
  - InteractArea (Area2D)
    - CollisionShape2D

### Pickup.tscn
- Pickup (Area2D)
  - Sprite2D
  - CollisionShape2D

## Connection Guide

- **Door transitions**: set `target_scene` + `target_spawn` on each `Door` instance.
- **Spawn points**: `SceneRouter` searches for a `Marker2D` by exact `spawn_name`.
- **NPC interaction**: player enters `InteractArea`, presses `interact`, NPC picks dialogue key based on quest state.
- **Chest/key flow**: interact opens chest once (`opened_flag_name`), gives/spawns key pickup, updates quest to `item_acquired`.
- **Quest completion**: Elder checks for `required_item_id`; on success sets quest `completed` and flag `gate_unlocked`.
- **Gate unlock**: `gate.gd` watches `QuestManager.flag_changed` and disables collision/visibility when unlocked.

## Build Order (Fastest)

1. Run project as-is to verify baseline.
2. Add placeholder tile sprites + collisions in `TileMapLayer` nodes.
3. Add player/slime/chest animations with required names.
4. Tune combat values (`move_speed`, cooldowns, knockback).
5. Add UI polish and sound effects.

## Known Limitations (v1)

- No save/load system
- No inventory UI panel (items are flags/counts only)
- One quest, one enemy type
- Basic enemy steering (no pathfinding)
- Minimal scene transition effects (no fade)
- No advanced combat combo/stamina systems

## Next 5 Improvements

1. Add reusable interaction prompt (`Press E`) for interactables.
2. Add potion/heart drops and healing pickups.
3. Add fade transition + spawn camera easing.
4. Add second NPC and branching dialogue conditions.
5. Add basic audio manager (SFX + BGM with area swaps).
