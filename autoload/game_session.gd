extends Node

signal roster_changed
signal starter_selected(pokemon: PokemonInstance)

var roster: PlayerRoster
var starter_instance: PokemonInstance = null


func _ready() -> void:
	roster = PlayerRoster.new()
	roster.roster_changed.connect(_on_roster_changed)

	print("GameSession inicializada.")


func choose_starter(
	species: PokemonSpecies,
	initial_level: int = 5
) -> bool:
	if species == null:
		push_warning("Não é possível escolher uma espécie inválida.")
		return false

	if starter_instance != null:
		push_warning("O jogador já escolheu seu Pokémon inicial.")
		return false

	var pokemon := PokemonInstance.new()
	pokemon.initialize(species, initial_level)

	if not roster.add_pokemon(pokemon):
		return false

	starter_instance = pokemon

	starter_selected.emit(pokemon)

	print(
        "Pokémon inicial escolhido: %s"
		% pokemon.get_display_name()
	)

	return true


func add_pokemon(pokemon: PokemonInstance) -> bool:
	return roster.add_pokemon(pokemon)


func _on_roster_changed() -> void:
	roster_changed.emit()


func has_chosen_starter() -> bool:
	return starter_instance != null


func reset_session() -> void:
	roster.roster_changed.disconnect(_on_roster_changed)

	roster = PlayerRoster.new()
	roster.roster_changed.connect(_on_roster_changed)

	starter_instance = null

	roster_changed.emit()

	print("Sessão do jogador reiniciada.")
