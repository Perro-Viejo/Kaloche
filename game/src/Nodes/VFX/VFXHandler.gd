class_name VFXHandler
extends Node2D

export var target: NodePath = '../'

export(Array, Resource) var vfxs := []



func _ready() -> void:
	for v in vfxs:
		v.target = get_node(target)


func start_vfx(vfx_names: Array) -> void:
	for vfx_name in vfx_names:
		var v: VFXInterface = _get_vfx(vfx_name.to_lower())
		if v:
			if not is_instance_valid(v.tween):
				v.tween = Tween.new()
				add_child(v.tween)
			v.start()


func stop_vfx(vfx_names: Array) -> void:
	for vfx_name in vfx_names:
		var v: VFXInterface = _get_vfx(vfx_name.to_lower())
		if v: v.stop()


func _get_vfx(vfx_name: String) -> VFXInterface:
	for v in vfxs:
		if v.NAME.to_lower() == vfx_name or v.resource_name.to_lower() == vfx_name:
			return v
	return null
