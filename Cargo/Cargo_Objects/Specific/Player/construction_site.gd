class_name construction_site extends factory_template

var construction_materials = {}

func _init(coords: Vector2i):
	super._init(coords, {}, {})

func buy_cargo(type: int, amount: int):
	add_cargo(type, amount)

#Recipe Stuff
func set_recipe(selected_recipe: Array):
	inputs = selected_recipe[0]
	outputs = selected_recipe[1]
	create_construction_materials()

func destroy_recipe():
	inputs = {}
	outputs = {}

func get_recipe() -> Array:
	return [inputs, outputs]

func has_recipe() -> bool:
	return !inputs.is_empty()

#Construction_materials
func create_construction_materials():
	create_construction_material(terminal_map.get_cargo_type("lumber"), 100)
	create_construction_material(terminal_map.get_cargo_type("steel"), 20)
	create_construction_material(terminal_map.get_cargo_type("iron"), 50)
	create_construction_material(terminal_map.get_cargo_type("glass"), 50)
	create_construction_material(terminal_map.get_cargo_type("tools"), 25)

func create_construction_material(type: int, amount: int):
	add_accept(type)
	construction_materials[type] = 50

func get_construction_materials() -> Dictionary:
	return construction_materials


func day_tick():
	pass

func month_tick():
	pass
	
