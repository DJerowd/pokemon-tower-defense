class_name PathManager
extends Node3D

@export var waypoints: Array[Marker3D] = []

func get_waypoints() -> Array[Vector3]:
	var positions: Array[Vector3] = []

	for point in waypoints:
		if is_instance_valid(point):
			positions.append(point.global_position)

	return positions
