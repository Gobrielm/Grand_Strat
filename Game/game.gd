extends Node2D
var user_information: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	any_set_money_user.rpc(multiplayer.get_unique_id(), 100)

@rpc("authority", "reliable", "call_remote")
func server_change_money_user(user_id: int, change_by: int):
	if user_information[user_id] + change_by >= 0:
		user_information[user_id] += change_by
		return true
	return false
@rpc("authority", "reliable", "call_remote")
func server_get_money_user(user_id: int) -> int:
	return user_information[user_id]

@rpc("any_peer", "reliable")
func request_change_money_user():
	pass

@rpc("any_peer", "reliable", "call_local")
func any_set_money_user(user_id: int, amount: int):
	user_information[user_id] = amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
