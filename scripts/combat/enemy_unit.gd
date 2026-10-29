class_name EnemyUnit
extends Node3D

signal reached_goal(enemy: EnemyUnit)
signal defeated(enemy: EnemyUnit)

@export var species: PokemonSpecies
@export var move_speed: float = 2.0
@export var max_hp: int = 30

var current_hp: int
var path_points: Array[Vector3] = []
var target_index: int = 0
var is_finished: bool = false

func _ready() -> void:
	current_hp = max_hp

func set_path(points: Array[Vector3]) -> void:
	path_points = points.duplicate()
	target_index = 0

	if path_points.is_empty():
		push_warning("O inimigo recebeu um percurso vazio.")
		return

	global_position = path_points[0]

func _process(delta: float) -> void:
	if is_finished or path_points.is_empty():
		return

	if target_index >= path_points.size():
		_finish_path()
		return

	var target_position: Vector3 = path_points[target_index]
	var distance: float = global_position.distance_to(target_position)

	if distance <= 0.05:
		target_index += 1

		if target_index >= path_points.size():
			_finish_path()

		return

	global_position = global_position.move_toward(
		target_position,
		move_speed * delta
	)

func take_damage(amount: int) -> void:
	if is_finished or amount <= 0:
		return

	current_hp -= amount

	if current_hp <= 0:
		current_hp = 0
		is_finished = true
		defeated.emit(self)
		queue_free()

func _finish_path() -> void:
	if is_finished:
		return

	is_finished = true
	reached_goal.emit(self)
	queue_free()
