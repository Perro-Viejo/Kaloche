tool
class_name ZIndexChanger
extends Area2D

signal z_index_changed(new_z_index)

enum InvolvedNodesCase { BOTH, ENTER, EXIT }

export var zindex_on_entered := 0
export var zindex_on_exited := 4
export(Array, NodePath) var involved_nodes := []
export(InvolvedNodesCase) var affect_involved_on := InvolvedNodesCase.BOTH
export(Array, NodePath) var disable_lights_on_enter := []
export(Array, NodePath) var disable_lights_on_exit := []
export var disable_lights_on_ready := false
export(Array, NodePath) var pause_z_changers_on_enter := []
# TODO: ¿pausar ZIndexChanger al salir...?
export(Array, NodePath) var lights_to_enable := []
export(InvolvedNodesCase) var lights_to_enable_case := InvolvedNodesCase.BOTH

var _involved_nodes := []


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos de Godot ░░░░
func _ready():
	for p in involved_nodes:
		_involved_nodes.append(get_node(p))
	
	ready_setup()

	listen_areas(true)

	# Cosas de Editor
	modulate = Color.aqua


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos públicos ░░░░
# Pemite pausar temporalmente la escucha de las señales de entrada y salida del
# área. Esto resulta útil para que no ocurran problemas de cambio de z-index cuando
# el ZIndexChanger de otro nodo también está alterando a este y sus polígonos son
# adyacentes o están muy cerca.
func listen_areas(listen: bool) -> void:
	if not listen:
		disconnect('area_entered', self, '_change_z_index')
		disconnect('area_exited', self, '_change_z_index')
	else:
		connect('area_entered', self, '_change_z_index', [true])
		connect('area_exited', self, '_change_z_index', [false])


func ready_setup() -> void:
	if disable_lights_on_ready:
		for l in disable_lights_on_enter:
			(get_node(l) as Light2D).enabled = false
		for l in disable_lights_on_exit:
			(get_node(l) as Light2D).enabled = false


# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ métodos privados ░░░░
func _change_z_index(body: Area2D, entered: bool) -> void:
	if body.name == 'FootArea':
		var target_zindex := zindex_on_entered if entered else zindex_on_exited
		get_parent().z_index = target_zindex

		for n in _involved_nodes:
			if n:
			# Esto corrige un error que puede ocurrir si el nodo guardado en
			# el arreglo ha sido eliminado
				match affect_involved_on:
					InvolvedNodesCase.ENTER:
						if not entered:
							break
					InvolvedNodesCase.EXIT:
						if entered:
							break
				n.z_index = target_zindex

		emit_signal('z_index_changed', target_zindex)

		# Luces ----
		for l in disable_lights_on_enter:
			(get_node(l) as Light2D).enabled = !entered
		
		for l in disable_lights_on_exit:
			(get_node(l) as Light2D).enabled = entered
			
		for l in lights_to_enable:
			var enabled := entered
			match lights_to_enable_case:
				InvolvedNodesCase.ENTER:
					if not entered:
						enabled = false
				InvolvedNodesCase.EXIT:
					if entered:
						enabled = false
			(get_node(l) as Light2D).enabled = enabled
		# ---- Luces
		
		for z in pause_z_changers_on_enter:
			(get_node(z) as ZIndexChanger).listen_areas(!entered)
		
#		prints('ZIndexChanger %s: %s' % 
#			[get_parent().name, 'entra' if entered else 'sale']
#		)
