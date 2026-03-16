# Zelda Clone Prototype

Godot 4.6 top-down 2D action-RPG prototype inspired by **The Legend of Zelda: A Link to the Past**.

The project currently includes a playable overworld/cave loop, simple combat, quest progression, dialogue, pickups, and scene transitions using Kenney art assets wired through atlas regions and lightweight GDScript systems.

## Current State

- Engine: `Godot 4.6`
- Language: `GDScript`
- Main scene: `res://scenes/Main.tscn`
- Style: pixel art, nearest-neighbor filtering
- Status: playable vertical slice

## Included Features

- Top-down movement with 4-direction facing
- Sword attack with a short melee hitbox
- Slime enemies with chase behavior, contact damage, knockback, and death
- Elder NPC with quest-aware dialogue
- Quest progression from intro to key retrieval to gate unlock
- Chest interaction and spawned key pickup flow
- Overworld and cave scene transitions with named spawn points
- HUD with hearts and current objective text
- Dialogue box with line-by-line advancement
- Atlas-based sprite rendering using Kenney sprite sheets

## Controls

- `W` move up
- `A` move left
- `S` move down
- `D` move right
- `J` attack
- `E` interact / advance dialogue

## Art Assets In Use

The project currently uses these Kenney sprite sheets:

- `res://assets/kenney/kenney_roguelike-characters/Spritesheet/roguelikeChar_transparent.png`
- `res://assets/kenney/kenney_roguelike-indoors/Tilesheets/roguelikeIndoor_transparent.png`
- `res://assets/kenney/kenney_roguelike-rpg-pack/Spritesheet/roguelikeSheet_transparent.png`

The generated background texture used by the map backdrops lives at:

- `res://assets/tilesets/background_tileset.png`

## Project Structure

```text
project.godot
AGENT.md
README.md
assets/
  kenney/
  tilesets/
data/
  dialogue/elder.json
  items/items.json
  quests/lost_key.json
scenes/
  Main.tscn
  enemies/Slime.tscn
  maps/Cave.tscn
  maps/Overworld.tscn
  npc/NPC.tscn
  player/Player.tscn
  ui/DialogueBox.tscn
  ui/HUD.tscn
  world/Chest.tscn
  world/Door.tscn
  world/Pickup.tscn
scripts/
  autoload/DialogueManager.gd
  autoload/Game.gd
  autoload/QuestManager.gd
  autoload/SceneRouter.gd
  enemies/slime.gd
  npc/npc.gd
  player/player.gd
  player/sword_hitbox.gd
  ui/dialogue_box.gd
  ui/hud.gd
  world/chest.gd
  world/door.gd
  world/gate.gd
  world/pickup.gd
```

## Setup

1. Open `project.godot` in Godot `4.6`.
2. Confirm the autoloads exist:
   - `Game`
   - `QuestManager`
   - `DialogueManager`
   - `SceneRouter`
3. Confirm the input actions exist:
   - `move_up`
   - `move_down`
   - `move_left`
   - `move_right`
   - `attack`
   - `interact`
4. Run `res://scenes/Main.tscn`.

## Scene Overview

### Main

- `Main.tscn`
- Boots into `Overworld.tscn`

### Player

- `Player.tscn`
- Root: `CharacterBody2D`
- Child nodes:
  - `Sprite2D`
  - `CollisionShape2D`
  - `Hurtbox`
  - `SwordHitbox`
- Uses atlas regions from the Kenney character sheet

### Enemy

- `Slime.tscn`
- Root: `CharacterBody2D`
- Child nodes:
  - `Sprite2D`
  - `CollisionShape2D`
  - `ContactHitbox`
- Uses atlas regions from the Kenney character sheet

### NPC

- `NPC.tscn`
- Root: `Node2D`
- Child nodes:
  - `Sprite2D`
  - `InteractArea`
- Uses atlas regions from the Kenney character sheet

### Maps

#### Overworld

- Backdrop frame `0` from `background_tileset.png`
- Contains:
  - player start spawn
  - elder NPC
  - cave entrance door
  - quest gate
  - HUD
  - dialogue UI

#### Cave

- Backdrop frame `1` from `background_tileset.png`
- Contains:
  - cave exit door
  - two slime enemies
  - treasure chest
  - pickup spawn target
  - HUD
  - dialogue UI

### World Objects

- `Door.tscn`: scene transitions
- `Chest.tscn`: one-time interactable chest with open/closed atlas regions
- `Pickup.tscn`: collectible item pickup

## Gameplay Flow

1. Start in the overworld near the village elder.
2. Talk to the elder to begin the lost key quest.
3. Enter the cave.
4. Avoid or fight slimes.
5. Open the chest to obtain the key pickup.
6. Return to the elder.
7. Complete the quest and unlock the gate.

## Data And Systems

### Autoloads

- `Game`
  - player HP
  - movement lock state
  - item ownership/count tracking
- `QuestManager`
  - quest states
  - world flags
- `DialogueManager`
  - dialogue UI state
  - line advancement
- `SceneRouter`
  - scene changes
  - spawn marker resolution

### Data Files

- `data/dialogue/elder.json`
- `data/quests/lost_key.json`
- `data/items/items.json`

## Important Implementation Notes

- The project currently uses `Sprite2D` plus atlas `region_rect` logic rather than `AnimatedSprite2D` resources.
- Swapping sprite sheets requires updating any code that still assumes `frame`, `hframes`, or `vframes`.
- Map `Ground` and `Props` nodes exist as `TileMapLayer`s, but the current visible environment is primarily driven by backdrop sprites and placed scene instances.
- Scene transitions rely on exact `Marker2D` names.
- Several gameplay systems depend on stable child node names such as `Sprite2D`, `InteractArea`, `Hurtbox`, and `SwordHitbox`.

## Known Limitations

- No save/load system
- No inventory UI
- Only one quest
- Only one enemy type
- Very simple enemy AI
- No audio system yet
- Minimal transition effects
- TileMap content is still sparse compared to the backdrop-driven presentation

## Suggested Next Improvements

1. Add a reusable interact prompt.
2. Add sound effects and music.
3. Replace simple backdrop-based environments with fuller TileMap-authored maps.
4. Add more enemy types and combat variety.
5. Add a second NPC and more quest branching.
6. Add save/load support.

## Development Notes

- Use Godot `4.6` APIs and patterns.
- Check `AGENT.md` for repo-specific guidance before making structural changes.
- Prefer official Godot documentation for engine-specific decisions:
  - https://docs.godotengine.org/en/stable
