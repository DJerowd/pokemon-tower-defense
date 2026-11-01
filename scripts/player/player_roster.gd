class_name PlayerRoster
extends Resource

signal roster_changed

## Quantidade máxima de Pokémon na equipe.
@export_range(1, 6, 1) var max_team_size: int = 6

## Pokémon disponíveis para utilizar nas batalhas.
@export var team: Array[PokemonInstance] = []

## Pokémon guardados no armazenamento.
@export var storage: Array[PokemonInstance] = []


func add_pokemon(pokemon: PokemonInstance) -> bool:
	if pokemon == null or pokemon.species == null:
		push_warning("Não é possível adicionar um Pokémon inválido.")
		return false

	if contains_pokemon(pokemon):
		push_warning("Esse Pokémon já pertence ao jogador.")
		return false

	# Prioriza a equipe enquanto houver espaço.
	if team.size() < max_team_size:
		team.append(pokemon)
		print("%s foi adicionado à equipe." % pokemon.get_display_name())
	else:
		storage.append(pokemon)
		print("%s foi enviado ao armazenamento." % pokemon.get_display_name())

	roster_changed.emit()
	return true


func move_to_storage(pokemon: PokemonInstance) -> bool:
	if pokemon == null or not team.has(pokemon):
		return false

	team.erase(pokemon)
	storage.append(pokemon)

	print("%s foi enviado ao armazenamento." % pokemon.get_display_name())

	roster_changed.emit()
	return true


func move_to_team(pokemon: PokemonInstance) -> bool:
	if pokemon == null or not storage.has(pokemon):
		return false

	if team.size() >= max_team_size:
		print("A equipe está cheia.")
		return false

	storage.erase(pokemon)
	team.append(pokemon)

	print("%s foi adicionado à equipe." % pokemon.get_display_name())

	roster_changed.emit()
	return true


func remove_pokemon(pokemon: PokemonInstance) -> bool:
	if pokemon == null:
		return false

	var removed := false

	if team.has(pokemon):
		team.erase(pokemon)
		removed = true
	elif storage.has(pokemon):
		storage.erase(pokemon)
		removed = true

	if removed:
		roster_changed.emit()

	return removed


func contains_pokemon(pokemon: PokemonInstance) -> bool:
	return team.has(pokemon) or storage.has(pokemon)


func get_team_size() -> int:
	return team.size()


func get_storage_size() -> int:
	return storage.size()


func is_team_full() -> bool:
	return team.size() >= max_team_size
