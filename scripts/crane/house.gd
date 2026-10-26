class_name House
extends RigidBody2D
## A single floor of the building. Hangs on the crane until released, then falls onto the stack.

## Emitted once, when the house lands on another house or the ground floor lands on the ground.
signal landed
## Emitted when an upper floor touches the ground.
signal hit_ground

## Window centers relative to the house size, the last two are replaced by the door on the ground floor.
const WINDOW_SLOTS: PackedVector2Array = [
	Vector2(-0.25, -0.25), Vector2(0.22, -0.25), Vector2(-0.24, 0.24), Vector2(0.21, 0.25)
]
## Corner offsets of each window relative to its size, so they look hand drawn.
const WINDOW_JITTER: Array[PackedVector2Array] = [
	[Vector2(0.06, 0.0), Vector2(0.0, 0.05), Vector2(-0.04, 0.0), Vector2(0.0, -0.06)],
	[Vector2(0.0, 0.07), Vector2(-0.05, 0.0), Vector2(0.0, -0.03), Vector2(0.05, 0.0)],
	[Vector2(-0.03, 0.0), Vector2(0.0, -0.05), Vector2(0.06, 0.03), Vector2(0.0, 0.0)],
	[Vector2(0.0, -0.04), Vector2(0.04, 0.05), Vector2(0.0, 0.0), Vector2(-0.06, 0.02)],
]
## Part of the top floor height taken by the roof.
const ROOF_HEIGHT := 0.4
## Width of the anti-aliased outline drawn around shapes to smooth their edges.
const EDGE_WIDTH := 1.5

var level := 0
var is_released := false

var _config: HouseConfig
var _facade_color := Color.WHITE
var _has_landed := false
var _last_land_sound_time := -INF

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _land_player: AudioStreamPlayer = $LandPlayer


## Must be called before the house enters the tree.
func setup(config: HouseConfig, floor_level: int, facade_color: Color) -> void:
	_config = config
	level = floor_level
	_facade_color = facade_color


func _ready() -> void:
	mass = _config.mass
	gravity_scale = _config.gravity_scale
	physics_material_override = _config.physics_material
	var shape := RectangleShape2D.new()
	shape.size = Units.vec_to_pixels(_config.collider_size)
	_collision_shape.shape = shape
	_land_player.stream = Synth.blop()
	body_entered.connect(_on_body_entered)


func release() -> void:
	is_released = true
	linear_damp = _config.released_linear_damp
	angular_damp = _config.released_angular_damp


func _on_body_entered(body: Node) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_land_sound_time > _config.land_sound_cooldown:
		_last_land_sound_time = now
		_land_player.pitch_scale = randf_range(0.9, 1.1)
		_land_player.play()

	var is_ground := body is Ground
	if not _has_landed and (body is House or level == 0 and is_ground):
		_has_landed = true
		landed.emit()
	if level > 0 and is_ground:
		hit_ground.emit()


func _draw() -> void:
	var size := Units.vec_to_pixels(_config.size)
	var half := size / 2.0

	if level == _config.building_height:
		# shorter top floor with a pitched roof
		var roof_bottom := -half.y + size.y * ROOF_HEIGHT
		_draw_shape(_rect_points(Rect2(-half.x, roof_bottom, size.x, size.y * (1.0 - ROOF_HEIGHT))), _facade_color)
		var roof := PackedVector2Array(
			[Vector2(-half.x * 0.95, roof_bottom), Vector2(half.x * 0.14, -half.y), Vector2(half.x * 0.95, roof_bottom)]
		)
		_draw_shape(roof, _config.roof_color)
		_draw_window(size, 2)
		_draw_window(size, 3)
		return

	_draw_shape(_rect_points(Rect2(-half, size)), _facade_color)

	# flip every other floor vertically so the windows don't line up perfectly
	if level > 0 and level % 2 == 0:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1, -1))

	_draw_window(size, 0)
	_draw_window(size, 1)
	if level == 0:
		var door_size := size * Vector2(0.22, 0.42)
		var x := -size.x * 0.03
		var door := PackedVector2Array(
			[
				Vector2(x - door_size.x * 0.32, half.y - door_size.y),
				Vector2(x + door_size.x * 0.5, half.y - door_size.y),
				Vector2(x + door_size.x * 0.48, half.y),
				Vector2(x - door_size.x * 0.5, half.y),
			]
		)
		_draw_shape(door, _config.door_color)
	else:
		_draw_window(size, 2)
		_draw_window(size, 3)
	draw_set_transform(Vector2.ZERO)


func _draw_window(house_size: Vector2, slot: int) -> void:
	var center := WINDOW_SLOTS[slot] * house_size
	var window_size := _config.window_size * house_size
	var jitter := WINDOW_JITTER[slot]
	var corners := PackedVector2Array()
	for i in 4:
		var corner := Vector2(-0.5 if i == 0 or i == 3 else 0.5, -0.5 if i < 2 else 0.5)
		corners.append(center + (corner + jitter[i]) * window_size)
	_draw_shape(corners, _config.window_color)


## Filled polygon with an anti-aliased outline, as 2D MSAA is not available with the compatibility renderer.
func _draw_shape(points: PackedVector2Array, color: Color) -> void:
	draw_colored_polygon(points, color)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, color, EDGE_WIDTH, true)


static func _rect_points(rect: Rect2) -> PackedVector2Array:
	return [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
