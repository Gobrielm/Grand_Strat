extends Node

var building = false
var hovering_over_gui = false
var controlling_camera = false

func default():
	controlling_camera = true

func gui_button_pressed():
	building = true
	controlling_camera = false

func gui_button_unpressed():
	building = false
	default()
