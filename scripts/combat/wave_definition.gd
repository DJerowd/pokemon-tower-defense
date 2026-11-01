class_name WaveDefinition
extends Resource

@export var display_name: String = "Nova onda"

@export var enemy_species: PokemonSpecies

@export_range(1, 100, 1)
var enemy_count: int = 5

@export_range(0.1, 30.0, 0.1)
var spawn_interval: float = 1.5

@export_range(0.1, 20.0, 0.1)
var enemy_move_speed: float = 2.0
