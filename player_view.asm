# need to save some typing
.include "macros.asm"
.include "constants.asm"
# need to access the offset definitons for the player array
.include "player_struct.asm"

.globl player_draw
.data
.text	

# void player_draw()
#	t0 = player_get_element
#	display_blit_5x5_trans(%(t0+player_x),%(t0+player_y),master_chief_pattern)	

player_draw:
	enter
	jal	player_get_element
	move	t0,v0				# t0 contains memory address of player struct array
	lw	a0,player_x(t0)			# gets x coordinate of player
	lw	a1,player_y(t0)			# gets y coordinate of player
	la	a2,master_chief_pattern		# loads character bit pattern	
	jal	display_blit_5x5_trans		# draws character
	leave
