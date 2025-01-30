class_name firm extends terminal

const INITIAL_CASH = 1000

var cash: int

func _init(new_location: Vector2i):
	location = new_location
	cash = INITIAL_CASH

func get_amount_can_buy(amount_per: int) -> int:
	return floor(float(cash) / amount_per)

func add_cash(amount: int):
	cash += amount

func remove_cash(amount: int):
	cash -= amount

func get_cash() -> int:
	return cash

func transfer_cash(amount: int) -> int:
	amount = min(get_cash(), amount)
	remove_cash(amount)
	return amount
