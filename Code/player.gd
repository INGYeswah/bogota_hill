extends RigidBody2D

signal fuel_changed(value: float)
signal crashed(reason: String)

@export var motor_torque: float = 300000.0
@export var max_wheel_speed: float = 18.0
@export var air_rotation_torque: float = 180000.0
@export var fuel_consumption: float = 6.5

var wheels: Array[RigidBody2D] = []
var fuel: float = 100.0
var dead: bool = false
var throttle: float = 0.0
var _age: float = 0.0

@onready var head: RigidBody2D = $Head
@onready var engine: AudioStreamPlayer = $EngineSound
@onready var game_over_timer: Timer = $GameOverTimer


func _ready() -> void:
	# Only this car's wheels; another vehicle must not receive our input.
	for path in ["WheelHolder/Wheel", "WheelHolder/WheelHolder2/Wheel"]:
		wheels.append(get_node(path) as RigidBody2D)
	engine.stream = engine.stream.duplicate()
	(engine.stream as AudioStreamOggVorbis).loop = true
	engine.play()
	head.body_entered.connect(_on_head_body_entered)


func _physics_process(delta: float) -> void:
	if dead:
		return
	_age += delta
	throttle = Input.get_axis("drive_left", "drive_right")
	if fuel > 0.0:
		if not is_zero_approx(throttle):
			use_fuel(delta)
			for wheel in wheels:
				if wheel.angular_velocity * throttle < max_wheel_speed:
					wheel.apply_torque(motor_torque * throttle)
	else:
		throttle = 0.0
		if game_over_timer.is_stopped():
			game_over_timer.start()

	# A little chassis rotation also makes jumps controllable, as in the tutorial.
	var tilt := Input.get_axis("tilt_left", "tilt_right")
	if is_zero_approx(tilt):
		tilt = -throttle * 0.35
	apply_torque(tilt * air_rotation_torque)

	# Elastic neck: restore relative to the chassis, not world-up.
	var neck_angle := wrapf(head.global_rotation - global_rotation, -PI, PI)
	head.apply_torque(-neck_angle * 100000.0 - (head.angular_velocity - angular_velocity) * 6500.0)
	if _age > 1.0 and absf(neck_angle) > deg_to_rad(100.0):
		crash("El conductor se lastimó el cuello")
	if global_position.y > 4300.0 or global_position.x < -1100.0:
		crash("Te saliste del camino")

	var target_pitch := 0.75 + absf(throttle) * 0.45 + absf(linear_velocity.x) / 3000.0
	engine.pitch_scale = lerpf(engine.pitch_scale, target_pitch, 1.0 - exp(-4.0 * delta))
	engine.volume_db = -19.0 if fuel > 0.0 else -60.0


func refuel() -> void:
	if dead:
		return
	fuel = 100.0
	game_over_timer.stop()
	fuel_changed.emit(fuel)


func use_fuel(delta: float) -> void:
	fuel = clampf(fuel - fuel_consumption * delta, 0.0, 100.0)
	fuel_changed.emit(fuel)


func crash(reason: String) -> void:
	if dead:
		return
	dead = true
	throttle = 0.0
	game_over_timer.stop()
	engine.stop()
	crashed.emit(reason)


func stop_engine() -> void:
	engine.stop()


func _exit_tree() -> void:
	# Release the looping voice when restarting or closing the game.
	engine.stop()
	engine.stream = null


func _on_head_body_entered(body: Node) -> void:
	if _age > 0.75 and body is StaticBody2D:
		crash("El conductor golpeó el suelo")


func _on_game_over_timer_timeout() -> void:
	if fuel <= 0.0:
		crash("Te quedaste sin combustible")
