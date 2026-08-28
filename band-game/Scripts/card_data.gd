# card_data.gd
class_name CardData
extends Resource

@export var card_name: String = "Card 2"
@export var cost: int = 1
@export_multiline var description: String = "Add 10 Rhythm."
@export var art: Texture2D


@export var rhythm: int = 0
@export var lead: int = 1
@export var sing: int = 1

@export var effect: CardEffect

#Give each card a type depending on class Rhythm is 1, Lead is 2, Sing is 3
@export var type: int
