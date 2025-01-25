class_name station extends hold

var ingoing_cargo: fixed_hold

var connected_terminals: Dictionary = {}

func _init(new_location: Vector2i, new_owner):
	super._init(new_location)
	ingoing_cargo = fixed_hold.new(new_location)
	player_owner = new_owner

func get_storage_available_for_delievery(type: int) -> int:
	return ingoing_cargo.get_cargo_amount(type)

func can_take_type(type: int, term: terminal) -> bool:
	if term is factory or term is apex_factory:
		return term.does_accept(type)
	return false

func get_desired_cargo(type: int) -> int:
	return ingoing_cargo.get_desired_cargo(type)

func deliver_cargo(type: int, amount: int):
	var amount_to_add = ingoing_cargo.add_cargo(type, amount)
	return amount_to_add

func distribute_cargo():
	var cash = 0
	for connected_terminal in connected_terminals.values():
		if connected_terminal is factory or connected_terminal is apex_factory:
			cash += find_transfer_good(connected_terminal)
	money_controller.add_money_to_player(player_owner, cash)

func find_transfer_good(connected_terminal: terminal) -> int:
	var cash = 0
	var in_storage = ingoing_cargo.get_current_hold()
	for cargo in in_storage.size():
		if in_storage[cargo] > 0 and connected_terminal.does_accept(cargo):
			var amount = ingoing_cargo.transfer_cargo(cargo, 1)
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
		if obj is fixed_hold or obj is sink:
			add_accepts(obj)

func add_accepts(obj):
	for index in NUMBER_OF_GOODS:
		if obj.does_accept(index):
			ingoing_cargo.add_accept(index)

func get_in_accepts() -> Dictionary:
	return ingoing_cargo.accepts

func does_in_accept(type: int) -> bool:
	return ingoing_cargo.does_accept(type)

func does_out_accept(type: int) -> bool:
	return does_accept(type)

func reset_accepts_train():
	ingoing_cargo.reset_accepts()

func month_tick():
	distribute_cargo()
