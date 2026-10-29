extends Node2D

var coins_collected: int = 0


func addcoins(amount: int) -> void:
	coins_collected += amount
	$UI/Coin/Label.text = str(coins_collected)
	print("Monedas recogidas: ", coins_collected)
func update_fuel_UI(value):
	$UI/Fuel/ProgressBar.value=value
	var stylebox= $UI/Fuel/ProgressBar.get_theme_stylebox("fill") as StyleBoxFlat
	stylebox.bg_color = Color(0,0.6,value/100)
