extends Label

@onready var rhythmLabel = $"."
@onready var leadLabel = $"../LeadLabel"
@onready var singLabel = $"../SingLabel"
@onready var totalLabel = $"../TotalLabel"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rhythmLabel.text = "Rhythm Score: " + str(owner.rhythmScore)
	leadLabel.text = "Lead Score: " + str(owner.leadScore)
	singLabel.text = "Sing Score: " + str(owner.singScore)
	totalLabel.text = "Total Score: " + str(owner.totalScore)
