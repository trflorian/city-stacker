extends StaticBody2D
## The grass the city is built on.

const COLOR := Color(0.62, 0.78, 0.4)

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _draw() -> void:
	var size: Vector2 = (_shape.shape as RectangleShape2D).size
	draw_rect(Rect2(-size / 2.0, size), COLOR)
