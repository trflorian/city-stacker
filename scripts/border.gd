extends Area2D
## Invisible side border that ends the game when a house swings or falls out.

@export var game: Main


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is House:
		game.call_game_over()
