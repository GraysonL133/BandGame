class_name RhythmEffect
extends CardEffect

@export var rhythm: int = 1

func execute(game, _target):
	print("Add ", rhythm, " rhythm!")
	game.addRhythm(rhythm)
