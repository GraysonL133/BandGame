extends HFlowContainer
var ghost_container = self
var ghost_container_start_scale = self.scale.y
var ghost_container_start_pos = ghost_container.global_position
@onready var game = $"../.."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func updateContainer():
	
	var scale_factor = 0.28
	var new_scale = ghost_container_start_scale/(game.rCards.size() * scale_factor)
	
	if (game.rCards.is_empty()):
		# If there are no rhythm cards, reset the scale
		ghost_container.scale = ghost_container_start_scale
		ghost_container.global_position = ghost_container_start_pos

	elif (new_scale > ghost_container_start_scale):
		# If it would make the container bigger do not run
		return	
	
	else:
		ghost_container.scale = new_scale
