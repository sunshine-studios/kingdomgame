# Choice System Documentation

## Overview
The choice system extends the existing portrait dialogue tool to allow interactive choices that can modify global variables and branch dialogue paths. Players can select from 2-3 options that affect the story and character relationships.

## Global Variables
Two global variables are tracked throughout the game:
- **Dominance Factor**: Represents the player's assertiveness and leadership
- **Reputation Factor**: Represents how others view the player

These are managed by the `GameState` autoload and can be accessed from any scene:
```gdscript
# Get current values
var dominance = GameState.get_dominance()
var reputation = GameState.get_reputation()

# Modify values
GameState.modify_dominance(0.1)  # Increase by 0.1
GameState.modify_reputation(-0.2)  # Decrease by 0.2

# Set absolute values
GameState.set_dominance(0.5)
GameState.set_reputation(0.0)
```

## JSON Structure for Choices

### Basic Choice Format
```json
{
  "dialogue_id": {
    "choice_0": {
      "prompt": "What do you choose?",
      "options": [
        {
          "text": "Option 1 text",
          "dominance_change": 0.1,
          "reputation_change": 0.2,
          "next_dialogue": "target_dialogue_id"
        },
        {
          "text": "Option 2 text",
          "dominance_change": -0.1,
          "reputation_change": 0.0,
          "next_dialogue": "other_dialogue_id"
        }
      ]
    }
  }
}
```

### Choice Properties
- **prompt**: Text displayed above the choice buttons (optional, defaults to "What do you choose?")
- **options**: Array of choice objects (2-3 choices supported)

### Option Properties
- **text**: The text displayed on the choice button (required)
- **dominance_change**: Amount to modify dominance factor (optional)
- **reputation_change**: Amount to modify reputation factor (optional)
- **next_dialogue**: ID of dialogue to jump to after this choice (optional)
- **skip_to_dialogue**: Index in sequence to skip to (optional, alternative to next_dialogue)

## Setting Up a Scene with Choices

### 1. Configure the Dialogue Tool
In the `portrait_dialogue_tool_v02.gd` script, set:
```gdscript
@export var json_file_path: String = "res://jsons/your_scene.json"
@export var scene_dialogue_sequence: Array[String] = ["intro", "choice_moment", "conclusion"]
```

### 2. Create Your JSON File
Structure your dialogue with regular lines and choices:
```json
{
  "portraitDialogue": {
    "intro": {
      "line_0": "Welcome to the academy.",
      "expression_0": "character_calm"
    },
    "choice_moment": {
      "choice_0": {
        "prompt": "How do you respond?",
        "options": [
          {
            "text": "Thank you for having me",
            "reputation_change": 0.1,
            "next_dialogue": "polite_response"
          },
          {
            "text": "I don't need your welcome",
            "dominance_change": 0.2,
            "reputation_change": -0.1,
            "next_dialogue": "rude_response"
          }
        ]
      }
    },
    "polite_response": {
      "line_0": "Such good manners!",
      "expression_0": "character_happy"
    },
    "rude_response": {
      "line_0": "How disrespectful!",
      "expression_0": "character_angry"
    }
  }
}
```

## Choice Flow Control

### Branching Dialogue
Use `next_dialogue` to jump to different dialogue branches:
```json
{
  "text": "I'll help you",
  "next_dialogue": "helpful_path"
}
```

### Sequential Progression
Omit `next_dialogue` to continue with the normal sequence:
```json
{
  "text": "I'm not sure",
  "dominance_change": -0.1
}
```

### Skipping Ahead
Use `skip_to_dialogue` to jump to a specific index in the sequence:
```json
{
  "text": "Let's skip the formalities",
  "skip_to_dialogue": 3
}
```

## Variable Guidelines

### Dominance Factor
- **Positive values**: Assertive, leadership-oriented choices
- **Negative values**: Passive, submissive choices
- **Range**: Generally -1.0 to 1.0
- **Examples**: 
  - +0.1 to +0.3: Mild to moderate assertiveness
  - -0.1 to -0.3: Mild to moderate passiveness

### Reputation Factor
- **Positive values**: Actions that improve others' opinion
- **Negative values**: Actions that damage reputation
- **Range**: Generally -1.0 to 1.0
- **Examples**:
  - +0.1 to +0.3: Helpful, respectful actions
  - -0.1 to -0.3: Rude, harmful actions

## Testing and Debugging

### Debug Panel
The main scene shows current variable values in the debug panel:
- Press F1 to toggle debug visibility
- Press F2 to reset all variables to 0

### Console Output
The system logs all choice selections and variable changes:
```
Choice selected: {"text": "Pick up the apple", "dominance_change": 0.1}
Dominance modified by: 0.1
```

## Example Implementation

See `jsons/choice_system_example.json` for a complete working example that demonstrates:
- Multiple choice points
- Variable modifications
- Dialogue branching
- Character portrait changes

## Tips for Content Creation

1. **Keep choices meaningful**: Each choice should feel impactful and represent different character approaches
2. **Balance variable changes**: Avoid extreme swings that break immersion
3. **Test all paths**: Ensure every choice leads to appropriate dialogue
4. **Use descriptive prompts**: Help players understand what they're choosing
5. **Consider consequences**: Choices should feel like they matter to the story

This system maintains the simplicity of the original dialogue tool while adding powerful branching capabilities for interactive storytelling. 