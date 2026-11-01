extends Control

signal starter_confirmed(pokemon: PokemonInstance)

@export var available_starters: Array[PokemonSpecies] = []

@onready var pokemon_name: Label = $MainContainer/Content/PokemonInfo/PokemonName
@onready var pokemon_number: Label = $MainContainer/Content/PokemonInfo/PokemonNumber
@onready var pokemon_types: Label = $MainContainer/Content/PokemonInfo/PokemonTypes
@onready var pokemon_portrait: TextureRect = $MainContainer/Content/PokemonInfo/PokemonPortrait
@onready var description_label: Label = $MainContainer/DescriptionLabel
@onready var previous_button: Button = $MainContainer/Content/Navigation/PreviousButton
@onready var next_button: Button = $MainContainer/Content/Navigation/NextButton
@onready var confirm_button: Button = $MainContainer/ConfirmButton

var selected_index: int = 0
var selection_confirmed: bool = false


func _ready() -> void:
	previous_button.pressed.connect(_on_previous_pressed)
	next_button.pressed.connect(_on_next_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)

	if GameSession.has_chosen_starter():
		_show_already_selected()
		return

	if available_starters.is_empty():
		_show_error("Nenhum Pokémon inicial foi configurado.")
		return

	_show_selected_pokemon()


func _show_selected_pokemon() -> void:
	if available_starters.is_empty():
		return

	var species: PokemonSpecies = available_starters[selected_index]

	if species == null:
		_show_error("O recurso do Pokémon selecionado está inválido.")
		return

	pokemon_name.text = species.display_name
	pokemon_number.text = "#%03d" % species.national_dex_number
	pokemon_types.text = _format_types(species.type_ids)

	pokemon_portrait.texture = species.portrait

	description_label.text = "Escolha seu companheiro de jornada!"

	previous_button.disabled = selected_index <= 0
	next_button.disabled = selected_index >= available_starters.size() - 1


func _format_types(type_ids: Array[StringName]) -> String:
	if type_ids.is_empty():
		return "Tipo desconhecido"

	var formatted_types: Array[String] = []

	for type_id in type_ids:
		formatted_types.append(String(type_id).capitalize())

	return " / ".join(formatted_types)


func _on_previous_pressed() -> void:
	if selection_confirmed:
		return

	if selected_index > 0:
		selected_index -= 1
		_show_selected_pokemon()


func _on_next_pressed() -> void:
	if selection_confirmed:
		return

	if selected_index < available_starters.size() - 1:
		selected_index += 1
		_show_selected_pokemon()


func _on_confirm_pressed() -> void:
	if selection_confirmed:
		return

	if available_starters.is_empty():
		return

	var species: PokemonSpecies = available_starters[selected_index]

	if species == null:
		_show_error("Não foi possível confirmar este Pokémon.")
		return

	var success: bool = GameSession.choose_starter(species, 5)

	if not success:
		_show_error("Não foi possível registrar o Pokémon inicial.")
		return

	selection_confirmed = true

	var pokemon: PokemonInstance = GameSession.starter_instance

	description_label.text = "%s agora faz parte da sua equipe!" % pokemon.get_display_name()

	confirm_button.disabled = true
	previous_button.disabled = true
	next_button.disabled = true

	starter_confirmed.emit(pokemon)

	var error: Error = get_tree().change_scene_to_file(
		"res://scenes/main/game.tscn"
	)

	if error != OK:
		push_error("Não foi possível abrir a cena de batalha. Erro: %s" % error)


func _show_already_selected() -> void:
	var pokemon: PokemonInstance = GameSession.starter_instance

	description_label.text = "Você já escolheu %s como inicial." % pokemon.get_display_name()

	confirm_button.disabled = true
	previous_button.disabled = true
	next_button.disabled = true


func _show_error(message: String) -> void:
	description_label.text = message
	confirm_button.disabled = true
	previous_button.disabled = true
	next_button.disabled = true
	push_warning(message)
