extends Node

const UNIT = "Unit"


enum state {
	IDLE = 0,
	RUN,
}

var  anims = {
	state.IDLE : "Idle", 
	state.RUN : "Run",
}
