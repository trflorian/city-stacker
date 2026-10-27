class_name StackTest
extends Node2D
## Test scene that starts with houses already stacked, to check how stable a tall building is.
##
## The houses are stacked almost perfectly with small random offsets. The randomness is seeded so every run can be
## reproduced. All settings can be overridden on the command line, which also allows running the test headless:
## [codeblock]
## godot --headless res://scenes/test/stack_test.tscn -- --houses=10 --seed=3 --duration=10
## [/codeblock]
## The scene prints a summary every second and quits with exit code 1 if the stack was not stable when running
## headless.

const HOUSE_SCENE: PackedScene = preload("res://scenes/house.tscn")
## Seconds to let the stack settle before speeds count towards the result.
const SETTLE_TIME := 1.0

@export var house_config: HouseConfig
@export var house_count := 8
@export var random_seed := 1
## Maximum horizontal offset of a house to the one below in world units.
@export var max_offset := 0.05
## Maximum rotation of each house in degrees.
@export var max_rotation := 0.5
## Seconds to simulate before the result is reported, 0 runs forever.
@export var duration := 10.0
## Highest speed in world units per second a settled house may have for the stack to count as stable.
@export var stable_speed := 0.05
## Quit after reporting the result, always on when running headless.
@export var quit_when_done := false

@export_group("Physics")
## Overrides the physics ticks per second of the project when above 0.
@export var physics_ticks := 0
## Overrides the solver iterations of the project when above 0.
@export var solver_iterations := 0

var _houses: Array[House] = []
var _start_positions: Array[Vector2] = []
var _physics_frames := 0
var _max_settled_speed := 0.0
var _max_settled_angular_speed := 0.0
var _is_done := false

@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	_parse_arguments()
	if DisplayServer.get_name() == "headless":
		quit_when_done = true
	if physics_ticks > 0:
		Engine.physics_ticks_per_second = physics_ticks
	if solver_iterations > 0:
		PhysicsServer2D.space_set_param(
			get_world_2d().space, PhysicsServer2D.SPACE_PARAM_SOLVER_ITERATIONS, solver_iterations
		)

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	var size := Units.vec_to_pixels(house_config.collider_size)
	var x := 0.0
	var bottom := 0.0
	for level in house_count:
		var angle := deg_to_rad(rng.randf_range(-max_rotation, max_rotation))
		if level > 0:
			x += Units.to_pixels(rng.randf_range(-max_offset, max_offset))
		# half height of the rotated box, so the houses touch without overlapping
		var half_height := (size.y * cos(angle) + size.x * absf(sin(angle))) / 2.0
		var house: House = HOUSE_SCENE.instantiate()
		house.setup(house_config, level, house_config.facade_colors[0])
		house.position = Vector2(x, bottom - half_height)
		house.rotation = angle
		add_child(house)
		house.release()
		_houses.append(house)
		_start_positions.append(house.position)
		bottom -= half_height * 2.0

	_camera.position = Vector2(0, bottom / 2.0)
	var view_height := get_viewport_rect().size.y
	_camera.zoom = Vector2.ONE * minf(1.0, view_height / (-bottom + Units.to_pixels(2.0)))
	print(
		(
			"stack test: %d houses, seed %d, max offset %.3f, max rotation %.2f deg, %d physics ticks, %s"
			% [
				house_count,
				random_seed,
				max_offset,
				max_rotation,
				Engine.physics_ticks_per_second,
				"%d solver iterations" % solver_iterations if solver_iterations > 0 else "default solver iterations",
			]
		)
	)


func _physics_process(_delta: float) -> void:
	if _is_done:
		return
	_physics_frames += 1
	var time := _physics_frames / float(Engine.physics_ticks_per_second)
	if time > SETTLE_TIME:
		for house in _houses:
			_max_settled_speed = maxf(_max_settled_speed, house.linear_velocity.length() / Units.PIXELS_PER_UNIT)
			_max_settled_angular_speed = maxf(_max_settled_angular_speed, absf(house.angular_velocity))
	if _physics_frames % Engine.physics_ticks_per_second == 0:
		_print_status(time)
	if duration > 0.0 and time >= duration:
		_finish()


func _print_status(time: float) -> void:
	var max_speed := 0.0
	var sleeping := 0
	for house in _houses:
		max_speed = maxf(max_speed, house.linear_velocity.length() / Units.PIXELS_PER_UNIT)
		if house.sleeping:
			sleeping += 1
	print(
		(
			"t=%5.1fs  max speed %.4f  top drift %.4f  sleeping %d/%d"
			% [time, max_speed, _drift(_houses.size() - 1), sleeping, _houses.size()]
		)
	)


func _finish() -> void:
	_is_done = true
	var max_drift := 0.0
	for i in _houses.size():
		max_drift = maxf(max_drift, _drift(i))
	var is_stable := _max_settled_speed <= stable_speed
	print(
		(
			"result: %s  max settled speed %.4f  max settled angular speed %.4f  max drift %.4f"
			% ["STABLE" if is_stable else "UNSTABLE", _max_settled_speed, _max_settled_angular_speed, max_drift]
		)
	)
	if quit_when_done:
		get_tree().quit(0 if is_stable else 1)


## Distance in world units the house moved from its start position.
func _drift(index: int) -> float:
	return _houses[index].position.distance_to(_start_positions[index]) / Units.PIXELS_PER_UNIT


func _parse_arguments() -> void:
	for argument in OS.get_cmdline_user_args():
		var parts := argument.trim_prefix("--").split("=")
		if parts.size() != 2:
			continue
		match parts[0]:
			"houses":
				house_count = parts[1].to_int()
			"seed":
				random_seed = parts[1].to_int()
			"offset":
				max_offset = parts[1].to_float()
			"rotation":
				max_rotation = parts[1].to_float()
			"duration":
				duration = parts[1].to_float()
			"ticks":
				physics_ticks = parts[1].to_int()
			"iterations":
				solver_iterations = parts[1].to_int()
