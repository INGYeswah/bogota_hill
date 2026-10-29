extends Area2D
var collected: bool = false
func _ready() -> void:
	$Sprite2D.visible = true
	$Sprite2D.modulate = Color.WHITE
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().get_current_scene().get_node("Player").refuel()
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("pickup")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
