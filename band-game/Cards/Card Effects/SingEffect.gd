class_name SingEffect
extends CardEffect

@export var sing = 1

func execute(game, _target) -> void:
	print("Add ", sing, " sing!")
	game.addSing(sing)
