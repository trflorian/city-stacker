class_name Ground
extends StaticBody2D
## The grass the city is built on. Fills its collision shape with a flat color.

@export var color := Color(0.62, 0.78, 0.4)

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _draw() -> void:
	var rect_shape := _collision_shape.shape as RectangleShape2D
	draw_rect(Rect2(-rect_shape.size / 2.0, rect_shape.size), color)
