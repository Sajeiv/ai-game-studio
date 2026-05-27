# Godot 4 — Scene Format

Reference for writing valid `.tscn` files in Godot 4.

---

## File header

Every `.tscn` file starts with a header line followed by external resource declarations:

```
[gd_scene load_steps=3 format=3 uid="uid://abc123"]

[ext_resource type="Script" path="res://seeds/player_controller.gd" id="1_abc"]
[ext_resource type="Texture2D" path="res://assets/sprites/player.png" id="2_def"]
```

- `load_steps` = total number of resources (ext_resource + sub_resource + 1 for the scene itself)
- `uid` = Godot-generated unique ID; leave as placeholder if generating, Godot rewrites it on import

---

## Node declaration

```
[node name="Player" type="CharacterBody2D"]
script = ExtResource("1_abc")
speed = 120.0
```

Child nodes use `parent=` to indicate their place in the tree:

```
[node name="Sprite" type="Sprite2D" parent="Player"]
texture = ExtResource("2_def")
position = Vector2(0, 0)
```

Root node has no `parent=` attribute.

---

## Sub-resources

Inline resources (shapes, materials) declared with `[sub_resource]`:

```
[sub_resource type="CapsuleShape2D" id="Shape_xyz"]
radius = 8.0
height = 24.0

[node name="Collider" type="CollisionShape2D" parent="Player"]
shape = SubResource("Shape_xyz")
```

---

## Signal connections

Connections are declared at the bottom of the file:

```
[connection signal="body_entered" from="InteractZone" to="." method="_on_zone_body_entered"]
```

- `from` = path to the emitting node relative to scene root
- `to` = path to the receiving node (`.` = root)
- `method` = name of the function on the receiving node

---

## Groups

Assign a node to a group in the node declaration:

```
[node name="Player" type="CharacterBody2D" groups=["player"]]
```

The `detector` and `interactable` seeds both use the `"player"` group to identify the player node.

---

## Common node types used by seeds

| Seed | Root node type |
|------|---------------|
| player_controller | CharacterBody2D |
| camera | Camera2D |
| scene_manager | Node (autoload) |
| game_state | Node (autoload) |
| autonomous_mover | CharacterBody2D |
| interactable | Area2D |
| resource_tracker | Node |
| audio_manager | Node (autoload) |
| ui_element | Control |
| detector | Node2D |
| spawner | Node2D |
| projectile | Area2D |
| dialogue | CanvasLayer |
| timer_event | Node |
