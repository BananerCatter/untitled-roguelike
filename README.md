# untitled-roguelike

## A multi-week project for [#terra](terra.hackclub.com)
## Made by myself and [2shine](https://github.com/2shineman)

A 2d game made in godot, for Linux and Windows. We're planning to make a dungeon crawler roguelike thing, but currently it's more of a proof of concept while we flesh out the concept and mechanics. Well, to be honest, for now it's basically a collection of extensible systems made for us to use in the later weeks, so for now we have:

### Features :
```Bn = Added by bananya; 2s = added by 2shine```
```Most assets made by 2shine, a few sprites by me```
* A basic state machine movement system with acceleration and a dash ```Bn```
* A basic enemy template with pathfinding ```Bn```
* A stat and leveling system (latter not fully utilized yet) ```Bn```
* A **working** dungeon layout generator ```2s, the size of scripts he made for this scare me ngl```
* A minimap and rooms which close off when entered ```2s```
* Stamina (something something rollslop) ```Bn```
* Items and inventory, that can theoretically be used by almost anything (for now just the player) ```Bn```
* A (quite fugly looking 😭) inventory display ```Bn```
* Combat ```Bn```
* An option to switch between the test room and the dungeon (Options/ Spawn in dungeon) ```Bn```
* Buffs and status effects (Currently the only one in use is a tier 3 heal which gets applied when loading the level) ```Bn```

```Week 5 does not have that much to show for, as most of the changes I made are mostly internal (such as turning the test level into a level manager, fixing week 4 bugs) / are not fully utilized yet (the buff and status effect systems)```

### Controls:
* W/A/S/D for movement
* Shift to dash
* Left click to attack
* Tab to toggle inventory
* Left click to select item in inventory
* Q to use item / hold weapon from inventory
* ESC to pause/unpause
* M to toggle fullscreen minimap (if loaded in dungeon)
  
#### To use your weapon: Open the inventory, select it with left click, take it from the inventory with Q, left click to attack

### Debug controls:
* 1: Add 10 hp
* 2: Remove 10 hp
* 3: Toggle fps counter

### How to install:

Download the version for your system from the releases page, extract and run the provided executable. No further setup needed :D



### Screenshots:
<img width="1753" height="986" alt="Screenshot from 2026-11-16 19-31-00" src="https://github.com/user-attachments/assets/240bf673-f5f4-4aab-bbc6-ecdf38943ebd" />
<img width="1753" height="986" alt="Screenshot from 2026-11-16 19-31-08" src="https://github.com/user-attachments/assets/bbe4ce1b-9d2a-409a-a30c-a872aed04a1c" />
<img width="1860" height="1032" alt="Screenshot from 2026-11-23 17-41-51" src="https://github.com/user-attachments/assets/c6b673a7-74fd-4606-9501-aa6b0c02f6b7" />




