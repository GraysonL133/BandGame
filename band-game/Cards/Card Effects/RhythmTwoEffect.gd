class_name RhythmTwoEffect
extends CardEffect

@export var rhythm: int = 1

func execute(game, _target):
	print("Duplicated the last R Card played.")
	game.duplicateLastRCard()
	game.addRhythm(rhythm)
