extends Label

@onready var singLabel = $"../SingLabel"
@onready var totalLabel = $"../TotalLabel"
@onready var roundLabel = $"../RoundLabel"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	singLabel.text = "x" + str(GameState.singScore)
	totalLabel.text = "Total Score: " + str(GameState.totalScore)
	roundLabel.text = str(GameState.currentRound) + "/" + str(GameState.roundTarget)
