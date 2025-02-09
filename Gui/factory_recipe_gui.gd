extends Window

@onready var recipes = $Control/Recipes

func open_window(_coords: Vector2i):
	popup()

func _ready():
	hide()

func _on_close_requested():
	hide()
