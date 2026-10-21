extends Node2D

var coins: int = 0


func addcoins(amount: int) -> void:
	coins += amount
	print("Monedas recogidas: ", coins)
