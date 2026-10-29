class_name PokemonInstance
extends RefCounted

var instance_id: String
var species: PokemonSpecies

var level: int = 5
var experience: int = 0
var ability_id: StringName
var known_move_ids: Array[StringName] = []
