# card.gd
class_name Card
extends Control

@export var data: CardData

@onready var name_label: Label = $NameLabel
@onready var cost_label: Label = $CostLabel
@onready var desc_label: Label = $DescLabel
@onready var background: TextureRect = $Background

func _ready() -> void:
	if data:
		setup(data)

func setup(card_data: CardData) -> void:
	data = card_data
	name_label.text = data.card_name
	cost_label.text = str(data.cost)
	desc_label.text = data.description
	if data.art:
		background.texture = data.art



# --- Drag and drop (Godot 4 Control virtuals) ---
func _get_drag_data(_at_position: Vector2) -> Variant:
	# A small preview that follows the cursor while dragging.
	var preview := duplicate()
	preview.modulate = Color(1, 1, 1, 0.7)
	set_drag_preview(preview)
	# Return THIS card as the payload the play area will receive.
	return self
