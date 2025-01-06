extends Node

var unit_dictionary: Dictionary = {} # int -> type, y-coord of atlas

func _init():
	unit_dictionary[infantry] = 0
	unit_dictionary[calvary] = 1
	unit_dictionary[artillery] = 2
	unit_dictionary[engineer] = 3
	unit_dictionary[officer] = 4

func get_y_atlas_from_unit_type(type) -> int:
	if unit_dictionary.has(type):
		return unit_dictionary[type]
	return -1
