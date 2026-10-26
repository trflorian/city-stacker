class_name BoundaryArea
extends Area2D
## Invisible area at the side of the play field that houses must not enter.

signal house_entered


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is House:
		house_entered.emit()
