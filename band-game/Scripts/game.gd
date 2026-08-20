# game.gd
extends Node2D

@export var card_scene: PackedScene          # Card.tscn
@export var starting_deck_r: Array[CardData] = []
@export var starting_deck_l: Array[CardData] = []
@export var starting_deck_s: Array[CardData] = []
@onready var starting_deck: Array[CardData] = []

@export var Class = "Rhythm"

@onready var roundLabel = $WorldLayer/RoundLabel

@onready var lead_label: Label

#Declare which round it is
@onready var currentRound = 0
@export var roundTarget = 5

@onready var spacing = 60

@onready var energy_portion
@onready var energy_bar_start = $WorldLayer/EnergyBarBorder/EnergyBar.size.y

var ghost_nodes: Array = []
var deck: Array[CardData] = []
var hand: Array[Card] = []
var discard: Array[CardData] = []
var rCards: Array = []

const HAND_SIZE := 999

@onready var hand_container = $HandLayer/HandContainer
@onready var ghost_container: HBoxContainer = $GhostLayer/ghostContainer 

@onready var ghost: Control

# game.gd (continued)
@export var max_energy := 5
var energy := 5

@onready var energy_bar: ColorRect = $WorldLayer/EnergyBarBorder/EnergyBar


func _ready_connections() -> void:
	$WorldLayer/PlayArea.card_played.connect(_on_card_played)
	$HandLayer/Card.cardHovered.connect(_on_card_hovered)

func _on_card_played(card: Card) -> void:
	
	var card_data := card.data
	print("_on_card_played ran. Card data: ", card_data.card_name)
	if card_data.cost > energy:
		return                       # not enough energy this turn
	
	updateEnergy(card_data)
	apply_effect(card_data)
	
	# Move the card out of the hand and into the discard pile.
	hand.erase(card)
	discard.append(card_data)
	card.queue_free()                # remove the scene instance

func apply_effect(card_data: CardData) -> void:
	card_data.effect.execute(self, null)
	match card_data.type:
		1:
			rCards.append(card_data)
			createGhost(card_data)

func updateEnergy(card_data: CardData):
	energy -= card_data.cost
	energy_bar.size.y -= energy_portion

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
	print("")
	var lead = GameState.leadScore
	var sing = GameState.singScore
	var rhythm
	for i in range(rCards.size()):
		rhythm = rCards[i].effect.rhythm
		print("--")
		print(str(rCards[i]))
		print(str(rhythm))
		print("--")
		GameState.turnScore += (((rhythm) * lead) * sing)
	print("Lead Score: " + str(lead))
	print("Sing Score: " + str(sing))
	print("Rhythm Score: " + str(rhythm))
	print("Total Score: " + str(GameState.totalScore))
	print("Turn Score: ", GameState.turnScore)
	print("Total Score: ", GameState.totalScore , 
	" + " , GameState.turnScore)
	GameState.totalScore += GameState.turnScore
	print("= " , GameState.totalScore)
	print("rCards size: ", rCards.size())
	clearScore()

func clearScore():
	GameState.rhythmScore = 0
	GameState.leadScore = 1
	GameState.singScore = 1
	GameState.turnScore = 0

func clear_ghosts():
	for ghost_node in ghost_nodes:
		ghost_node.queue_free()
		
	ghost_nodes.clear()
	rCards.clear()

func createGhost(card):
	ghost = card_scene.instantiate()
	ghost.data = card
	ghost_container.add_child(ghost)
	ghost_nodes.append(ghost)
	ghost.modulate.a = 0.5
	ghost_container.position = Vector2(500, 300)
	ghost.scale = Vector2(0.2,0.2)
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
	energy_bar.size.y = energy_bar_start
	updateRound()
	energy = max_energy
	draw_hand()



func end_turn() -> void:
	# Discard the whole hand.
	for card in hand:
		discard.append(card.data)
		card.queue_free()
	calculateScore()
	hand.clear()
	clear_ghosts()
	start_turn()
	if (currentRound > roundTarget):
		goToShop()                     # next turn (enemy turn would go here)

func goToShop():
	get_tree().change_scene_to_file("res://Scenes/Shop.tscn")

func updateRound():
	currentRound = currentRound + 1
	roundLabel.text = str(currentRound) + "/" + str(roundTarget)
	energy_portion = energy_bar.size.y/max_energy

func _on_button_pressed() -> void:
	end_turn()

var ghost_time := 0.0
var ghost_start_y := 0.0


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
