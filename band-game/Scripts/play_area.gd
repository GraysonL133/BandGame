# play_area.gd
extends Control

signal card_played(card: Card)

var i = 0

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Only accept Card payloads.
	return data is Card

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var card: Card = data as Card
	card_played.emit(card)
	
