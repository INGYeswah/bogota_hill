
extends Area2D

@export var value: int = 5

var collected: bool = false


func _ready() -> void:
	$Sprite2D.visible = true
	$Sprite2D.modulate = Color.WHITE


func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if body.is_in_group("player"):
		collected = true

		var level = get_tree().get_current_scene()

		if level.has_method("addcoins"):
			level.addcoins(value)

		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("pickup")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pickup":
		queue_free()
