class_name Utils extends Node

static func round(num, places) -> float:
	return round(num * pow(10, places)) / pow(10, places)
