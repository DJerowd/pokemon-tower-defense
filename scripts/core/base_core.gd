class_name BaseCore
extends Node3D

signal health_changed(current_health: int, maximum_health: int)
signal destroyed

@export_range(1, 1000, 1)
var max_health: int = 20

var current_health: int
var is_destroyed: bool = false


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> void:
	if is_destroyed or amount <= 0:
		return

	current_health = maxi(0, current_health - amount)

	health_changed.emit(current_health, max_health)

	print("Vida da base: %d/%d" % [
		current_health,
		max_health
	])

	if current_health <= 0:
		destroy_base()


func destroy_base() -> void:
	if is_destroyed:
		return

	is_destroyed = true

	print("A base foi destruída!")

	destroyed.emit()


func heal(amount: int) -> void:
	if is_destroyed or amount <= 0:
		return

	current_health = mini(
		max_health,
		current_health + amount
	)

	health_changed.emit(current_health, max_health)
