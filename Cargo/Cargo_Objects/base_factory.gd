class_name base_factory extends source

var connected_holds: Dictionary = {}

func add_terminal(coords: Vector2i, new_terminal):
	connected_holds[coords] = new_terminal

func delete_terminal(coords: Vector2i):
	connected_holds.erase(coords)

func distribute_cargo():
	for index in production.size():
		var specific_production = production[index]
		
		if specific_production > 0:
			
			distribute_specific_type(index)

func distribute_specific_type(type: int):
	var recieving_holds = []
	for connected_hold in connected_holds.values():
		if connected_hold is station:
			recieving_holds.push_back(connected_hold)
	
	var size = recieving_holds.size()
	if size == 0:
		return
	var amount_left = production[type]
	while amount_left > size and size != 0:
		var for_each_for_now = floor(amount_left / size)
		var wanted = 0
		for i in size:
			var connected_hold = recieving_holds[i]
			var amount_wanted = connected_hold.add_cargo(type, for_each_for_now)
			wanted += amount_wanted
			if amount_wanted == 0:
				recieving_holds.remove_at(i)
				i -= 1
				size = recieving_holds.size()
		amount_left -= wanted


func process(delta):
	count += delta
	if count > speed:
		if connected_holds.size() > 0:
			distribute_cargo()
		count = 0
