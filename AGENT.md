# AGENT.md

## Purpose

This repository is a Godot 4.6 project built with GDScript. Use this file as the working guide for any agent or contributor making changes here. The goal is to keep edits aligned with Godot 4.6 conventions, preserve scene and script structure, and avoid introducing brittle engine-specific regressions.

## Project Summary

- Engine: Godot `4.6`
- Language: `GDScript`
- Main scene: `res://scenes/Main.tscn`
- Genre: top-down 2D action RPG prototype
- Rendering style: pixel art with nearest-neighbor filtering
- Architecture style: scene-driven composition with lightweight autoload singletons

## Core Rules

- Prefer Godot 4.6 APIs and patterns over older Godot 3.x approaches.
- Keep gameplay logic in `.gd` scripts and scene composition in `.tscn` files.
- Preserve existing node names unless a rename is required and every dependent script/path is updated.
- Treat exported properties and node paths as part of the scene contract.
- Avoid editing `.godot/` cache or import artifacts unless there is a specific, necessary reason.
- Do not hand-edit `project.godot` unless the task truly requires project-level config changes.
- Use official Godot documentation for engine-specific behavior and API uncertainty.

## Project Layout

```text
project.godot
AGENT.md
README.md
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
  dialogue/
  quests/
  items/
assets/
  kenney/
  tilesets/
```

## Engine Configuration

Current project-level assumptions from `project.godot`:

- `config/features=PackedStringArray("4.6")`
- Main scene is `res://scenes/Main.tscn`
- Autoloads:
  - `Game`
  - `QuestManager`
  - `DialogueManager`
  - `SceneRouter`
- Input actions:
  - `move_up` mapped to `W`
  - `move_down` mapped to `S`
  - `move_left` mapped to `A`
  - `move_right` mapped to `D`
  - `attack` mapped to `J`
  - `interact` mapped to `E`
- Pixel filtering is disabled via `textures/canvas_textures/default_texture_filter=0`

When making gameplay or UI changes, assume these settings are intentional unless the task explicitly says to change them.

## Godot 4.6 Guidance

### Scenes

- Prefer scene inheritance and instancing over duplicating nodes manually.
- Keep reusable gameplay objects as self-contained scenes.
- Maintain stable node paths for scripts that use `$NodeName` or exported `NodePath`.
- If you must change a node name or hierarchy, update every script and inherited-scene override that depends on it.
- Use `CharacterBody2D`, `Area2D`, `StaticBody2D`, `CanvasLayer`, `Marker2D`, and `TileMapLayer` according to their intended Godot 4 usage.

### Scripts

- Use typed GDScript where it improves clarity.
- Prefer `@export` for inspector-facing values.
- Prefer `@onready` for scene node references.
- Use signals and groups for loose coupling when appropriate.
- Keep `_process` and `_physics_process` focused and small.
- Avoid putting level-specific logic inside generic reusable scenes if it belongs in the map scene.

### Resources and Assets

- Use `res://` paths consistently in scene and script resources.
- Keep sprite-sheet usage explicit when possible.
- If replacing a sprite sheet, update any `frame`, `hframes`, `vframes`, `AtlasTexture`, or `region_rect` logic that depends on the old layout.
- Do not assume a new texture can replace an old one without remapping frames or atlas regions.
- Available graphic assets for this project include:
  - `res://assets/kenney/kenney_roguelike-characters/Spritesheet/roguelikeChar_transparent.png`
  - `res://assets/kenney/kenney_roguelike-indoors/Tilesheets/roguelikeIndoor_transparent.png`
  - `res://assets/kenney/kenney_roguelike-rpg-pack/Spritesheet/roguelikeSheet_transparent.png`
- Preserve pixel-art presentation:
  - Keep nearest-neighbor filtering
  - Avoid smoothing/scaling choices that blur sprites

### Physics and Movement

- Use `_physics_process` for movement and collision behavior.
- Prefer `move_and_slide()` patterns already established in the project.
- Keep hitboxes, hurtboxes, and interaction areas separated by responsibility.
- When changing collisions or body types, verify both visual placement and gameplay behavior.

## Current Gameplay Architecture

### Player

- Scene: `res://scenes/player/Player.tscn`
- Script: `res://scripts/player/player.gd`
- Responsibilities:
  - movement
  - facing direction
  - animation state updates
  - sword attack timing
  - receiving damage
- Uses:
  - `SwordHitbox` child area
  - `Hurtbox` child area
  - `Game` autoload for HP and movement lock state

### Enemies

- Slime scene: `res://scenes/enemies/Slime.tscn`
- Script: `res://scripts/enemies/slime.gd`
- Responsibilities:
  - player pursuit within aggro range
  - contact damage
  - knockback response
  - simple sprite animation state

### NPCs and Dialogue

- NPC scene: `res://scenes/npc/NPC.tscn`
- Script: `res://scripts/npc/npc.gd`
- Dialogue is driven through `DialogueManager`
- Quest state is read from `QuestManager`
- NPC interaction depends on `InteractArea` body enter/exit events

### World Interactables

- `Door.tscn` handles scene transitions
- `Chest.tscn` handles one-time opening and optional pickup spawning
- `Pickup.tscn` handles item collection
- `gate.gd` reacts to quest flags for progression gating

### Maps

- `Overworld.tscn` and `Cave.tscn` are currently the active maps
- They instance player, NPCs, enemies, HUD, dialogue UI, and world interactables
- Spawn transitions rely on named `Marker2D` nodes
- Backgrounds currently come from a stacked backdrop texture rather than authored TileMap content

## Scene Contracts To Preserve

These contracts are important and should not be broken casually:

- `SceneRouter` expects spawn markers to exist by exact name.
- `Door` instances rely on `target_scene` and `target_spawn`.
- `NPC` relies on `InteractArea`.
- `Chest` relies on `InteractArea` and sprite visuals being updateable at runtime.
- `Player` relies on `SwordHitbox` and `Hurtbox`.
- Scripts often assume specific child node names like `Sprite2D`, `CollisionShape2D`, `InteractArea`, `ContactHitbox`, and `SwordHitbox`.

If you change any of these contracts, update all dependent scenes and scripts in the same task.

## Coding Style For GDScript

- Use tabs if the file already uses tabs. Match existing formatting.
- Keep functions small and named around behavior.
- Prefer descriptive variable names over abbreviations.
- Use constants for repeated frame data, atlas regions, or gameplay tuning values that are not inspector-driven.
- Add brief comments only when the logic is not obvious from code.
- Avoid overengineering. This repo favors clear, direct gameplay scripts.

## Asset Replacement Rules

When swapping art in this repo:

- Check every scene and script that references the old asset.
- Verify whether the asset is used as:
  - full texture
  - frame grid
  - `AtlasTexture`
  - `region_rect`
  - inherited-scene override
- Update code that uses `.frame` if the replacement is no longer a frame grid.
- Update child scene overrides in parent maps if they relied on old frame indices.
- Expect related `.import` files to be regenerated by Godot.

## Safe Editing Checklist

Before editing:

- Read the relevant scene file and attached script.
- Search for references to the scene, node names, exported fields, and textures involved.
- Check whether inherited scenes override the same properties.

After editing:

- Re-read the changed scene or script to confirm references still match.
- Check for stale frame-grid assumptions after atlas swaps.
- Check for resource paths that still point to removed files.
- If you cannot run Godot in the environment, say so clearly.

## Testing Expectations

Preferred validation order:

1. Static verification
2. Scene/script reference review
3. Godot editor run or in-engine smoke test

When Godot is available, validate at least:

- Project opens without missing-resource errors
- Main scene loads
- Player is visible and movable
- Scene transitions still work
- NPC dialogue still opens
- Slimes are visible and damage the player
- Chest and pickup flow still works

If Godot is not available in the environment, do not pretend runtime validation happened. Report exactly what was checked instead.

## Common Pitfalls In This Repo

- Replacing a texture without updating frame indexing logic
- Renaming child nodes that scripts access directly
- Forgetting inherited scene overrides
- Breaking spawn marker names used by `SceneRouter`
- Changing quest flags or item IDs without updating dialogue and quest data
- Editing only the scene or only the script when both define the behavior contract
- Deleting source assets that scenes still reference

## Recommended Workflow For Agents

1. Read the relevant scene and script together.
2. Search for all references before changing art, node names, or exported values.
3. Make the smallest coherent set of changes that fully resolves the task.
4. Re-read the final files for consistency.
5. Report any runtime validation gaps honestly.

## Documentation Source

For engine-specific questions, consult the official Godot documentation first:

- https://docs.godotengine.org/en/stable

For this repository’s intended gameplay and structure, also review:

- `README.md`
- `project.godot`
- the relevant `.tscn` and `.gd` files involved in the task
