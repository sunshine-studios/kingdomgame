# Portrait Dialogue Tool v01 - Template Usage Guide

## 🚀 Quick Start: Creating a New Scene

1. **Duplicate the Scene**: Right-click `portrait_dialogue_tool_v01.tscn` → Duplicate → Rename (e.g., `chapter02_scene01.tscn`)

2. **Create Your JSON**: Duplicate `portrait_dialogue_template.json` → Rename (e.g., `Chapter02_Scene01.json`)

3. **Update Scene Settings**: In your new scene, select the root node and update:
   - **Json File Path**: `res://jsons/YourNewFile.json`
   - **Scene Dialogue Sequence**: `["character1_0", "character2_0", "character1_1"]`
   - **Scene End Behavior**: Choose how scene ends (HOLD/FADE_OUT/NEXT_SCENE)
   - **Next Scene Path**: If using NEXT_SCENE, set path like `res://scenes/next_scene.tscn`

That's it! Your new scene is ready!

## 📝 Easy JSON Format

```json
{
  "portraitDialogue": {
    "merlin_0": {
      "expression_0": "test_assets/merlin_test_01",
      "line_0": "Your dialogue text here",
      "expression_1": "test_assets/merlin_test_01", 
      "line_1": "Next line of dialogue"
    }
  }
}
```

## 👥 Adding New Characters

### Method 1: Use Existing Placeholders
- Rename `Character3PortraitStandIn` → `HarryPortraitStandIn`
- Make it visible in scene
- Add `harry_0`, `harry_1` entries to your JSON

### Method 2: Add New Character Nodes
1. Add new `TextureRect` node to scene root
2. Name it `[CharacterName]PortraitStandIn` (e.g., `HermionePortraitStandIn`)
3. Set size to `1216x832`
4. Position where you want
5. Add character entries to JSON

## 🎨 Portrait Assets

- **Size**: Always use 1216x832 for portraits
- **Path**: Place in `textures/` folder or subfolders
- **Reference**: Use path like `"test_assets/character_name"` in JSON

## 🔧 Built-in Features Kept

- ✅ Linear dialogue progression
- ✅ Typewriter text effect  
- ✅ Click to advance/skip
- ✅ Automatic character switching
- ✅ Font styling (DePixel font, size 32)
- ✅ Bottom-aligned dialogue box
- ✅ All test assets preserved
- ✅ **NEW**: Scene ending options (Hold/Fade/Transition)
- ✅ **NEW**: Crash protection with bounds checking

## 🎬 Scene Ending Options

Choose how your scene ends when dialogue completes:

- **HOLD** (default): Shows "Scene Complete" message, waits for user
- **FADE_OUT**: Smoothly fades scene to black
- **NEXT_SCENE**: Automatically transitions to next scene (set Next Scene Path)

## 💡 Pro Tips

- Character names in JSON should match node names (lowercase, no "PortraitStandIn")
- `merlin_0` dialogue shows `MerlinPortraitStandIn` 
- `harry_0` dialogue shows `HarryPortraitStandIn`
- The system auto-detects all portrait nodes! 