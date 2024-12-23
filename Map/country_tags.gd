extends TileMap
@export var country_tags := {
	"value" = null,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for cell in get_used_cells(0):
		country_tags[cell] = Vector2i(get_cell_atlas_coords(0, cell))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
