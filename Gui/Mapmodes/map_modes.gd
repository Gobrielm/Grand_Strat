extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_gui_hovered() -> bool:
	for child in get_children():
		if child.has_method("is_hovered") and child.is_hovered():
			return true
	return false


func _on_cargo_pressed():
	unpress_other_buttons()
	$Resource_Window.popup()
	press_button($cargo)

func _on_diplomatic_pressed():
	unpress_other_buttons()
	press_button($diplomatic)

func _on_strat_pressed():
	unpress_other_buttons()
	press_button($strat)

func unpress_other_buttons():
	for child in get_children():
		if child is Button:
			unpress_button(child)

func press_button(button: Button):
	unpress_other_buttons()
	if button.modulate.g == 0.75:
		button.modulate = Color(1, 1, 1, 1)
	else:
		button.modulate = Color(1, 0.75, 1, 1)
		

func unpress_button(button: Button):
	button.modulate = Color(1, 1, 1, 1)


func _on_resource_window_resource_window_picked(type: int):
	Utils.cargo_values.open_resource_map(type)
