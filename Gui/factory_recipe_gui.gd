extends Window

@onready var recipes: ItemList = $Control/Recipes
@onready var filter: LineEdit = $Control/Search_Bar

func _input(event):
	if event.is_action_pressed("deselect"):
		filter.release_focus()
		state_machine.unpress_gui()

func open_window(_coords: Vector2i):
	popup()
	request_populate_recipes.rpc_id(1)

func _on_search_bar_text_changed(_new_text):
	request_populate_recipes.rpc_id(1)

@rpc("any_peer", "call_local", "unreliable")
func request_populate_recipes():
	var recipes = recipe.get_set_recipes()
	populate_recipes.rpc_id(multiplayer.get_remote_sender_id(), recipes)

@rpc("authority", "call_local", "unreliable")
func populate_recipes(recipes_dict: Array):
	recipes.clear()
	var filter_text = filter.text
	for recipe_item: Array in recipes_dict:
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
	hide()


func _on_search_bar_focus_entered():
	state_machine.gui_button_pressed()
