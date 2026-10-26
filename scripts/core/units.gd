class_name Units
extends RefCounted
## Conversion between world units and pixels.
##
## Gameplay values are configured in world units like in the original game: one unit is the height of a
## house floor and 10 units fill the height of the 1280px reference viewport.

const PIXELS_PER_UNIT := 128.0


static func to_pixels(units: float) -> float:
	return units * PIXELS_PER_UNIT


static func vec_to_pixels(units: Vector2) -> Vector2:
	return units * PIXELS_PER_UNIT
