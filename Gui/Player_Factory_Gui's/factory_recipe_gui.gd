extends Window

@onready var recipes: ItemList = $Control/Recipes
@onready var filter: LineEdit = $Control/Search_Bar
var current_coords
var current_recipes

func _input(event):
	if event.is_action_pressed("deselect"):
		filter.release_focus()
		state_machine.unpress_gui()

func open_window(coords: Vector2i):
	popup()
	current_recipes = null
	current_coords = coords
	request_populate_recipes.rpc_id(1)

func _on_search_bar_text_changed(_new_text):
	request_populate_recipes.rpc_id(1)

@rpc("any_peer", "call_local", "unreliable")
func request_populate_recipes():
	var recipes = recipe.get_set_recipes()
	populate_recipes.rpc_id(multiplayer.get_remote_sender_id(), recipes)

@rpc("authority", "call_local", "unreliable")
func populate_recipes(recipes_array: Array):
	current_recipes = recipes_array
	recipes.clear()
	var filter_text = filter.text
	for recipe_item: Array in current_recipes:
		var inputs = recipe_item[0]
		var outputs = recipe_item[1]
		for input: String in inputs:
			if input.begins_with(filter_text):
				var str = get_name_for_recipe(inputs, outputs)
				recipes.add_item(str)

func get_name_for_recipe(inputs: Dictionary, outputs: Dictionary) -> String:
	var toReturn: String = ""
	for input: String in inputs:
		toReturn += str(inputs[input]) + " "
		toReturn += input + "+ "
	toReturn = toReturn.left(toReturn.length() - 2)
	toReturn += " = "
	for output: String in outputs:
		toReturn += str(outputs[output]) + " "
		toReturn += output + "+ "
	toReturn = toReturn.left(toReturn.length() - 2)
	return toReturn

func _ready():
	hide()

func _on_close_requested():
	state_machine.unpress_gui()
	hide()

func _on_search_bar_focus_entered():
	state_machine.gui_button_pressed()

func _on_confirm_pressed():
	var selected_recipes: Array = recipes.get_selected_items()
	if !selected_recipes.is_empty():
		var selected_recipe: Array = current_recipes[selected_recipes[0]]
		request_change_construction_recipe.rpc_id(1, current_coords, selected_recipe)
		hide()

@rpc("any_peer", "call_local", "reliable")
func request_change_construction_recipe(coords: Vector2i, selected_recipe: Array):
	terminal_map.set_construction_site_recipe(coords, selected_recipe)
