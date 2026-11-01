class_name UnitSelectionManager
extends Node

signal unit_selected(unit: AllyUnit)
signal selection_cleared

var selected_unit: AllyUnit = null

func _ready() -> void:
	add_to_group("unit_selection_manager")

func select_unit(unit: AllyUnit) -> void:
	if unit == null:
		clear_selection()
		return

	if not is_instance_valid(unit):
		clear_selection()
		return

	if selected_unit == unit:
		return

	clear_selection()

	selected_unit = unit

	selected_unit.set_selected(true)

	unit_selected.emit(selected_unit)


func clear_selection() -> void:
	if selected_unit != null and is_instance_valid(selected_unit):
		selected_unit.set_selected(false)

	selected_unit = null

	selection_cleared.emit()


func get_selected_unit() -> AllyUnit:
	if selected_unit == null:
		return null

	if not is_instance_valid(selected_unit):
		selected_unit = null
		return null

	return selected_unit
