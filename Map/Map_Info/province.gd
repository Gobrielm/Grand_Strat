class_name province extends Node

var state_id: int
var population: int
var coords: Vector2i
var tiles: Array

func _init(_coords: Vector2, _state_id: int, _population: int, _tiles: Array):
	coords = _coords
	state_id = _state_id
	population = _population
	tiles = _tiles
