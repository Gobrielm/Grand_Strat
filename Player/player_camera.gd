extends Camera2D
var last_mouse_position
@onready var coords_label = $CanvasLayer/Coordinate_Label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):
	if Input.is_action_pressed("pan_left"):
		position.x -= 5 / zoom.x
	if Input.is_action_pressed("pan_right"):
		position.x += 5 / zoom.x
	if Input.is_action_pressed("pan_down"):
		position.y -= 5 / zoom.x
	if Input.is_action_pressed("pan_up"):
		position.y += 5 / zoom.x
	if Input.is_action_just_released("zoom_in") and zoom.x < 2:
		zoom.x += 0.05
		zoom.y += 0.05
	if Input.is_action_just_released("zoom_out") and zoom.x > 0.06:
		zoom.x -= 0.05
		zoom.y -= 0.05
	if Input.is_action_pressed("pan_mouse"):
		var instant_mouse_movement = last_mouse_position - get_viewport().get_mouse_position()
		position.x += 1 / zoom.x * instant_mouse_movement.x
		position.y += 1 / zoom.y * instant_mouse_movement.y
	last_mouse_position = get_viewport().get_mouse_position()


func unpress_all_buttons():
	for element in $CanvasLayer.get_children():
		if element is Button:
			element.unpress()

func are_all_buttons_unpressed():
	var toReturn = true
	for element in $CanvasLayer.get_children():
		if element is Button:
			toReturn = toReturn && !element.active
	return toReturn

func update_coord_label(coords: Vector2i):
	coords_label.text = str(coords)
@rpc("authority", "unreliable")
func update_cash_label(new_cash: int):
	$CanvasLayer/Cash_Label.text = str(new_cash)
