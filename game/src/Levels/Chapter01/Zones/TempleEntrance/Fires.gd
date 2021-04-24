extends Node2D

export var facade_pyramids: NodePath
export var facade_torch: NodePath


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start_front_pyramids() -> void:
	_start_fires($FrontPyramids)


func start_front_canal() -> void:
	_start_fires($FrontCanal)


func start_left_fingers() -> void:
	_start_fires($LeftFingers)


func start_right_fingers() -> void:
	_start_fires($RightFingers)


func start_facade_pyramids() -> void:
	_start_fires(get_node(facade_pyramids))


func start_torch_fire() -> void:
	_start_fires(get_node(facade_torch))


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _start_fires(node: Node2D) -> void:
	for f in node.get_children():
		f.start()
