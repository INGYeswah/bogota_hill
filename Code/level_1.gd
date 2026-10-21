extends Node2D

var coins_collected: int = 0


func addcoins(amount: int) -> void:
	coins_collected += amount
	$UI/Coin/Label.text = str(coins_collected)
	print("Monedas recogidas: ", coins_collected)
