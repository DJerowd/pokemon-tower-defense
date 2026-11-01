
class_name PathManager
extends Node3D

@export var waypoints: Array[Marker3D] = []


func _ready() -> void:
	# Procura automaticamente o nó Waypoints, irmão do PathManager.
	if waypoints.is_empty():
		var waypoint_container: Node = get_parent().get_node_or_null("Waypoints")

		if waypoint_container == null:
			push_error("PathManager: o nó Waypoints não foi encontrado.")
			return

		for child in waypoint_container.get_children():
			if child is Marker3D:
				waypoints.append(child)

	if waypoints.is_empty():
		push_error("PathManager: nenhum waypoint foi configurado.")


func get_waypoints() -> Array[Vector3]:
	var positions: Array[Vector3] = []

	for point in waypoints:
		if is_instance_valid(point):
			positions.append(point.global_position)

	return positions
