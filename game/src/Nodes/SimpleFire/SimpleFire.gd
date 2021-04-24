tool
extends AnimatedSprite

export(Array, Resource) var vfxs setget _set_vfxs


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready() -> void:
	$VFXHandler.vfxs = vfxs



# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start() -> void:
	if not playing: playing = true
	$VFXHandler.start_vfx(['grow'])


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _set_vfxs(value: Array) -> void:
	vfxs = value
	if vfxs.size() == 1:
		vfxs[0] = VFXGrow.new()
		vfxs[0].repeat = 0
		vfxs[0].resource_name = 'grow'
		property_list_changed_notify()
