class_name rail_vertex extends Node
var location: Vector2i
var connections: Dictionary = {}

func _init(new_location: Vector2i):
	location = new_location

func get_coordinates() -> Vector2i:
	return location

func add_connection(other_vertex: rail_vertex, distance: int):
	connections[other_vertex] = distance

func remove_connection(other_vertex: rail_vertex):
	connections.erase(other_vertex)
