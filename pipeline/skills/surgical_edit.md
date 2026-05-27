# Skill: surgical_edit

## Purpose
Modify a single property, value, or block in an existing file without touching anything else.

## Inputs
```json
{
  "file_path": "string",
  "edit_type": "property | node_property | script_var | text_replace",
  "target": "string — node path, variable name, or search string",
  "value": "any — the new value"
}
```

## Outputs
- Modified file written in place
- `{ "changed": true, "previous_value": "...", "new_value": "..." }`

## Rules
- Read the file first; never overwrite the whole file
- Make the smallest possible change to achieve the edit
- Preserve all whitespace, comments, and formatting outside the edit target
- If `target` is ambiguous (matches multiple locations), return an error — do not guess
- Always pass the result through `validate_gdscript` after editing a `.gd` file
