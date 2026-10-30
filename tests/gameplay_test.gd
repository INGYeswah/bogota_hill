extends SceneTree

const TEST_SAVE := "user://bogota_hill_qa.cfg"
var level: Node2D
var failures: int = 0
var checks: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS ", message)
	else:
		failures += 1
		push_error("FAIL " + message)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func fresh_level() -> void:
	Input.action_release("drive_left")
	Input.action_release("drive_right")
	Input.action_release("tilt_left")
	Input.action_release("tilt_right")
	paused = false
	if is_instance_valid(level):
		level.queue_free()
		await process_frame
	level = load("res://Levels/level_1.tscn").instantiate()
	level.save_path = TEST_SAVE
	root.add_child(level)
	current_scene = level
	await frames(2)

func key_event(code: Key, physical: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	if physical:
		event.physical_keycode = code
	else:
		event.keycode = code
	return event

func _run() -> void:
	root.size = Vector2i(1152, 648)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	await fresh_level()
	for pickup in get_nodes_in_group("fuel_pickup"):
		var sprite: Sprite2D = pickup.get_node("Sprite2D")
		var bounds: Rect2 = sprite.get_rect()
		var clear_of_ground := true
		for sample in range(17):
			var bottom := sprite.to_global(Vector2(lerpf(bounds.position.x, bounds.end.x, sample / 16.0), bounds.end.y))
			var ray := PhysicsRayQueryParameters2D.create(Vector2(bottom.x, -2000), Vector2(bottom.x, 4300), 1)
			var ground: Dictionary = pickup.get_world_2d().direct_space_state.intersect_ray(ray)
			if ground.is_empty() or bottom.y > ground.position.y - 24.0:
				clear_of_ground = false
		check(clear_of_ground, "%s sprite stays completely above terrain, including its uphill edge" % pickup.name)
		var overlapping_coin := false
		var pickup_rect := Rect2(sprite.to_global(bounds.position), bounds.size * sprite.global_scale)
		for coin_pickup in get_nodes_in_group("coin_pickup"):
			var coin_sprite: Sprite2D = coin_pickup.get_node("Sprite2D")
			var coin_bounds := coin_sprite.get_rect()
			var coin_rect := Rect2(coin_sprite.to_global(coin_bounds.position), coin_bounds.size * coin_sprite.global_scale)
			if pickup_rect.intersects(coin_rect):
				overlapping_coin = true
		check(not overlapping_coin, "%s is visually separated from every coin" % pickup.name)
	check(key_event(KEY_LEFT, true).is_action_pressed("drive_left"), "left arrow is mapped to reverse")
	check(key_event(KEY_RIGHT, true).is_action_pressed("drive_right"), "right arrow is mapped to accelerator")
	check(key_event(KEY_UP, true).is_action_pressed("tilt_left") and key_event(KEY_DOWN, true).is_action_pressed("tilt_right"), "up and down arrows control balance")
	check(key_event(KEY_P).is_action_pressed("pause_run"), "virtual and accessibility keyboards support pause")
	Input.parse_input_event(key_event(KEY_ESCAPE, true))
	Input.flush_buffered_events()
	await frames(3)
	check(paused, "Escape pauses through the real input pipeline")
	Input.parse_input_event(key_event(KEY_P))
	Input.flush_buffered_events()
	await frames(3)
	check(not paused, "P resumes through the real input pipeline")
	var car = level.player
	await frames(120)
	check(is_equal_approx(car.fuel, 100.0), "idling does not consume fuel")
	check(not car.dead, "driver survives spawn and settling")
	check(car.wheels.size() == 2, "car controls exactly its own two wheels")
	check(car.engine.playing and car.engine.stream.loop, "engine sound loops")
	check(level.get_node("Background").get_child_count() == 2, "two independent parallax layers")
	var initial_fuel: float = car.fuel
	Input.action_press("drive_right")
	await frames(60)
	Input.action_release("drive_right")
	check(absf((initial_fuel - car.fuel) - car.fuel_consumption) < 0.2, "fuel consumption follows elapsed seconds")
	check(car.position.x > -85.0, "accelerator moves the physical car forward")
	initial_fuel = car.fuel
	Input.action_press("drive_right")
	Input.action_press("drive_left")
	await frames(30)
	check(is_equal_approx(initial_fuel, car.fuel), "opposite inputs do not double-charge fuel")
	Input.action_release("drive_right")
	Input.action_release("drive_left")
	level.toggle_pause()
	var paused_position: Vector2 = car.position
	initial_fuel = car.fuel
	Input.action_press("drive_right")
	await frames(45)
	check(car.position.is_equal_approx(paused_position) and is_equal_approx(initial_fuel, car.fuel), "pause freezes car, wheels, and fuel even with input")
	check(level.ui.overlay.visible and level.ui.resume.visible, "pause exposes resume and restart controls")
	level.toggle_pause()
	Input.action_release("drive_right")
	check(not paused and not level.ui.overlay.visible, "resume restores the running state")
	level.toggle_mute()
	check(AudioServer.is_bus_mute(0), "mute controls all game audio")
	await fresh_level()
	check(level.muted, "audio preference survives a new scene")
	level.toggle_mute()
	car = level.player
	var coin = level.get_node("Coin")
	var before: int = level.coins_collected
	coin._on_body_entered(car)
	coin._on_body_entered(car.wheels[0])
	check(level.coins_collected == before + coin.value, "chassis and wheel cannot collect the same coin twice")
	car.fuel = 0.0
	await frames(3)
	check(not car.game_over_timer.is_stopped(), "empty fuel starts the recovery countdown")
	var fuel_pickup = level.get_node("Fuel")
	fuel_pickup._on_body_entered(car)
	car.fuel = 60.0
	fuel_pickup._on_body_entered(car.wheels[0])
	check(is_equal_approx(car.fuel, 60.0), "fuel pickup is applied only once")
	check(car.game_over_timer.is_stopped(), "refueling cancels the pending game over")
	car.fuel = 19.0
	car.fuel_changed.emit(car.fuel)
	check(level.ui.warning.visible, "low fuel warning appears below 20 percent")
	car.refuel()
	check(not level.ui.warning.visible and level.ui.fuel_bar.value == 100.0, "refueling clears alarm and updates gauge")
	car.fuel = 0.0
	car.fuel_changed.emit(0.0)
	await frames(315)
	check(car.dead and paused and level.run_state == level.RunState.FINISHED, "empty fuel ends the run after the five-second grace period")
	check(not level.ui.resume.visible and level.ui.restart.visible, "game over offers restart without resume")
	check(not car.engine.playing, "engine stops at game over")
	await fresh_level()
	car = level.player
	await frames(65)
	car._on_head_body_entered(level.get_node("StaticBody2D"))
	check(car.dead and paused, "head hitting terrain ends the run")
	var result_text: String = level.ui.reason_label.text
	car.crash("second collision")
	check(level.ui.reason_label.text == result_text, "duplicate crash cannot replace the result")
	await fresh_level()
	car = level.player
	var start_x: float = car.position.x
	var refuels: int = 0
	var previous_fuel: float = car.fuel
	Input.action_press("drive_right")
	for frame in range(2400):
		await physics_frame
		if car.fuel > previous_fuel:
			refuels += 1
		previous_fuel = car.fuel
		if level.run_state == level.RunState.FINISHED:
			break
	Input.action_release("drive_right")
	check(car.position.x >= level.FINISH_X, "full physical drive reaches the finish before running out of fuel")
	check(refuels == 3, "full drive collects all three fuel pickups through real collisions")
	check(level.coins_collected > 0, "full drive collects coins through real collisions")
	check(level.ui.title.text == "¡META ALCANZADA!" and paused, "finish displays victory and freezes the scene")
	check(level.distance >= (level.FINISH_X - start_x) * level.METERS_PER_PIXEL - 2.0, "distance and progress match the route")
	var saved_best: float = level.best_distance
	await fresh_level()
	check(level.best_distance >= saved_best and level.best_coins > 0, "records persist into a new run")
	check(level.coins_collected == 0 and level.player.fuel == 100.0 and not paused, "new run resets fuel, coins, and pause state")
	level._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(paused and level.run_state == level.RunState.PAUSED, "losing window focus pauses automatically")
	var previous_level_id: int = level.get_instance_id()
	level.distance = saved_best + 10.0
	Input.parse_input_event(key_event(KEY_R))
	Input.flush_buffered_events()
	await frames(4)
	level = current_scene
	level.save_path = TEST_SAVE
	check(level.get_instance_id() != previous_level_id and not paused, "R reloads the scene and unpauses from the pause menu")
	check(level.coins_collected == 0 and level.player.fuel == 100.0, "keyboard restart resets the actual scene")
	var restart_save := ConfigFile.new()
	restart_save.load(TEST_SAVE)
	check(is_equal_approx(float(restart_save.get_value("records", "distance", 0.0)), saved_best + 10.0), "manual restart saves a new distance record before reloading")
	paused = false
	level.queue_free()
	await frames(90)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("RESULT ", checks - failures, "/", checks, " passed")
	# Fixed-FPS simulations can outrun the audio mixer; let it release stopped voices.
	OS.delay_msec(100)
	quit(0 if failures == 0 else 1)
