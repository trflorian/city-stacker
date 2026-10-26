class_name Crane
extends Node2D
## Swings houses on a rope and releases them on demand. Moves up one floor whenever a house lands.

signal house_landed
signal house_fell
signal building_completed

const HOUSE_SCENE: PackedScene = preload("res://scenes/house.tscn")

@export var config: CraneConfig
@export var house_config: HouseConfig
@export var palette: Palette
## Parent of the spawned houses, they must not move together with the crane.
@export var house_container: Node2D

var _level := 0
var _facade_color := Color.WHITE
var _is_running := false
var _current_house: House
var _joint: PinJoint2D

@onready var _pivot: StaticBody2D = $Pivot
@onready var _rope: Line2D = $Rope


func _ready() -> void:
	_rope.width = Units.to_pixels(config.rope_width)
	_rope.default_color = palette.rope
	_rope.visible = false


func _process(_delta: float) -> void:
	if has_attached_house():
		_rope.set_point_position(1, to_local(_current_house.global_position))


## Starts a new building with the first house hanging on the crane.
func start() -> void:
	_is_running = true
	_level = 0
	_facade_color = house_config.facade_colors.pick_random()
	position = Vector2(0, -Units.to_pixels(config.start_height))
	_spawn_house()


## Stops spawning houses and removes the one hanging on the crane.
func stop() -> void:
	_is_running = false
	if has_attached_house():
		_detach_house()
		_current_house.queue_free()
		_current_house = null


func release_house() -> void:
	if not has_attached_house():
		return
	_detach_house()
	_current_house.release()


func has_attached_house() -> bool:
	return _current_house != null and not _current_house.is_released


func _on_house_landed() -> void:
	if not _is_running:
		return
	house_landed.emit()

	if _level >= house_config.building_height:
		# the roof is placed, the building is complete
		_is_running = false
		building_completed.emit()
		return

	_level += 1
	position.y -= Units.to_pixels(config.floor_height)
	_spawn_house()


func _on_house_hit_ground() -> void:
	if _is_running:
		house_fell.emit()


func _spawn_house() -> void:
	var angle := deg_to_rad(randf_range(-config.max_swing_angle, config.max_swing_angle))
	var max_angle := deg_to_rad(config.max_swing_angle)

	# give the house just enough energy to swing up to the max angle
	var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * house_config.gravity_scale
	var rope_length := Units.to_pixels(config.rope_length)
	var height_diff := (cos(angle) - cos(max_angle)) * rope_length
	var speed := sqrt(2.0 * gravity * height_diff) * (1.0 if randi() % 2 == 0 else -1.0)
	var velocity := Vector2(cos(absf(angle)), -sin(absf(angle))) * speed

	var house: House = HOUSE_SCENE.instantiate()
	house.setup(house_config, _level, _facade_color)
	house.position = house_container.to_local(to_global(Vector2(sin(angle), cos(angle)) * rope_length))
	house.rotation = -angle
	# houses report collisions during the physics step, spawning must wait until it is done
	house.landed.connect(_on_house_landed, CONNECT_DEFERRED)
	house.hit_ground.connect(_on_house_hit_ground, CONNECT_DEFERRED)
	house_container.add_child(house)
	house.linear_velocity = velocity
	_current_house = house

	_joint = PinJoint2D.new()
	_pivot.add_child(_joint)
	_joint.node_a = _joint.get_path_to(_pivot)
	_joint.node_b = _joint.get_path_to(house)

	_rope.visible = true
	_rope.set_point_position(1, to_local(house.global_position))


func _detach_house() -> void:
	_rope.visible = false
	if _joint != null:
		_joint.queue_free()
		_joint = null
