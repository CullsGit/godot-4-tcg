extends Node2D
class_name Player

@export var controller: Node = null
@onready var board = $Board
@onready var hand  = $Hand
@onready var deck  = $Deck
