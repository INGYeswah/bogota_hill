extends Node2D

const HILLS := preload("res://Images/Other/SceneBG.png")
const CLOUDS := preload("res://Images/Other/Clouds.png")


func _ready() -> void:
	# Parallax2D is the Godot 4 replacement for ParallaxBackground/ParallaxLayer.
	_add_layer("Hills", HILLS, Vector2(0.18, 0.0), Vector2(0, -300), Vector2.ZERO)
	_add_layer("Clouds", CLOUDS, Vector2(0.08, 0.0), Vector2(0, -800), Vector2(-12, 0))


func _add_layer(layer_name: String, texture: Texture2D, scroll: Vector2, offset: Vector2, wind: Vector2) -> void:
	var layer := Parallax2D.new()
	layer.name = layer_name
	layer.scroll_scale = scroll
	layer.scroll_offset = offset
	layer.repeat_size = Vector2(texture.get_width(), 0)
	layer.repeat_times = 3
	layer.autoscroll = wind
	layer.z_index = -11 if layer_name == "Clouds" else -10
	add_child(layer)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	layer.add_child(sprite)
