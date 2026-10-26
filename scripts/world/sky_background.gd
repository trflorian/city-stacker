class_name SkyBackground
extends CanvasLayer
## Background gradient behind the world.

@export var palette: Palette

@onready var _rect: ColorRect = $ColorRect


func _ready() -> void:
	var material := _rect.material as ShaderMaterial
	material.set_shader_parameter("top_color", palette.sky_top)
	material.set_shader_parameter("bottom_color", palette.sky_bottom)
