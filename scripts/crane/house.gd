class_name House
extends RigidBody2D
## A single floor of the building. Hangs on the crane until released, then falls onto the stack.

## Emitted once, when the house lands on another house or the ground floor lands on the ground.
signal landed
## Emitted when an upper floor touches the ground.
signal hit_ground

## Rows of the house sprite sheets from top to bottom.
enum SpriteRow { TOP, MIDDLE, GROUND }

const SPRITE_ROWS := 3

var level := 0
var is_released := false

var _config: HouseConfig
var _facade_color := Color.WHITE
var _has_landed := false
var _last_land_sound_time := -INF

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _land_player: AudioStreamPlayer = $LandPlayer
@onready var _facade: Sprite2D = $Facade
@onready var _windows: Sprite2D = $Windows
@onready var _details: Sprite2D = $Details


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
	body_entered.connect(_on_body_entered)
	_setup_sprites()


func release() -> void:
	is_released = true
	linear_damp = _config.released_linear_damp
	angular_damp = _config.released_angular_damp


func _setup_sprites() -> void:
	var row := SpriteRow.MIDDLE
	if level == 0:
		row = SpriteRow.GROUND
	elif level == _config.building_height:
		row = SpriteRow.TOP
	# flip every other middle floor vertically so the windows don't line up perfectly
	var flip := row == SpriteRow.MIDDLE and level % 2 == 0
	var sprite_scale := Units.PIXELS_PER_UNIT / _config.sprite_pixels_per_unit

	for sprite: Sprite2D in [_facade, _windows, _details]:
		var row_height := sprite.texture.get_height() / float(SPRITE_ROWS)
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, row * row_height, sprite.texture.get_width(), row_height)
		sprite.flip_v = flip
		sprite.scale = Vector2.ONE * sprite_scale
	_facade.modulate = _facade_color
	# door and roof only exist on the ground and top floor
	_details.visible = row != SpriteRow.MIDDLE


func _on_body_entered(body: Node) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_land_sound_time > _config.land_sound_cooldown:
		_last_land_sound_time = now
		_land_player.play()

	var is_ground := body is Ground
	if not _has_landed and (body is House or level == 0 and is_ground):
		_has_landed = true
		landed.emit()
	if level > 0 and is_ground:
		hit_ground.emit()
