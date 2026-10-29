extends Node3D

@export var species: PokemonSpecies

func _ready() -> void:
	if species == null:
		push_warning("Nenhuma espécie foi configurada para esta unidade.")
		return

	print("Espécie carregada: ", species.display_name)
