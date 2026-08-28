# game.gd
extends Node2D

@export var card_scene: PackedScene          # Card.tscn
@export var starting_deck_r: Array[CardData] = []
@export var starting_deck_l: Array[CardData] = []
@export var starting_deck_s: Array[CardData] = []
@onready var starting_deck: Array[CardData] = []

@export var Class = "Rhythm"

@onready var lead_label: Label

@onready var spacing = 60

var ghost_nodes: Array = []
var deck: Array[CardData] = []
var hand: Array[Card] = []
var discard: Array[CardData] = []
var rCards: Array = []

const HAND_SIZE := 999

@onready var hand_container = $HandLayer/HandContainer
@onready var ghost_container: FlowContainer = $GhostLayer/ghostContainer 

@onready var ghost: Control

# game.gd (continued)
@export var max_energy := 999
var energy := 999

@onready var energy_bar: ColorRect = $WorldLayer/EnergyBarBorder/EnergyBar

@onready var ghost_time := 0.0
@onready var ghost_start_y := 0.0

signal turn_ended(game)

func _ready_connections() -> void:
	$WorldLayer/PlayArea.card_played.connect(_on_card_played)
	$HandLayer/Card.cardHovered.connect(_on_card_hovered)

func _on_card_played(card: Card) -> void:
	
	var card_data := card.data
	print("_on_card_played ran. Card data: ", card_data.card_name)
	if card_data.cost > GameState.energy:
		print("Not enough energy")
		print("Current energy: " , GameState.energy)
		print("Cost: " , card_data.cost)
		return                       # not enough energy this turn

	apply_effect(card_data)
	
	# Move the card out of the hand and into the discard pile.
	hand.erase(card)
	discard.append(card_data)
	card.queue_free() # remove the scene instance
	energy_bar._update_energy(card_data)
	
func apply_effect(card_data: CardData) -> void:
	card_data.effect.execute(self, null)
	match card_data.type:
		1:
			rCards.append(card_data)
			createGhost(card_data)

func addRhythm(amount):
	GameState.rhythmScore += amount

func addLead(amount):
	GameState.leadScore += amount

func addSing(amount):
	GameState.singScore += amount

func duplicateLastRCard():
		if (rCards.is_empty()):
			return
		var card_data = rCards.back()
		rCards.append(card_data)
		createGhost(card_data)

func _on_card_hovered(card):
	rearrange_hand(card)

func calculateScore():
	var lead = GameState.leadScore
	var sing = GameState.singScore
	var rhythm
	for i in range(rCards.size()):
		rhythm = rCards[i].effect.rhythm
		GameState.turnScore += (((rhythm) * lead) * sing)
	GameState.totalScore += GameState.turnScore
	
func clear_score():
	GameState.rhythmScore = 0
	GameState.leadScore = 1
	GameState.singScore = 1
	GameState.turnScore = 0

func clear_ghosts():
	for ghost_node in ghost_nodes:
		ghost_node.queue_free()
	
	ghost_nodes.clear()
	rCards.clear()
	#updateContainer()

func createGhost(card):
	ghost = card_scene.instantiate()
	ghost.data = card
	ghost_container.add_child(ghost)
	ghost_nodes.append(ghost)
	ghost.modulate.a = 0.5
	
	#updateContainer()
	ghost_container.queue_sort()
	ghost.start_ghost_animation()

func _ready() -> void:
	_ready_connections()
	randomize()                     # seed the global RNG for shuffle()
	build_deck()
	start_turn()

func build_deck() -> void:
	deck.clear()
	
	match Class:
		"Rhythm":
			starting_deck = starting_deck_r
		"Lead":
			starting_deck = starting_deck_l
		"Sing":
			starting_deck = starting_deck_s
	
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
	card.cardHovered.connect(_on_card_hovered)
	rearrange_hand(card)

func draw_hand() -> void:
	for i in HAND_SIZE:
		draw_card()

func rearrange_hand(card):

	var center_index = (hand.size() - 1) / 2.0

	for i in range(hand.size()):
		# Base resting position for each card
		var target_x = (i - center_index) * spacing
		var target_y = 0.0
		var hovered_index = hand.find(card)
		# Apply spread if a card is currently hovered
		if card != null:
			if i < hovered_index:
				target_x -= spacing # Push left
			elif i > hovered_index:
				target_x += spacing # Push right
			else:
				target_y -= 40.0 # Pop the hovered card upwards slightly
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(hand[i], "position:x", target_x, 0.2)
			tween.tween_property(hand[i], "position:y", target_y, 0.2)

func reshuffle_discard_into_deck() -> void:
	deck.append_array(discard)
	discard.clear()
	deck.shuffle()

# game.gd (continued)
func start_turn() -> void:
	updateRound()
	energy = max_energy
	draw_hand()


func end_turn() -> void:
	calculateScore()
	turn_ended.emit()
	
	# Discard the whole hand.
	for card in hand:
		discard.append(card.data)
		card.queue_free()

	clear_score()
	hand.clear()
	clear_ghosts()
	start_turn()
	if (GameState.currentRound > GameState.roundTarget):
		goToShop()                     # next turn (enemy turn would go here)

func goToShop():
	GameState.currentRound = 0
	get_tree().change_scene_to_file("res://Scenes/Shop.tscn")

func updateRound():
	GameState.currentRound = GameState.currentRound + 1

func _on_button_pressed() -> void:
	end_turn()

func _on_add_rhythm_button_pressed() -> void:                 # nothing left anywhere
	var card_data: CardData = preload("res://Cards/RNote.tres")
	deck.append(card_data)
	draw_card()


func _on_add_lead_button_pressed() -> void:
	var card_data: CardData = preload("res://Cards/LNote.tres")
	deck.append(card_data)
	draw_card()


func _on_add_sing_button_pressed() -> void:
	var card_data: CardData = preload("res://Cards/SNote.tres")
	deck.append(card_data)
	draw_card()
	
func changeClass(new_class: String):
	Class = new_class
	for card in hand:
		card.queue_free()
	deck.clear()
	hand.clear()
	build_deck()
	draw_hand()


func _on_change_class_rhythm_button_pressed() -> void:
	changeClass("Rhythm")



func _on_change_class_lead_button_pressed() -> void:
	changeClass("Lead")


func _on_change_class_sing_button_pressed() -> void:
	changeClass("Sing")


func _process(delta):
	for i in discard.size():
		if discard[i].effect.has_method("flow"):
			discard[i].effect.flow()
	
	for i in range(ghost_nodes.size()):
		var start = ghost_nodes[i].position.y
		ghost_nodes[i].animate(delta, start , i)
	
