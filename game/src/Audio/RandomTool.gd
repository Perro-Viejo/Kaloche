extends Node2D


var index_sound = -1
var select_sound
var canplay

export (float) var Weight = 100

export (float) var Volume = 0
export (float) var Pitch = 0

export (bool) var RandomVolume
export (float) var minVolume
export (float) var maxVolume

export (bool) var RandomPitch
export (float) var minPitch
export (float) var maxPitch

var avVolume
var avPitch
var dflt_values: Dictionary

func _ready():
	Pitch = Pitch/24

	# Crear el diccionario de valores por defecto para los efectos de sonido
	# hijos
	for sfx in get_children():
		dflt_values[sfx.name] = {
			'pitch': sfx.get_pitch_scale(),
			'volume': sfx.get_volume_db()
		}

func play():
	randomize()

	index_sound = randi()%get_child_count()
	select_sound = get_child(index_sound)
	avVolume = dflt_values[select_sound.name].volume + Volume
#
	if RandomVolume == true:
		randomizeVol(avVolume, minVolume, maxVolume)
	else:
		select_sound.set_volume_db(avVolume)
#
#
	if randi()%100 <= Weight:
		select_sound.play()
		if RandomPitch == true:
			randomizePitch(dflt_values[select_sound.name].pitch, minPitch, maxPitch)
		else:
			select_sound.set_pitch_scale(dflt_values[select_sound.name].pitch + Pitch)

func stop():
	if select_sound:
		select_sound.stop()
	else:
		pass


func randomizeVol(_Volume, minVolume, maxVolume):
	var ranVol = (rand_range( minVolume, (maxVolume+1)))
	select_sound.set_volume_db(_Volume + ranVol)

func randomizePitch(_Pitch, minPitch, maxPitch):
		var ranPitch = (rand_range( minPitch + 1, (maxPitch+1))/24)
		if (_Pitch + ranPitch > 0):
			select_sound.set_pitch_scale((_Pitch + ranPitch))

