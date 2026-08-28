class_name RhythmEffect
extends CardEffect

@export var rhythm = 10
@export var starting_rhythm = 0

func execute(game, _target):
	starting_rhythm = rhythm
	print("Add ", rhythm, " rhythm!")
	game.addRhythm(rhythm)
