extends CharacterBody3D

@export var up_vector_display : Label
@export var camera_pivot : Node3D
@export var camera : Camera3D
@export var forward_node : Node3D
var speed := 5.0
var jump_speed := 5.0
var mouse_sensitivity := 0.002

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var up_vector = Vector3(0, 0, position.z) - position
	if(up_vector == Vector3.ZERO):
		up_vector = slight_drift()
	up_vector_display.text = str(up_vector)
	set_up_direction(up_vector)
	var angle = Vector2(position.x, position.y).angle()
	set_rotation(Vector3(0, 0, angle + deg_to_rad(90)))
	apply_controls()
	var subjective_gravity = -up_vector * delta
	up_vector_display.text += str("\n", subjective_gravity)
	velocity.y += subjective_gravity.y
	velocity.x += subjective_gravity.x
	
	up_vector_display.text += str("\nis_on_floor ", is_on_floor())

	move_and_slide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click") && Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(85), deg_to_rad(80))

func apply_controls():
	if(is_on_floor()):
		var input = Input.get_vector("left", "right", "forward", "backward")
		var movement_dir = basis * camera_pivot.basis * Vector3(input.x, 0, input.y)
		up_vector_display.text += str("\n", movement_dir)
		velocity.x = movement_dir.x * speed
		velocity.y = movement_dir.y * speed
		velocity.z = movement_dir.z * speed
		if Input.is_action_just_pressed("jump"):
			var jump_dir = basis * Vector3(0, jump_speed, 0)
			velocity.x += jump_dir.x
			velocity.y += jump_dir.y
	else:
		up_vector_display.text += str("\n", Vector3.ZERO)

func slight_drift() -> Vector3:
	var rnd = RandomNumberGenerator.new()
	rnd.randomize()
	return Vector3(rnd.randfn(), rnd.randfn(), 0)
