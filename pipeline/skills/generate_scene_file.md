# Skill: generate_scene_file

## Purpose
Produce a valid Godot 4 `.tscn` text scene file from a structured scene description.

## Inputs
```json
{
  "scene_name": "string",
  "root_type": "Node2D | CharacterBody2D | ...",
  "children": [
    {
      "name": "string",
      "type": "string",
      "script": "res://scripts/feature.gd",
      "properties": { "key": "value" },
      "children": []
    }
  ],
  "connections": [
    { "signal": "string", "from": "NodePath", "to": "NodePath", "method": "string" }
  ]
}
```

## Outputs
- A `.tscn` file in Godot 4 text scene format
- Written to `scenes/<scene_name>.tscn` in the game project

## Rules
- Use `ext_resource` for scripts and packed scenes; never inline GDScript in `.tscn`
- Every signal connection must reference a method that exists in the target script
- Node paths must be relative to the scene root
- All resource UIDs are generated sequentially starting from 1
