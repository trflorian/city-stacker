class_name Crane
extends Node2D
## Spawns houses that swing on a rope and releases them on tap.

const CRANE_LENGTH := 6.0
const MAX_HOUSE_ANGLE := 10.0
const START_HEIGHT := 7.0

const HOUSE_SCENE := preload("res://scenes/house.tscn")

@export var game: Main
## Parent node for spawned houses
@export var houses: Node2D

var _current_level := 0
var _current_house: House
var _joint: PinJoint2D

@onready var _pivot: StaticBody2D = $Pivot
@onready var _line: Line2D = $CraneLine


func _ready() -> void:
	game.tapped.connect(_release_house)
	game.game_over.connect(_on_game_over)
	position = Vector2(0, -START_HEIGHT * Main.UNIT)
	_spawn_house()


func _process(_delta: float) -> void:
	if _current_house != null and not _current_house.is_detached:
		_update_crane_line()


func _release_house() -> void:
	if _current_house == null or _current_house.is_detached:
		return
	_line.visible = false
	_free_joint()
	_current_house.detach()


func _move_up() -> void:
	if game.is_game_over:
		return
	game.increase_score()

	if _current_level >= House.BUILDING_HEIGHT:
		# roof is placed, the building is complete
		get_tree().create_timer(1.0).timeout.connect(game.call_game_over)
		return

	_current_level += 1
	position.y -= Main.UNIT
	_spawn_house()


func _spawn_house() -> void:
	var angle := randf_range(-MAX_HOUSE_ANGLE, MAX_HOUSE_ANGLE)
	var rad := deg_to_rad(angle)
	var offset := Vector2(sin(rad), cos(rad)) * CRANE_LENGTH

	# give the house just enough energy to swing up to the max angle
	var height_diff := (cos(rad) - cos(deg_to_rad(MAX_HOUSE_ANGLE))) * CRANE_LENGTH
	var speed := sqrt(2.0 * House.GRAVITY_SCALE * 9.81 * height_diff)
	if randi() % 2 == 0:
		speed *= -1.0
	var direction_angle := deg_to_rad(absf(angle))
	var velocity := Vector2(cos(direction_angle), -sin(direction_angle)) * speed

	_current_house = HOUSE_SCENE.instantiate()
	_current_house.setup(game, _current_level)
	_current_house.position = position + offset * Main.UNIT
	_current_house.rotation = -rad
	houses.add_child(_current_house)
	_current_house.linear_velocity = velocity * Main.UNIT
	_current_house.touched_down.connect(_move_up)

	_joint = PinJoint2D.new()
	_pivot.add_child(_joint)
	_joint.node_a = _joint.get_path_to(_pivot)
	_joint.node_b = _joint.get_path_to(_current_house)

	_line.visible = true
	_update_crane_line()


func _on_game_over() -> void:
	if _current_house == null or _current_house.is_detached:
		return
	_line.visible = false
	_free_joint()
	_current_house.queue_free()
	_current_house = null


func _free_joint() -> void:
	if _joint != null:
		_joint.queue_free()
		_joint = null


func _update_crane_line() -> void:
	_line.set_point_position(1, to_local(_current_house.global_position))
