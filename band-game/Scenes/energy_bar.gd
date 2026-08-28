extends ColorRect

@onready var energy_portion
@onready var energy_bar_start = size.y
@onready var energy_bar = self
@onready var game = $"../../.."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$"../PlayArea".card_played.connect(_update_energy)
	game.turn_ended.connect(_reset_energy)
	energy_portion = energy_bar.size.y/GameState.maxEnergy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _update_energy(card_data: CardData):
	if card_data == null:
		return
	else:
		GameState.energy -= card_data.cost
		energy_bar.size.y -= (energy_portion * card_data.cost)

func _reset_energy():
	GameState.energy = GameState.maxEnergy
	energy_bar.size.y = energy_bar_start
