extends Node
class_name AIController

# Called each time it’s the AI’s turn. Return any structure you like;
# for now let’s just return a slot index (int).
func decide_move(player: Node) -> int:
	# Simple example: play the first card in hand onto the first empty board slot
	var hand = player.hand  # your Hand node
	if hand.card_count() == 0:
		return -1  # “no move”
	var card = hand.get_card_at(0)
	
	# Find first empty slot on board
	var board = player.board
	for i in board.get_slot_count():
		if board.is_slot_empty(i):
			return i
	return -1
