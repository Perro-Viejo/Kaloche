extends Sprite

export(Array, Resource) var vfxs := []

onready var _tweenA := Tween.new()
onready var _tweenB := Tween.new()


func _ready() -> void:
	add_child(_tweenA)
	add_child(_tweenB)
	
	(vfxs[0] as VFXLevitateRes).setup({
		target = self,
		tween = _tweenA,
		init_pos = position
	})
	
	(vfxs[1] as VFXZoomi).setup({
		target = self,
		tween = _tweenB,
		init_scale = scale
	})


func start_floating() -> void:
	(vfxs[0] as VFXLevitateRes).start_floating()
	(vfxs[1] as VFXZoomi).start_zoomi()
