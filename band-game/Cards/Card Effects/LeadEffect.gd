class_name LeadEffect
extends CardEffect

@export var lead: int = 1

func execute(game, _target):
	print("Add ", lead, " lead!")
	game.addLead(lead)
