class_name Palette
extends Resource
## Shared colors of the game so everything follows one flat, coherent style.
##
## The ui theme (resources/theme.tres) uses the same shadow color and offset for texts and buttons.

@export_group("World")
@export var sky_top := Color(0.5, 0.68, 0.69)
@export var sky_bottom := Color(0.64, 0.79, 0.78)
@export var ground := Color(0.61, 0.77, 0.4)
@export var rope := Color(0.88, 0.88, 0.86)

@export_group("Shadow")
## Flat drop shadow used for texts, buttons and icons.
@export var shadow := Color(0.0, 0.12, 0.14, 0.25)
@export var shadow_offset := Vector2(0, 5)

@export_group("UI")
@export var icon := Color.WHITE
