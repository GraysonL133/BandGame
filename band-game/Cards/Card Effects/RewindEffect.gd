class_name RewindEffect
extends CardEffect

@export var rhythm = 0
@export var starting_rhythm = rhythm

func execute(game, _target):
	print("Duplicated the last R Card played.")
	game.duplicateLastRCard()
	
