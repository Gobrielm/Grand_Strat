extends Node

var unit_array: Array = []

func _init():
	unit_array.append(infantry)
	unit_array.append(calvary)
	unit_array.append(artillery)
	unit_array.append(engineer)
	unit_array.append(officer)

func get_unit_class(type):
	if type >= 0 and type < unit_array.size():
		return unit_array[type]
	return null
