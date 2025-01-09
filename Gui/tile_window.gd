extends Window

var info_about_tile
var current_location
var update_timer = 0
@onready var tile_info = $tile_info
@onready var map = get_parent()
@onready var cargo_controler = map.get_node("cargo_controller")
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_timer += 1
	if update_timer == 40 and info_about_tile != null:
		update_timer = 0
		refresh_screen()
	elif update_timer > 40:
		update_timer = 0


func _on_close_requested():
	info_about_tile = null
	current_location = null
	hide()


func show_tile_info(location):
	if $tile_info.tile_metadata.has(location):
		info_about_tile = tile_info.tile_metadata.get(location)
		current_location = location
		refresh_screen()


func refresh_screen():
	var current_type = info_about_tile[0]
	if current_type == 0:
		city_tile()
	elif current_type == 1:
		depot_tile(current_location)
	elif current_type == 2:
		station_tile(current_location)


func city_tile():
	$Name.text = "[center][font_size=30]" + info_about_tile[1] + "[/font_size][/center]"
	$Size.text = "[center][font_size=30]" + str(info_about_tile[2]) + "[/font_size][/center]"
	disable_goodbox()
	enable_map()
	disable_trainbox()
	popup()

func depot_tile(coordinates: Vector2i):
	$Name.text = "[center][font_size=30]" + info_about_tile[1] + "[/font_size][/center]"
	$Size.text = ""
	var depot = tile_info.get_tile_metadata(coordinates)[2]
	$Train_Box/TrainList.clear()
	for train in depot.get_trains():
		$Train_Box/TrainList.add_item("train")
	disable_goodbox()
	disable_map()
	enable_trainbox()
	popup()

func _on_start_trains_pressed():
	var train_list: ItemList = $Train_Box/TrainList
	var trains = train_list.get_selected_items()
	var depot = tile_info.get_tile_metadata(current_location)[2]
	for index in trains:
		var train = depot.get_train(index)
		train.visible = true
		train.start_train()
		$Train_Box/TrainList.remove_item(index)
		depot.remove_train(index)

func _on_new_train_pressed():
	$Train_Box/train_car_browser.popup()
	#var depot = tile_info.get_tile_metadata(current_location)[2]
	#depot.add_new_train()

func station_tile(coordinates: Vector2i):
	$Name.text = "[center][font_size=30]" + info_about_tile[1] + "[/font_size][/center]"
	$Size.text = ""
	for i in $Cargo_Box/GoodList.item_count:
		$Cargo_Box/GoodList.remove_item(0)
	var obj: terminal = cargo_controler.get_terminal(coordinates)
	var goods = obj.get_current_hold()
	for i in goods.size():
		var cargo_name = cargo_controler.get_cargo_name(i)
		$Cargo_Box/GoodList.add_item(cargo_name + ", " + str(goods[i]))
	enable_goodbox()
	disable_map()
	disable_trainbox()
	popup()

func disable_trainbox():
	$Train_Box.visible = false
func enable_trainbox():
	$Train_Box.visible = true
func disable_goodbox():
	$Cargo_Box.visible = false
func enable_goodbox():
	$Cargo_Box.visible = true

func disable_map():
	set_map(true)
func enable_map():
	set_map(false)

func set_map(state):
	$Enter_City.disabled = state
	$Enter_City.visible = !state
	
func _on_enter_city_pressed():
	pass
	#var map = info_about_tile[3]
	#$City_Tile_Map.load_city(map)
