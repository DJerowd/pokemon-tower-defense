class_name PokemonInstance
extends Resource

## Espécie compartilhada por todos os indivíduos da mesma espécie.
@export var species: PokemonSpecies

## Apelido opcional dado pelo jogador.
@export var nickname: String = ""

## Nível individual do Pokémon.
@export_range(1, 100, 1) var level: int = 5

## Experiência acumulada pelo indivíduo.
@export var experience: int = 0

## HP atual. -1 indica que o indivíduo ainda não foi inicializado.
@export var current_hp: int = -1

## Identificador próprio desta instância.
@export var instance_id: String = ""


func initialize(
	new_species: PokemonSpecies,
	initial_level: int = 5
) -> void:
	species = new_species
	level = clampi(initial_level, 1, 100)
	experience = 0

	# Cada indivíduo recebe um identificador diferente.
	instance_id = (
		str(Time.get_ticks_usec())
		+ "_"
		+ str(randi())
	)

	current_hp = get_max_hp()


func get_display_name() -> String:
	if not nickname.strip_edges().is_empty():
		return nickname

	if species != null:
		return species.display_name

	return "Pokémon desconhecido"


func get_max_hp() -> int:
	if species == null or species.base_stats == null:
		return 1

	var base_hp: int = species.base_stats.hp

	# Fórmula de HP baseada na fórmula dos jogos Pokémon.
	var calculated_hp := floori(
		(2.0 * base_hp * level) / 100.0
	) + level + 10

	return maxi(1, calculated_hp)


func is_fainted() -> bool:
	return current_hp <= 0


func take_damage(amount: int) -> void:
	if amount <= 0 or is_fainted():
		return

	current_hp = maxi(0, current_hp - amount)


func heal(amount: int) -> void:
	if amount <= 0:
		return

	current_hp = mini(
		get_max_hp(),
		current_hp + amount
	)


func restore_full_hp() -> void:
	current_hp = get_max_hp()
