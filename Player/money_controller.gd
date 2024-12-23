extends Node

var money = {}

func _init(peers: Array):
	peers.append(1)
	for peer in peers:
		money[peer] = 100

func add_money_to_player(id: int, amount: int):
	money[id] += amount
	
func get_money(id: int) -> int:
	return money[id]

func get_money_dictionary() -> Dictionary:
	return money
