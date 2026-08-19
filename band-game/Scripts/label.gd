extends Label

@onready var rhythmLabel = $"."
@onready var leadLabel = $"../LeadLabel"
@onready var singLabel = $"../SingLabel"
@onready var totalLabel = $"../TotalLabel"
@onready var turnLabel = $"../TurnLabel"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rhythmLabel.text = "Rhythm Score: " + str(GameState.rhythmScore)
	leadLabel.text = "Lead Score: " + str(GameState.leadScore)
	singLabel.text = "x" + str(GameState.singScore)
	totalLabel.text = "Total Score: " + str(GameState.totalScore)
	turnLabel.text = "Turn Score: " + str(GameState.turnScore)
