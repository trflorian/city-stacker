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
## Resolution of the house sprites. Each sprite sheet holds the top, middle and ground floor from top to bottom.
@export var sprite_pixels_per_unit := 200.0
## Tint of the facade sprite, one color is picked at random for each building.
@export var facade_colors: Array[Color] = []

@export_group("Audio")
## Minimum time between two landing sounds of the same house in seconds.
@export var land_sound_cooldown := 0.1
