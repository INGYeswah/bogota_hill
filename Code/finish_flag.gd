@tool
extends Node2D


func _draw() -> void:
	draw_line(Vector2(0, 0), Vector2(0, -360), Color("eff7ef"), 12.0)
	for row in range(4):
		for column in range(6):
			var color := Color("203343") if (row + column) % 2 == 0 else Color("f5f5df")
			draw_rect(Rect2(column * 28.0, -360 + row * 28.0, 28, 28), color)
