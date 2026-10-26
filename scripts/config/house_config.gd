class_name HouseConfig
extends Resource
## Physics and looks of a single house floor.

## Number of floors on top of the ground floor, the last one gets a roof.
@export var building_height := 20

@export_group("Physics")
## Size of the collision box in world units.
@export var collider_size := Vector2(1.362, 1.0)
@export var mass := 20.0
@export var gravity_scale := 1.8
@export var physics_material: PhysicsMaterial
## Damping applied once the house is released from the crane.
@export var released_linear_damp := 1.0
@export var released_angular_damp := 0.01

@export_group("Looks")
## Drawn size in world units, slightly wider than the collider so the floors overlap visually.
@export var size := Vector2(1.395, 1.025)
## One color is picked at random for each building.
@export var facade_colors: Array[Color] = []
@export var window_color := Color(0.89, 0.89, 0.89)
@export var door_color := Color(0.52, 0.34, 0.15)
@export var roof_color := Color(0.87, 0.6, 0.25)
## Window size relative to the house size.
@export var window_size := Vector2(0.2, 0.28)

@export_group("Audio")
## Minimum time between two landing sounds of the same house in seconds.
@export var land_sound_cooldown := 0.1
