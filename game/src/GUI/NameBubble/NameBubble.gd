extends GridContainer

func _ready():
	rect_position.x = 320 / 2
	rect_position.y = -180 / 2
	show()
	Event.connect('name_bubble_requested', self, '_place_bubble')


func _place_bubble(target: Node2D = null, text: String = '') -> void:
	if target:
		$Label.text = text
		prints('target global:', target.global_position)
		prints('target local:', target.position)
#		rect_position.x += 15
#		rect_position = (target.global_position / 8)
#		rect_position.x = abs(rect_position.x)
		show()
	else:
		$Label.text = ''
		hide()
