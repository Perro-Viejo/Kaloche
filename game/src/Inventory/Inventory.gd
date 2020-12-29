class_name Inventory
extends Resource

# Si es -1 entonces el espacio del inventario es infinito
export var max_size := -1
export (Array, Resource) var default_items := []

var _inventory := {}
var _current_size := 0

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func add_to_inventory(item) -> bool:
	if item.is_type("Item"):
		return _add_item_to_inventory(item)
	else:
		push_error("Object has to be or contain an Item to be added to an inventory") 
	return false


func remove_from_inventory(item) -> bool:
	var is_item = item.is_type("Item")
	var contains_item = item.get_node("Item") != null
	
	if is_item or contains_item:
		return _remove_item_from_inventory(item)
	else:
		push_error("Object has to be or contain an Item to be removed from an inventory") 
	return false


func on_item_added(item) -> void:
	pass


func on_item_removed(item) -> void:
	pass


func has_item(item_name) -> bool:
	return item_name in _inventory

func set_default_items() -> void:
	if not default_items == []:
		for i in default_items:
			_add_item_to_inventory(i)

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _add_item_to_inventory(item) -> bool:
	if max_size < 0 or _current_size + 1 <= max_size:
		if item.name_code in _inventory:
			_inventory[item.name_code].add(item)
		else:
			_inventory[item.name_code] = [item]
		item.container = self
		_current_size += 1
		on_item_added(item)
		return true
	return false

func _remove_item_from_inventory(item) -> bool:
	if item.name_code in _inventory:
		_inventory[item.name_code].erase(item)
		_current_size -= 1
		
		if _inventory[item.name_code].empty():
			_inventory.erase(item.name_code)
		item.container = null
		on_item_removed(item)
		return true
	return false
