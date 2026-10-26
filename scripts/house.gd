class_name House
extends RigidBody2D
## A single floor of the building. Swings on the crane until released.

signal touched_down

const GRAVITY_SCALE := 1.8
const BUILDING_HEIGHT := 20
const SIZE := Vector2(1.395, 1.025) * Main.UNIT

const FACADE_COLORS: Array[Color] = [
	Color(0.96, 0.87, 0.5),
	Color(0.96, 0.55, 0.5),
	Color(0.35, 0.7, 0.4),
	Color(0.74, 0.56, 0.92),
	Color(0.37, 0.62, 0.81),
]
const WINDOW_COLOR := Color(0.89, 0.89, 0.89)
const DOOR_COLOR := Color(0.52, 0.34, 0.15)
const ROOF_COLOR := Color(0.87, 0.6, 0.25)
## Window size relative to the house size
const WINDOW_SIZE := Vector2(0.2, 0.28)
## Corner jitter per window slot so they look hand drawn (fraction of window size)
const WINDOW_JITTER := [
	[Vector2(0.06, 0.0), Vector2(0.0, 0.05), Vector2(-0.04, 0.0), Vector2(0.0, -0.06)],
	[Vector2(0.0, 0.07), Vector2(-0.05, 0.0), Vector2(0.0, -0.03), Vector2(0.05, 0.0)],
	[Vector2(-0.03, 0.0), Vector2(0.0, -0.05), Vector2(0.06, 0.03), Vector2(0.0, 0.0)],
	[Vector2(0.0, -0.04), Vector2(0.04, 0.05), Vector2(0.0, 0.0), Vector2(-0.06, 0.02)],
]
const LAND_SOUND_COOLDOWN := 0.1

var level := 0
var is_detached := false

var _game: Main
var _color := Color.WHITE
var _has_touched_down := false
var _last_land_sound := -1.0

@onready var _land_player: AudioStreamPlayer = $LandPlayer


func setup(game: Main, floor_level: int) -> void:
	_game = game
	level = floor_level
	_color = FACADE_COLORS[game.house_color_id]


func _ready() -> void:
	gravity_scale = GRAVITY_SCALE
	_land_player.stream = Global.sfx_land
	body_entered.connect(_on_body_entered)


func detach() -> void:
	is_detached = true
	linear_damp = 1.0
	angular_damp = 0.01


func _on_body_entered(body: Node) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_land_sound > LAND_SOUND_COOLDOWN:
		_last_land_sound = now
		_land_player.pitch_scale = randf_range(0.9, 1.1)
		_land_player.play()

	var touch_ground := body.is_in_group("ground")
	if not _has_touched_down and (body is House or level == 0 and touch_ground):
		_has_touched_down = true
		touched_down.emit()

	if level > 0 and touch_ground:
		_game.call_game_over()


func _draw() -> void:
	var half := SIZE / 2.0
	var is_top := level == BUILDING_HEIGHT

	if is_top:
		# pitched roof over a shorter top floor
		var roof_height := SIZE.y * 0.4
		draw_rect(Rect2(-half.x, -half.y + roof_height, SIZE.x, SIZE.y - roof_height), _color)
		draw_colored_polygon(PackedVector2Array([
			Vector2(-half.x * 0.95, -half.y + roof_height),
			Vector2(half.x * 0.14, -half.y),
			Vector2(half.x * 0.95, -half.y + roof_height),
		]), ROOF_COLOR)
		_draw_window(0, Vector2(-0.25, 0.2))
		_draw_window(1, Vector2(0.22, 0.2))
		return

	draw_rect(Rect2(-half, SIZE), _color)

	# flip every other floor vertically so the windows don't line up perfectly
	if level > 0 and level % 2 == 0:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1, -1))

	_draw_window(0, Vector2(-0.25, -0.25))
	_draw_window(1, Vector2(0.22, -0.25))
	if level == 0:
		# door at the bottom of the ground floor
		var w := SIZE.x * 0.22
		var h := SIZE.y * 0.42
		var x := -SIZE.x * 0.03
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - w * 0.32, half.y - h),
			Vector2(x + w * 0.5, half.y - h),
			Vector2(x + w * 0.48, half.y),
			Vector2(x - w * 0.5, half.y),
		]), DOOR_COLOR)
	else:
		_draw_window(2, Vector2(-0.24, 0.24))
		_draw_window(3, Vector2(0.21, 0.25))
	draw_set_transform(Vector2.ZERO)


func _draw_window(slot: int, center: Vector2) -> void:
	var c := center * SIZE
	var s := WINDOW_SIZE * SIZE
	var jitter: Array = WINDOW_JITTER[slot]
	var corners := PackedVector2Array()
	for i in 4:
		var corner := Vector2(-0.5 if i == 0 or i == 3 else 0.5, -0.5 if i < 2 else 0.5)
		corners.append(c + (corner + jitter[i]) * s)
	draw_colored_polygon(corners, WINDOW_COLOR)
