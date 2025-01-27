class_name base_factory extends factory_template

func _init(new_location: Vector2i, new_outputs: Dictionary):
	super._init(new_location, {}, new_outputs)
	local_pricer = local_price_controller.new({}, outputs)

func produce():
	add_outputs(max_batch_size)

func month_tick():
	for type in outputs:
		local_pricer.vary_output_price(outputs[type] * max_batch_size, type)
	produce()
	if connected_stations.size() > 0:
		distribute_cargo()
