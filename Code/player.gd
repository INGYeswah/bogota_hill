extends RigidBody2D

@export var motor_torque: float = 300000.0
@export var max_wheel_speed: float = 18.0
@export var air_rotation_torque: float = 180000.0

var wheels: Array[RigidBody2D] = []


func _ready() -> void:
	# Recupera las ruedas que pertenecen al grupo "wheel".
	for node in get_tree().get_nodes_in_group("wheel"):
		if node is RigidBody2D:
			wheels.append(node)

	if wheels.is_empty():
		push_warning("Player: no se encontraron ruedas en el grupo 'wheel'.")


func _physics_process(_delta: float) -> void:
	var drive_direction := 0.0

	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		drive_direction += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		drive_direction -= 1.0

	if drive_direction != 0.0:
		for wheel in wheels:
			if not is_instance_valid(wheel):
				continue

			# Evita seguir acelerando una rueda que ya alcanzó el límite.
			if drive_direction > 0.0 and wheel.angular_velocity < max_wheel_speed:
				wheel.apply_torque(motor_torque)
			elif drive_direction < 0.0 and wheel.angular_velocity > -max_wheel_speed:
				wheel.apply_torque(-motor_torque)

	var tilt_direction := 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		tilt_direction -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		tilt_direction += 1.0

	if tilt_direction != 0.0:
		apply_torque(tilt_direction * air_rotation_torque)
