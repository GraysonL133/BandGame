class_name LeadEffect
extends CardEffect

@export var lead = 1

func execute(game, _target):
	print("Add ", lead, " lead!")
	game.addLead(lead)
