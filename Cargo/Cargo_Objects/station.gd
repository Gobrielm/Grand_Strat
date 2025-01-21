class_name station extends fixed_hold

var connected_terminals: Dictionary = {}

func _init(new_location: Vector2i, new_owner):
	super._init(new_location)
	player_owner = new_owner

#Return amount added
func add_cargo(type: int, amount: int) -> int:
	var amount_to_add = min(max_amount - storage[type], amount)
	storage[type] += amount_to_add
	return amount_to_add

func can_take_type(type: int, term: terminal) -> bool:
	if term is factory or term is apex_factory or term is town:
		return term.does_accept(type)
	return false

func deliver_cargo(type: int, amount: int):
	add_cargo(type, amount)

func distribute_cargo():
	var cash = 0
	for connected_terminal in connected_terminals:
		cash += find_transfer_good(connected_terminal)
	print(money_controller.get_money_dictionary())
	money_controller.add_money_to_player(player_owner, cash)
	#TODO: Cash calculation
	#map.add_money_to_player(player_owner, cash)

func find_transfer_good(connected_terminal: fixed_hold) -> int:
	var cash = 0
	for cargo in storage.size():
		if storage[cargo] > 0 and connected_terminal.does_accept(cargo):
			var amount = transfer_cargo(cargo, 1)
			cash += connected_terminal.deliver_cargo(cargo, amount)
			return cash
	return cash

func add_connected_terminal(new_terminal: terminal):
	connected_terminals[new_terminal.get_location()] = new_terminal
	update_accepts_from_trains()

func remove_connected_terminal(new_terminal):
	connected_terminals.erase(new_terminal.get_location())
	update_accepts_from_trains()

func update_accepts_from_trains():
	reset_accepts_train()
	for obj:terminal in connected_terminals.values():
		if obj is hold:
			#Add more logic about not allows money for storing
			set_accepts_all()
		elif obj is fixed_hold or obj is sink or obj is town:
			add_accepts(obj)

func set_accepts_all():
	for i in NUMBER_OF_GOODS:
		accepts[i] = true

func add_accepts(obj):
	for index in NUMBER_OF_GOODS:
		if obj.does_accept(index):
			add_accept(index)

func get_accepts() -> Array:
	return accepts

func does_accept(type: int) -> bool:
	return accepts[type]

func reset_accepts_train():
	for i in NUMBER_OF_GOODS:
		accepts[i] = false
	
