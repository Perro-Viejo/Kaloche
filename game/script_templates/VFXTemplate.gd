extends VFXInterface

# Aquí va el nombre del efecto, con el que se podrá iniciar cuando se llame a
# VFXHandler.start_vfx(vfx_names: Array)
const NAME := ''


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
func start() -> void:
	# Poner aquí la configuración de los interpolate del tween.
	tween.start()
	started()


func stop() -> void:
	.stop()


func target_set() -> void:
	# Por si hay que hacer algo cuando se define el target al que se le aplicarán
	# los tween.
	pass
