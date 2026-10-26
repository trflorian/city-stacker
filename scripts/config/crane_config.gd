class_name CraneConfig
extends Resource
## Tuning of the crane that swings the houses.

## Distance between the crane pivot and the center of the hanging house in world units.
@export var rope_length := 6.0
## Maximum swing angle of a new house in degrees.
@export var max_swing_angle := 10.0
## Height of the crane above the ground origin when the game starts in world units.
@export var start_height := 7.0
## How far the crane moves up after each placed floor in world units.
@export var floor_height := 1.0

@export_group("Rope")
@export var rope_width := 0.08
@export var rope_color := Color(0.85, 0.85, 0.85)
