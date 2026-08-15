# game.gd
extends Node2D

@export var card_scene: PackedScene          # Card.tscn
@export var starting_deck: Array[CardData] = []

# Declare Score Variables
@onready var rhythmScore = 0
@onready var leadScore = 0
@onready var singScore = 0
@onready var totalScore = 0
var ghost_nodes: Array = []
var deck: Array[CardData] = []
var hand: Array[Card] = []
var discard: Array[CardData] = []
var rCards: Array = []

const HAND_SIZE := 5

@onready var hand_container: HBoxContainer = $HandContainer
@onready var ghost_container: HBoxContainer = $CanvasLayer/ghostContainer 

@onready var ghost: Control

# game.gd (continued)
@export var max_energy := 3
var energy := 3



func _ready_connections() -> void:
	$CanvasLayer2/PlayArea.card_played.connect(_on_card_played)

func _on_card_played(card: Card) -> void:
	
	var card_data := card.data
	print("_on_card_played ran. Card data: ", card_data.card_name)
	if card_data.cost > energy:
		return                       # not enough energy this turn

	energy -= card_data.cost
	apply_effect(card_data)

	# Move the card out of the hand and into the discard pile.
	hand.erase(card)
	discard.append(card_data)
	card.queue_free()                # remove the scene instance

func apply_effect(card_data: CardData) -> void:
	match card_data.effect:
		CardData.Effect.Rhythm:
			rCards.append(card_data)
			createGhost(card_data)
			rhythmScore += card_data.rhythm
		CardData.Effect.Lead:
			leadScore += card_data.lead
			print("New Lead Score: ", card_data.effect)
		CardData.Effect.Sing:
			singScore += card_data.sing
			print("New Sing Score: ", card_data.effect)

func calculateScore(rhythm, lead, sing):
	for i in range(rCards.size()):
		totalScore = (((totalScore + rCards[i].rhythm) * lead) * sing)

func clearScore():
	rhythmScore = 0;
	leadScore = 0;
	singScore = 0;
	totalScore = 0;

func clear_ghosts():
	for i in ghost_nodes.size():
		ghost.queue_free()
	ghost_nodes.clear()
	rCards.clear()

func createGhost(card):
	ghost = card_scene.instantiate()
	ghost.data = card
	ghost_container.add_child(ghost)
	ghost_nodes.append(ghost)
	ghost.modulate.a = 0.5
	ghost_container.position = Vector2(500, 300)
	ghost.start_ghost_animation()
	print("Ghost added: ", ghost)
	print("Ghost visible: ", ghost.visible)
	print("Ghost position: ", ghost.global_position)
	print("Ghost size: ", ghost.size)

func _ready() -> void:
	_ready_connections()
	randomize()                     # seed the global RNG for shuffle()
	build_deck()
	start_turn()

func build_deck() -> void:
	deck.clear()
	for card_data in starting_deck:
		deck.append(card_data)      # one entry per card in the deck
	deck.shuffle()
	
func draw_card() -> void:
	if deck.is_empty():
		reshuffle_discard_into_deck()
	if deck.is_empty():
		return                       # nothing left anywhere

	var card_data: CardData = deck.pop_back()
	var card: Card = card_scene.instantiate()
	hand_container.add_child(card)   # HBoxContainer lays it out for us
	card.setup(card_data)
	hand.append(card)

func draw_hand() -> void:
	for i in HAND_SIZE:
		draw_card()

func reshuffle_discard_into_deck() -> void:
	deck.append_array(discard)
	discard.clear()
	deck.shuffle()
	
# game.gd (continued)
func start_turn() -> void:
	energy = max_energy
	draw_hand()


func end_turn() -> void:
	# Discard the whole hand.
	for card in hand:
		discard.append(card.data)
		card.queue_free()
	calculateScore(rhythmScore, leadScore, singScore)
	hand.clear()
	clear_ghosts()
	clearScore()
	start_turn()                     # next turn (enemy turn would go here)


func _on_button_pressed() -> void:
	end_turn()

var ghost_time := 0.0
var ghost_start_y := 0.0
