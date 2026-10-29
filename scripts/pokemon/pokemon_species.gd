class_name PokemonSpecies
extends Resource

@export var species_id: StringName
@export var display_name: String
@export var national_dex_number: int = 0

@export var type_ids: Array[StringName] = []
@export var base_stats: PokemonStats

@export var sprite_set_id: StringName
@export var capture_rate: int = 45
