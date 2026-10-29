extends RigidBody2D

@export var motor_torque: float = 300000.0
@export var max_wheel_speed: float = 18.0
@export var air_rotation_torque: float = 180000.0

var wheels: Array[RigidBody2D] = []
var fuel=100
func _input(event: InputEvent) -> void:
	if get_tree().paused and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_tree().paused=false
			get_tree().reload_current_scene()

func _ready() -> void:
	# Recupera las ruedas que pertenecen al grupo "wheel".
	for node in get_tree().get_nodes_in_group("wheel"):
		if node is RigidBody2D:
			wheels.append(node)

	if wheels.is_empty():
		push_warning("Player: no se encontraron ruedas en el grupo 'wheel'.")
	get_parent().update_fuel_UI(fuel)


func _physics_process(_delta: float) -> void:
	var drive_direction := 0.0
	if fuel>0:
		$GameOverTimer.stop()
		if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
			use_fuel(_delta)
			drive_direction += 1.0
		if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
			use_fuel(_delta)
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
	else:
		if $GameOverTimer.is_stopped():
			$GameOverTimer.start()
	print(fuel)
	var tilt_direction := 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		tilt_direction -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		tilt_direction += 1.0

	if tilt_direction != 0.0:
		apply_torque(tilt_direction * air_rotation_torque)
func refuel():
	fuel=100
	get_parent().update_fuel_UI(fuel)
func use_fuel(delta):
	fuel-=10*delta
	fuel= clamp(fuel,0,100)
	get_parent().update_fuel_UI(fuel)


func _on_game_over_timer_timeout() -> void:
	#Game over
	var game_over_label = get_parent().get_node("UI/GameOverLabel")
	game_over_label.visible = true
	get_tree().paused = true
	
	
