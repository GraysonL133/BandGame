class_name FlowEffect
extends CardEffect

var is_played = false
var main

func execute(game, _target):
	is_played = true
	main = game
	game.turn_ended.connect(_on_end_turn)
	
func flow():
	if is_played:
		for i in main.rCards.size():
			main.rCards[i].effect.rhythm += (main.rCards.size()*10)
	is_played = false

func _on_end_turn():
	for i in main.rCards.size():
		print("Starting Rhythm: ", main.rCards[i].effect.starting_rhythm)
		main.rCards[i].effect.rhythm = main.rCards[i].effect.starting_rhythm
