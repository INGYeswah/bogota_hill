extends CanvasLayer

signal pause_requested
signal restart_requested
signal mute_requested

var _fuel: float = 100.0
var _clock: float = 0.0
var _finished: bool = false

@onready var fuel_bar: ProgressBar = $Root/Top/Stats/FuelBox/Row/Bar
@onready var fuel_text: Label = $Root/Top/Stats/FuelBox/Row/Value
@onready var warning: Label = $Root/Warning
@onready var overlay: ColorRect = $Root/Overlay
@onready var title: Label = $Root/Overlay/Center/Card/Content/Title
@onready var reason_label: Label = $Root/Overlay/Center/Card/Content/Reason
@onready var summary: Label = $Root/Overlay/Center/Card/Content/Summary
@onready var resume: Button = $Root/Overlay/Center/Card/Content/Resume
@onready var restart: Button = $Root/Overlay/Center/Card/Content/Restart
@onready var pause_button: Button = $Root/Top/Actions/Pause
@onready var mute_button: Button = $Root/Top/Actions/Mute


func _ready() -> void:
	pause_button.pressed.connect(func(): pause_requested.emit())
	$Root/Top/Actions/Restart.pressed.connect(func(): restart_requested.emit())
	mute_button.pressed.connect(func(): mute_requested.emit())
	resume.pressed.connect(func(): pause_requested.emit())
	restart.pressed.connect(func(): restart_requested.emit())
	# The fill is unique to this UI instance, including after restarting.
	fuel_bar.add_theme_stylebox_override("fill", fuel_bar.get_theme_stylebox("fill").duplicate())


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	_clock += delta
	warning.modulate.a = 0.65 + 0.35 * sin(_clock * 7.0)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed() or event.is_echo():
		return
	# Restart removes this CanvasLayer immediately; retain the viewport first.
	var viewport := get_viewport()
	if event.is_action_pressed("restart_run"):
		restart_requested.emit()
	elif event.is_action_pressed("pause_run"):
		pause_requested.emit()
	elif event.is_action_pressed("mute_audio"):
		mute_requested.emit()
	elif _finished and event.is_action_pressed("ui_accept"):
		restart_requested.emit()
	else:
		return
	viewport.set_input_as_handled()


func set_fuel(value: float) -> void:
	_fuel = value
	fuel_bar.value = value
	fuel_text.text = "%d%%" % ceili(value)
	var fill := fuel_bar.get_theme_stylebox("fill") as StyleBoxFlat
	fill.bg_color = Color("ed765b") if value <= 20.0 else Color("8bd5a2")
	warning.visible = value <= 20.0
	warning.text = "COMBUSTIBLE BAJO · Busca un bidón" if value > 0.0 else "SIN COMBUSTIBLE · Aprovecha la inercia"


func set_fuel_countdown(time_left: float) -> void:
	if _fuel <= 0.0 and time_left > 0.0:
		warning.text = "SIN COMBUSTIBLE · %d s para alcanzar un bidón" % ceili(time_left)


func set_coins(value: int) -> void:
	$Root/Top/Stats/CoinsBox/Value.text = str(value)


func set_distance(value: float, best: float, goal: float) -> void:
	$Root/Top/Stats/DistanceBox/Value.text = "%d / %d m" % [int(value), int(goal)]
	$Root/Record.text = "RÉCORD  %d m" % int(best)
	$Root/Progress.value = clampf(value / goal * 100.0, 0.0, 100.0)


func set_muted(value: bool) -> void:
	mute_button.text = "Sonido: no" if value else "Sonido: sí"


func show_pause(pausing: bool) -> void:
	overlay.visible = pausing
	pause_button.text = "Seguir [P]" if pausing else "Pausa [P]"
	if pausing:
		title.text = "UN RESPIRO"
		reason_label.text = "Tu recorrido está en pausa"
		summary.text = "A / D o ← / →  ·  Avanzar y retroceder\nW / S o ↑ / ↓  ·  Equilibrar el carro\nR  ·  Reiniciar     M  ·  Silenciar"
		resume.show()
		resume.grab_focus()
	else:
		resume.release_focus()
		restart.release_focus()


func show_result(reason: String, won: bool, meters: float, coins: int, best: float, coin_record: int) -> void:
	_finished = true
	overlay.show()
	title.text = "¡META ALCANZADA!" if won else "FIN DEL RECORRIDO"
	title.modulate = Color("8bd5a2") if won else Color("ffd394")
	reason_label.text = reason
	summary.text = "%d m recorridos   ·   %d monedas\nRécord: %d m   ·   Mejor botín: %d" % [int(meters), coins, int(best), coin_record]
	resume.hide()
	restart.text = "Volver a jugar  [R / Enter]"
	restart.grab_focus()
