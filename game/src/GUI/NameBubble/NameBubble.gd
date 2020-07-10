extends GridContainer

onready var _original_parent: Control = get_parent()
onready var _label: Label = find_node('Label')

func _ready():
	hide()
	Event.connect('name_bubble_requested', self, '_place_bubble')


func _place_bubble(target: Node2D = null, text: String = '') -> void:
	if target:
		_label.text = text
		get_parent().remove_child(self)
		target.add_child(self)
		rect_position = Vector2.ZERO
		rect_position.x -= rect_size.x / 2
		rect_position.y -= rect_size.y + 8
		show()
	else:
		_label.text = ''
		hide()
