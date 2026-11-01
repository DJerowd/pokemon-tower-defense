extends Control

@export var wave_manager: WaveManager

@onready var base_label: Label = $TopPanel/TopContent/BasePanel/BaseLabel
@onready var base_health_bar: ProgressBar = $TopPanel/TopContent/BasePanel/BaseHealthBar

@onready var wave_label: Label = $TopPanel/TopContent/WavePanel/WaveLabel
@onready var enemies_label: Label = $TopPanel/TopContent/WavePanel/EnemiesLabel

@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_label: Label = $ResultPanel/ResultLabel

@onready var pause_button: Button = $BottomPanel/ControlsContainer/PauseButton
@onready var speed_button: Button = $BottomPanel/ControlsContainer/SpeedButton

signal pause_requested
signal speed_change_requested

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	speed_button.pressed.connect(_on_speed_button_pressed)
	result_panel.hide()

	if wave_manager == null:
		push_error("BattleHUD: configure o WaveManager.")
		return

	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.enemy_count_changed.connect(_on_enemy_count_changed)
	wave_manager.base_health_changed.connect(_on_base_health_changed)
	wave_manager.all_waves_completed.connect(_on_victory)
	wave_manager.game_over.connect(_on_game_over)

	_initialize_hud()

func _initialize_hud() -> void:
	if wave_manager.base_core == null:
		push_error("BattleHUD: BaseCore não configurada no WaveManager.")
		return

	var current_health: int = wave_manager.base_core.current_health
	var maximum_health: int = wave_manager.base_core.max_health

	_update_base_health(current_health, maximum_health)

	_update_enemy_count(wave_manager.active_enemies.size())

func _on_wave_started(
	wave_number: int,
	wave: WaveDefinition
) -> void:
	wave_label.text = "Onda %d: %s" % [
		wave_number,
		wave.display_name
	]

func _on_enemy_count_changed(active_count: int) -> void:
	_update_enemy_count(active_count)

func _update_enemy_count(active_count: int) -> void:
	enemies_label.text = "Inimigos em campo: %d" % active_count

func _on_base_health_changed(
	current_health: int,
	maximum_health: int
) -> void:
	_update_base_health(current_health, maximum_health)

func _update_base_health(
	current_health: int,
	maximum_health: int
) -> void:
	base_health_bar.max_value = maximum_health
	base_health_bar.value = current_health

	base_label.text = "Base: %d / %d HP" % [
		current_health,
		maximum_health
	]

func _on_victory() -> void:
	_show_result("VITÓRIA!\nTodas as ondas foram concluídas.")

func _on_game_over() -> void:
	_show_result("DERROTA!\nA base foi destruída.")

func _show_result(message: String) -> void:
	result_label.text = message
	result_panel.show()

func _on_pause_button_pressed() -> void:
	pause_requested.emit()

func _on_speed_button_pressed() -> void:
	speed_change_requested.emit()

func update_pause_button(is_paused: bool) -> void:
	pause_button.text = "Retomar" if is_paused else "Pausar"

func update_speed_button(speed: float) -> void:
	speed_button.text = "Velocidade: %.0fx" % speed
