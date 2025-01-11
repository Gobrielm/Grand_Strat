extends Node

var money = {}
var map: TileMapLayer

func _init(peers: Array, new_map: TileMapLayer):
	peers.append(1)
	for peer in peers:
		money[peer] = 1000
	map = new_map

func add_money_to_player(id: int, amount: int):
	money[id] += amount
	map.update_money_label.rpc_id(id, get_money(id))
	
func get_money(id: int) -> int:
	return money[id]

func get_money_dictionary() -> Dictionary:
	return money
