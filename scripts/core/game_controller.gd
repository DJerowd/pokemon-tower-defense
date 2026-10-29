extends Node3D

@export var enemy_scene: PackedScene
@export var path_manager: PathManager

@onready var units: Node3D = $Battlefield/Units

var active_enemies: Array[EnemyUnit] = []

func _ready() -> void:
	if enemy_scene == null:
		push_warning("Configure a cena do inimigo no Inspector.")
		return

	if path_manager == null:
		push_warning("Configure o PathManager no Inspector.")
		return

	spawn_test_enemy()

func spawn_test_enemy() -> void:
	var enemy := enemy_scene.instantiate() as EnemyUnit

	if enemy == null:
		push_error("A cena configurada não possui o script EnemyUnit.")
		return

	units.add_child(enemy)
	enemy.set_path(path_manager.get_waypoints())

	enemy.reached_goal.connect(_on_enemy_reached_goal)
	enemy.defeated.connect(_on_enemy_defeated)
	active_enemies.append(enemy)

func get_nearest_enemy(from_position: Vector3) -> EnemyUnit:
	var nearest: EnemyUnit = null
	var nearest_distance: float = INF

	for enemy in active_enemies:
		if not is_instance_valid(enemy) or enemy.is_finished:
			continue

		var distance := from_position.distance_to(
			enemy.global_position
		)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy

	return nearest

func _on_enemy_reached_goal(enemy: EnemyUnit) -> void:
	active_enemies.erase(enemy)
	print("O inimigo chegou à saída!")

func _on_enemy_defeated(enemy: EnemyUnit) -> void:
	active_enemies.erase(enemy)
	print("O inimigo foi derrotado!")
