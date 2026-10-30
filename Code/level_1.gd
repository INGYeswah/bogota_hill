extends Node2D

enum RunState { RUNNING, PAUSED, FINISHED }

const SAVE_PATH := "user://records.cfg"
const METERS_PER_PIXEL := 0.05
const FINISH_X := 16350.0

@export var save_path: String = SAVE_PATH

var coins_collected: int = 0
var distance: float = 0.0
var best_distance: float = 0.0
var best_coins: int = 0
var run_state: RunState = RunState.RUNNING
var muted: bool = false
var _start_x: float
var _save := ConfigFile.new()

@onready var player: RigidBody2D = $Player
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	_start_x = player.position.x
	_save.load(save_path)
	best_distance = maxf(0.0, float(_save.get_value("records", "distance", 0.0)))
	best_coins = maxi(0, int(_save.get_value("records", "coins", 0)))
	muted = bool(_save.get_value("settings", "muted", false))
	AudioServer.set_bus_mute(0, muted)
	player.fuel_changed.connect(update_fuel_UI)
	player.crashed.connect(finish_run)
	ui.pause_requested.connect(toggle_pause)
	ui.restart_requested.connect(restart_run)
	ui.mute_requested.connect(toggle_mute)
	update_fuel_UI(player.fuel)
	ui.set_coins(0)
	ui.set_muted(muted)
	ui.set_distance(0.0, best_distance, (FINISH_X - _start_x) * METERS_PER_PIXEL)


func _physics_process(_delta: float) -> void:
	distance = maxf(distance, maxf(0.0, (player.position.x - _start_x) * METERS_PER_PIXEL))
	ui.set_distance(distance, maxf(best_distance, distance), (FINISH_X - _start_x) * METERS_PER_PIXEL)
	ui.set_fuel_countdown(player.game_over_timer.time_left)
	if player.position.x >= FINISH_X:
		finish_run("Completaste el recorrido", true)


func addcoins(amount: int) -> void:
	if run_state != RunState.RUNNING:
		return
	coins_collected += amount
	ui.set_coins(coins_collected)


func update_fuel_UI(value: float) -> void:
	ui.set_fuel(value)


func toggle_pause() -> void:
	if run_state == RunState.FINISHED:
		return
	var pausing := run_state == RunState.RUNNING
	run_state = RunState.PAUSED if pausing else RunState.RUNNING
	get_tree().paused = pausing
	ui.show_pause(pausing)


func finish_run(reason: String, won: bool = false) -> void:
	if run_state != RunState.RUNNING:
		return
	run_state = RunState.FINISHED
	player.stop_engine()
	_store_records()
	ui.show_result(reason, won, distance, coins_collected, best_distance, best_coins)
	get_tree().paused = true


func _store_records() -> void:
	best_distance = maxf(best_distance, distance)
	best_coins = maxi(best_coins, coins_collected)
	_save.set_value("records", "distance", best_distance)
	_save.set_value("records", "coins", best_coins)
	_save_settings()


func restart_run() -> void:
	_store_records()
	get_tree().paused = false
	get_tree().reload_current_scene()


func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(0, muted)
	ui.set_muted(muted)
	_save_settings()


func _save_settings() -> void:
	_save.set_value("settings", "muted", muted)
	if _save.save(save_path) != OK:
		push_warning("No se pudieron guardar los récords y preferencias.")


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		if run_state == RunState.RUNNING:
			toggle_pause()
