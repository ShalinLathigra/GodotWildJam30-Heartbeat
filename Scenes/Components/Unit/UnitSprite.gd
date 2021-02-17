extends AnimatedSprite

onready var state  = Globals.state.IDLE
onready var state_stack = []

# Should hook up a signal to determine what state you're gonna be in. 
# Signal to trigger Attack, Move, etc. Then set state = top of pop_stack each time a next_state signal is received

func add_state(st : int) -> void:
	state_stack.push_front(state)
	state = st
	update_sprite()

func pop_state() -> void:
	self.state = state_stack.pop_front()
	update_sprite()

func update_sprite():
	animation = Globals.anims[state]
