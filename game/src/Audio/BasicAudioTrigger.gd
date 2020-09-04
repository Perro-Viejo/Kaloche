extends Area2D

export var mx = ""

func _ready():
	
	connect('area_entered', self, '_on_area_entered')

func _on_area_entered(other):	
	if other.get_name() == 'PlayerArea':
		AudioEvent.mx_request(mx)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
