class_name Item
extends Resource

const ITEM_TYPE = 'Item'

export var name_code := ''
#Averiguar sobre grupos y esos visajes
export var category := 'default'
export var description_code := ''
export var texture: Texture

var container = null

func is_type(type):
	return type == self.ITEM_TYPE or .is_type(type)

func get_type():
	return self.ITEM_TYPE

func activate() -> void:
	pass

func desactivate() -> void:
	pass
