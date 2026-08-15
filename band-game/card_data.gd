# card_data.gd
class_name CardData
extends Resource

@export var card_name: String = "Card 2"
@export var cost: int = 1
@export_multiline var description: String = "Add 10 Rhythm."
@export var rhythm: int = 0
@export var lead: int = 0
@export var sing: int = 0
@export var art: Texture2D

# Card behaviour as an enum keeps "what does this card do" data-driven.
enum Effect { Rhythm, Lead, Sing }
@export var effect: Effect = Effect.Rhythm
