extends Camera2D
var last_mouse_position
var state_machine
@onready var coords_label = $CanvasLayer/Coordinate_Label
# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/Desync_Label.visible = false

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
	if Input.is_action_pressed("pan_mouse") and last_mouse_position:
		var instant_mouse_movement = last_mouse_position - get_viewport().get_mouse_position()
		position.x += 1 / zoom.x * instant_mouse_movement.x
		position.y += 1 / zoom.y * instant_mouse_movement.y
	last_mouse_position = get_viewport().get_mouse_position()
	update_resolution()

func update_resolution():
	var viewport_size = get_viewport_rect().size
	$CanvasLayer.offset = viewport_size - Vector2(150, 70)
	$CanvasLayer/Coordinate_Label.position.x = -viewport_size.x + 150
	$CanvasLayer/Cash_Label.position.y = -viewport_size.y + 100

func assign_state_machine(new_state_machine):
	state_machine = new_state_machine

func unpress_all_buttons():
	state_machine.unpress_gui()
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
func update_desync_label(amount: int):
	$CanvasLayer/Desync_Label.text = str(amount)

func _on_station_button_pressed():
	state_machine.station_button_toggled()

func _on_track_button_pressed():
	state_machine.many_track_button_toggled()

func _on_depot_button_pressed():
	state_machine.depot_button_toggled()

func _on_single_track_button_pressed():
	state_machine.track_button_toggled()
