class_name MoveDefinition
extends Resource

enum DamageCategory {
	PHYSICAL,
	SPECIAL,
	STATUS
}

@export var move_id: StringName
@export var display_name: String = "Novo movimento"
@export var type_id: StringName = &"normal"
@export var category: DamageCategory = DamageCategory.PHYSICAL
@export var power: int = 40
@export var accuracy: float = 1.0
@export var attack_range: float = 1.0
@export var cooldown: float = 1.0
